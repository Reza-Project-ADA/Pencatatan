//
//  BudgetModel.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 28/04/25.
//

import Foundation
import CoreData

@objc(BudgetModel)
public class BudgetModel: NSManagedObject {
    @NSManaged public var limit: NSDecimalNumber
    @NSManaged public var category: ItemModelCategory
    @NSManaged public var createdAt: Date
}
