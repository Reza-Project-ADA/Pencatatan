//
//  StoreModel.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//
import Foundation
import CoreData

@objc(StoreModel)
public class StoreModel: NSManagedObject {
    @NSManaged public var address: String?
    @NSManaged public var branch: String?
    @NSManaged public var name: String
    @NSManaged public var telp: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var receipt: ReceiptModel?
}
