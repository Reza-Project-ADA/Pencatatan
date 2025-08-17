//
//  SettingsEntity.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//
import CoreData
protocol SettingsEntity: NSManagedObject {
    var id: NSManagedObjectID { get }
    func displayTitle() -> String
    func validateNewValue(_ value: String, forField field: String) -> Bool
    func updateField(_ field: String, withValue value: String)
}
