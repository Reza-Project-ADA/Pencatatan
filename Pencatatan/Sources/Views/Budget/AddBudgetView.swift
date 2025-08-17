//
//  AddBudgetView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 28/04/25.
//


import SwiftUI
import CoreData

struct AddBudgetView: View {
    let context: NSManagedObjectContext
    let categories: [ItemModelCategory]
    
    @State private var selectedCategory: ItemModelCategory?
    @State private var budgetAmount: String = ""
    @State private var errorMessage: String? = nil
    @Environment(\.presentationMode) var presentationMode
    
    var isFormValid: Bool {
        guard selectedCategory != nil else { return false }
        guard let amount = Double(budgetAmount), amount > 0 else { return false }
        return true
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $selectedCategory) {
                        Text("Select a category").tag(nil as ItemModelCategory?)
                        ForEach(categories, id: \.self) { category in
                            Text(category.name).tag(category as ItemModelCategory?)
                        }
                    }
                }
                
                Section(header: Text("Budget Limit")) {
                    TextField("Monthly Budget", text: $budgetAmount)
                        .keyboardType(.numberPad)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Budget")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveNewBudget()
                }
                .disabled(!isFormValid)
            )
        }
    }
    
    func saveNewBudget() {
        guard let category = selectedCategory else {
            errorMessage = "Please select a category."
            return
        }
        
        guard let amount = Double(budgetAmount) else {
            errorMessage = "Please enter a valid amount."
            return
        }
        
        // Check if this category already has a budget
        let request = NSFetchRequest<BudgetModel>(entityName: "BudgetModel")
        request.predicate = NSPredicate(format: "category == %@", category)
        
        do {
            let existingBudgets = try context.fetch(request)
            if !existingBudgets.isEmpty {
                errorMessage = "This category already has a budget. Please edit the existing one."
                return
            }
            
            // Create new budget
            let newBudget = BudgetModel(context: context)
            newBudget.category = category
            newBudget.limit = NSDecimalNumber(value: amount)
            newBudget.createdAt = Date()
            
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = "Failed to save budget: \(error.localizedDescription)"
        }
    }
}