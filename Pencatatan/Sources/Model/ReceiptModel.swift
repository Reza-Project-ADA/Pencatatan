//
//  ReceiptModel.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//
import Foundation
import CoreData

@objc(ReceiptModel)
public class ReceiptModel: NSManagedObject {
    @NSManaged public var transactions: ReceiptTransactionModel? // <- untuk relationship to-one
    @NSManaged public var store: StoreModel
    @NSManaged public var timestamp: Date?

}
