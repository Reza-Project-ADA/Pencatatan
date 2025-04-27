//
//  TransactionModel.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import Foundation
import CoreData

public class TransactionModel: NSManagedObject {
    @NSManaged public var actor: ActorModel
    @NSManaged public var amount: Double
    @NSManaged public var transactionType: String
    @NSManaged public var summary: String
    @NSManaged public var paymentType: PaymentTypeModel? // <- untuk relationship to-one
    @NSManaged public var timestamp: Date
}
