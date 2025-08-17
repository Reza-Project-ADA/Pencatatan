//
//  Persistence.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 26/04/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let paymentType = PaymentTypeModel(context: viewContext)
        paymentType.name = "Cash"
        paymentType.timestamp = Date()

        let transaction = ReceiptTransactionModel(context: viewContext)
        transaction.cashier = "Reza"
        transaction.changeTotal = 100_000.2
        transaction.orderNumber = "12345"
        transaction.paymentType = paymentType
        transaction.subtotal = 100_000
        transaction.tax = 10000
        transaction.total = 110_000
        transaction.timestamp = Date()

        let actor = ActorModel(context: viewContext)
        actor.name = "Reza"
        actor.timestamp = Date()

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Pencatatan")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        prepopulateCategories()
    }

    func prepopulateCategories() {
        let viewContext = container.viewContext
        let categories = [
            "Monthly Bills",
            "Grocery",
            "Dining",
            "Personal Care",
            "Shopping",
            "Household",
            "Entertainment",
            "Transportation",
            "Travel",
            "Accident",
            "Debt",
        ]

        let fetchRequest = NSFetchRequest<ItemModelCategory>(entityName: "ItemModelCategory")

        do {
            let existingCategories = try viewContext.fetch(fetchRequest)
            let existingCategoryNames = existingCategories.map { $0.name }

            for categoryName in categories {
                if !existingCategoryNames.contains(categoryName) {
                    let newCategory = ItemModelCategory(context: viewContext)
                    newCategory.name = categoryName
                    newCategory.timestamp = Date()
                }
            }

            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
