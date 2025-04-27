//
//  TransactionModel.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import Foundation
import CoreData

@objc(ReceiptTransactionModel)
public class ReceiptTransactionModel: NSManagedObject {
    @NSManaged public var cashier: String?
    @NSManaged public var orderNumber: String
    @NSManaged public var items: NSSet? // <- untuk relationship to-many ke ItemModel
    @NSManaged public var subtotal: NSDecimalNumber
    @NSManaged public var tax: NSDecimalNumber
    @NSManaged public var total: NSDecimalNumber
    @NSManaged public var paymentType: PaymentTypeModel? // <- untuk relationship to-one
    @NSManaged public var changeTotal : NSDecimalNumber
    @NSManaged public var timestamp: Date?
    
}
