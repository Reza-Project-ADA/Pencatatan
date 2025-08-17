//
//  ActorModel.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//
import Foundation
import CoreData

@objc(ActorModel)
public class ActorModel: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var timestamp: Date
}

extension ActorModel {
    static func getSystemActor(in context: NSManagedObjectContext) -> ActorModel {
        let request = NSFetchRequest<ActorModel>(entityName: "ActorModel")
        request.predicate = NSPredicate(format: "name == %@", "System")
        request.fetchLimit = 1
        
        if let existingActor = try? context.fetch(request).first {
            return existingActor
        } else {
            let newActor = ActorModel(context: context)
            newActor.name = "System"
            newActor.timestamp = Date()
            return newActor
        }
    }
}

extension ActorModel: SettingsEntity {
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
