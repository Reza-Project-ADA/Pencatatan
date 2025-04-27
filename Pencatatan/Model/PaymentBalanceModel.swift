//
//  PaymentBalanceModel.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//
import Foundation
import CoreData

@objc(PaymentBalanceModel)
public class PaymentBalanceModel: NSManagedObject {
    @NSManaged public var balance: NSDecimalNumber
    @NSManaged public var lastUpdated: Date
    @NSManaged public var paymentType: PaymentTypeModel
}

extension PaymentBalanceModel {
    /// Get or create a balance record for a payment type
    static func getOrCreateBalance(for paymentType: PaymentTypeModel, in context: NSManagedObjectContext) -> PaymentBalanceModel {
        // Check if balance record exists
        let request = NSFetchRequest<PaymentBalanceModel>(entityName: "PaymentBalanceModel")
        request.predicate = NSPredicate(format: "paymentType == %@", paymentType)
        request.fetchLimit = 1
        
        if let existingBalance = try? context.fetch(request).first {
            return existingBalance
        } else {
            // Create new balance record
            let newBalance = PaymentBalanceModel(context: context)
            newBalance.balance = NSDecimalNumber(value: 0)
            newBalance.lastUpdated = Date()
            newBalance.paymentType = paymentType
            return newBalance
        }
    }
    
    /// Update balance based on transaction type
    func updateBalance(amount: NSDecimalNumber, transactionType: String) {
        switch transactionType {
        case "income":
            self.balance = self.balance.adding(amount)
        case "expense":
            self.balance = self.balance.subtracting(amount)
        case "transfer_out":
            self.balance = self.balance.subtracting(amount)
        case "transfer_in":
            self.balance = self.balance.adding(amount)
        case "init":
            self.balance = amount
        default:
            break
        }
        self.lastUpdated = Date()
    }
}
