//
//  PaymentTypeModel.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//
import Foundation
import CoreData

@objc(PaymentTypeModel)
public class PaymentTypeModel: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var timestamp: Date
    @NSManaged public var receiptTransactions: NSSet
    @NSManaged public var deletedAt: Date?
}

extension PaymentTypeModel: SettingsEntity {
    func displayTitle() -> String {
        return name
    }
    
    func validateNewValue(_ value: String, forField field: String) -> Bool {
        // You can add specific validation logic here
        if field == "initialBalance" {
            return Double(value) != nil
        }
        return !value.isEmpty
    }
    
    func updateField(_ field: String, withValue value: String) {
        if field == "name" {
            self.name = value
        } else if field == "initialBalance" {
            // Create or update the balance when setting initial balance
            if let balanceValue = Double(value) {
                let decimalValue = NSDecimalNumber(value: balanceValue)
                let context = self.managedObjectContext!
                let balance = PaymentBalanceModel.getOrCreateBalance(for: self, in: context)
                balance.balance = decimalValue
                balance.lastUpdated = Date() // Use the correct property name
                
                // Add it to transaction
                let systemActor = ActorModel.getSystemActor(in: context)
                
                let transaction = TransactionModel.createInitialBalance(amount: decimalValue, paymentType: self, actor: systemActor, context: context)
            }
        }
        // Add more fields here as needed
    }
}
