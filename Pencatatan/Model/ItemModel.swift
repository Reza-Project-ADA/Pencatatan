//
//  ItemModel.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//
import Foundation
import CoreData

@objc(ItemModel)
public class ItemModel: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var quantity: Int16
    @NSManaged public var price: Double
    @NSManaged public var timestamp: Date
    
    @NSManaged public var category: ItemModelCategory?
    @NSManaged public var receiptTransaction: ReceiptTransactionModel?
}
