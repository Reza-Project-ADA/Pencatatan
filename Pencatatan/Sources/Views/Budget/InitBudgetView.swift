//
//  InitBudgetView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 28/04/25.
//
import CoreData
import SwiftUI

struct BudgetItem: Identifiable {
    let id = UUID()
    var category: ItemModelCategory?
    var budgetAmount: String = ""
}

struct InitBudgetView: View {
    let context: NSManagedObjectContext
    let categories: [ItemModelCategory]
    @State private var budgetItems: [BudgetItem]
    @State private var errorMessage: String? = nil
    @State private var totalBudget: String = "5000000" // Default value
    @Environment(\.presentationMode) var presentationMode

    init(context: NSManagedObjectContext, categories: [ItemModelCategory]) {
        self.context = context
        self.categories = categories
        
        var initialItems: [BudgetItem] = []
        // Pre-populate with the first 3 available categories
        for i in 0..<min(categories.count, 3) {
            initialItems.append(BudgetItem(category: categories[i]))
        }
        
        // If there are fewer than 3 categories, add empty budget items up to 3
        while initialItems.count < 3 {
            initialItems.append(BudgetItem())
        }
        
        self._budgetItems = State(initialValue: initialItems)
    }

    var isFormValid: Bool {
        // Check if at least one budget item is valid
        return budgetItems.contains { item in
            guard item.category != nil else { return false }
            guard let amount = Double(item.budgetAmount), amount > 0 else { return false }
            return true
        }
    }

    var usedBudget: Double {
        return budgetItems.compactMap { item in
            Double(item.budgetAmount)
        }.reduce(0, +)
    }

    var remainingBudget: Double {
        let total = Double(totalBudget) ?? 0
        return total - usedBudget
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Total Budget")) {
                    TextField("Total Budget", text: $totalBudget)
                        .keyboardType(.numberPad)
                    Text("Remaining: \(remainingBudget, specifier: "%.0f")")
                        .foregroundColor(remainingBudget >= 0 ? .green : .red)
                        .font(.caption)
                }

                ForEach(budgetItems.indices, id: \.self) { index in
                    Section(header: HStack {
                        Text("Budget #\(index + 1)")
                        Spacer()
                        if budgetItems.count > 1 {
                            Button(action: {
                                removeBudgetItem(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }) {
                        Picker("Select Category", selection: $budgetItems[index].category) {
                            Text("Select a category").tag(nil as ItemModelCategory?)
                            ForEach(availableCategories(excluding: index), id: \.self) { category in
                                Text(category.name).tag(category as ItemModelCategory?)
                            }
                        }

                        TextField("Monthly Budget", text: $budgetItems[index].budgetAmount)
                            .keyboardType(.numberPad)
                    }
                }

                Section {
                    Button(action: addBudgetItem) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Another Budget")
                        }
                        .foregroundColor(.blue)
                    }
                    .disabled(budgetItems.count >= categories.count)
                }

                Section {
                    Button(action: createSampleBudgets) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("Create Sample Budgets")
                        }
                        .foregroundColor(.green)
                    }
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Budgets")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveNewBudgets()
                }
                .disabled(!isFormValid)
            )
        }
    }

    func addBudgetItem() {
        budgetItems.append(BudgetItem())
    }

    func removeBudgetItem(at index: Int) {
        budgetItems.remove(at: index)
    }

    func availableCategories(excluding currentIndex: Int) -> [ItemModelCategory] {
        let selectedCategories = budgetItems.enumerated().compactMap { index, item in
            index != currentIndex ? item.category : nil
        }
        return categories.filter { category in
            !selectedCategories.contains(category)
        }
    }

    func saveNewBudgets() {
        var savedCount = 0
        var errors: [String] = []

        for (index, item) in budgetItems.enumerated() {
            guard let category = item.category else {
                continue // Skip items without category
            }

            guard let amount = Double(item.budgetAmount), amount > 0 else {
                errors.append("Budget #\(index + 1): Please enter a valid amount.")
                continue
            }

            // Check if this category already has a budget
            let request = NSFetchRequest<BudgetModel>(entityName: "BudgetModel")
            request.predicate = NSPredicate(format: "category == %@", category)

            do {
                let existingBudgets = try context.fetch(request)
                if !existingBudgets.isEmpty {
                    errors.append("Budget #\(index + 1): \(category.name) already has a budget.")
                    continue
                }

                // Create new budget
                let newBudget = BudgetModel(context: context)
                newBudget.category = category
                newBudget.limit = NSDecimalNumber(value: amount)
                newBudget.createdAt = Date()
                savedCount += 1

            } catch {
                errors.append("Budget #\(index + 1): Failed to check existing budget.")
            }
        }

        if savedCount > 0 {
            do {
                try context.save()
                if errors.isEmpty {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = "Some budgets were saved, but errors occurred:\n" + errors.joined(separator: "\n")
                }
            } catch {
                errorMessage = "Failed to save budgets: \(error.localizedDescription)"
            }
        } else {
            errorMessage = errors.isEmpty ? "No valid budgets to save." : errors.joined(separator: "\n")
        }
    }

    func createSampleBudgets() {
        let sampleBudgets = [
            "Grocery": 1_000_000,
            "Dining": 500_000,
            "Transportation": 300_000,
            "Entertainment": 200_000,
            "Shopping": 500_000,
        ]

        var createdCount = 0

        for (categoryName, budgetAmount) in sampleBudgets {
            if let category = categories.first(where: { $0.name == categoryName }) {
                // Check if a budget for this category already exists
                let request = NSFetchRequest<BudgetModel>(entityName: "BudgetModel")
                request.predicate = NSPredicate(format: "category == %@", category)

                do {
                    let existingBudgets = try context.fetch(request)
                    if existingBudgets.isEmpty {
                        let newBudget = BudgetModel(context: context)
                        newBudget.category = category
                        newBudget.limit = NSDecimalNumber(value: budgetAmount)
                        newBudget.createdAt = Date()
                        createdCount += 1
                    }
                } catch {
                    print("Failed to fetch existing budgets: \(error.localizedDescription)")
                }
            }
        }

        if createdCount > 0 {
            do {
                try context.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                errorMessage = "Failed to save sample budgets: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "No new sample budgets were created. They may already exist."
        }
    }
}
