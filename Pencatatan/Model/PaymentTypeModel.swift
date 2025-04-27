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
}

extension PaymentTypeModel: SettingsEntity {
    func displayTitle() -> String {
        return name
    }
    
    func validateNewValue(_ value: String, forField field: String) -> Bool {
        // You can add specific validation logic here
        return !value.isEmpty
    }
    
    func updateField(_ field: String, withValue value: String) {
        if field == "name" {
            self.name = value
        }
        // Add more fields here as needed
    }
}
