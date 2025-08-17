//
//  EditBudgetView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 28/04/25.
//


import SwiftUI
import CoreData

struct EditBudgetView: View {
    let budget: BudgetModel
    let context: NSManagedObjectContext
    
    @State private var budgetAmount: String = ""
    @State private var errorMessage: String? = nil
    @Environment(\.presentationMode) var presentationMode
    
    var isFormValid: Bool {
        guard let amount = Double(budgetAmount), amount > 0 else { return false }
        return true
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category")) {
                    Text(budget.category.name)
                        .foregroundColor(.primary)
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
            .onAppear {
                budgetAmount = budget.limit.stringValue
            }
            .navigationTitle("Edit Budget")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    updateBudget()
                }
                .disabled(!isFormValid)
            )
        }
    }
    
    func updateBudget() {
        guard let amount = Double(budgetAmount) else {
            errorMessage = "Please enter a valid amount."
            return
        }
        
        do {
            budget.limit = NSDecimalNumber(value: amount)
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = "Failed to update budget: \(error.localizedDescription)"
        }
    }
}