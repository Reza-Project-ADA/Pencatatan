//
//  BudgetingView.swift
//  Pencatatan
//
//  Created on 28/04/25.
//

import SwiftUI
import CoreData

struct BudgetingView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var showingAddBudgetSheet = false
    @State private var selectedCategory: ItemModelCategory?
    
    // Fetch all categories
    @FetchRequest(
        entity: ItemModelCategory.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) var categories: FetchedResults<ItemModelCategory>
    
    // Fetch all budgets
    @FetchRequest(
        entity: BudgetModel.entity(),
        sortDescriptors: [NSSortDescriptor(key: "category.name", ascending: true)]
    ) var budgets: FetchedResults<BudgetModel>
    
    // Fetch receipt transactions for spending calculations
    @FetchRequest(
        entity: ReceiptTransactionModel.entity(),
        sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]
    ) var receiptTransactions: FetchedResults<ReceiptTransactionModel>
    
    // Currency formatter
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID") // Indonesian Rupiah
        return formatter
    }()
    
    // Calculate spending for each category within the current month
    func spendingForCategory(_ category: ItemModelCategory) -> Decimal {
        // Get start of current month
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        // Filter transactions by date and look for items in the specified category
        let currentMonthSpending = receiptTransactions.reduce(Decimal(0)) { totalSpending, receipt in
            guard let timestamp = receipt.timestamp,
                  timestamp >= startOfMonth && timestamp <= endOfMonth,
                  let items = receipt.items as? Set<ItemModel> else {
                return totalSpending
            }
            
            let categoryItems = items.filter { $0.category == category }
            let categoryTotal = categoryItems.reduce(Decimal(0)) { subtotal, item in
                subtotal + (Decimal(item.price) * Decimal(item.quantity))
            }
            
            return totalSpending + categoryTotal
        }
        
        return currentMonthSpending
    }
    
    // Get budget for a specific category
    func budgetForCategory(_ category: ItemModelCategory) -> BudgetModel? {
        return budgets.first { $0.category == category }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if budgets.isEmpty {
                    emptyStateView
                } else {
                    budgetListView
                }
            }
            .navigationTitle("Budgeting")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddBudgetSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBudgetSheet) {
                AddBudgetView(context: context, categories: Array(categories))
            }
        }
    }
    
    // Empty state when no budgets exist
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "banknote.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Budgets Set")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Set spending limits for categories to track your expenses.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showingAddBudgetSheet = true
            }) {
                Text("Add Budget")
                    .fontWeight(.semibold)
                    .frame(width: 150, height: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    // Budget list when budgets exist
    var budgetListView: some View {
        List {
            ForEach(budgets, id: \.self) { budget in
                BudgetRowView(
                    budget: budget,
                    spending: spendingForCategory(budget.category),
                    currencyFormatter: currencyFormatter
                )
                .swipeActions {
                    Button(role: .destructive) {
                        context.delete(budget)
                        try? context.save()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        selectedCategory = budget.category
                        showingAddBudgetSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .sheet(isPresented: Binding<Bool>(
            get: { selectedCategory != nil },
            set: { if !$0 { selectedCategory = nil } }
        )) {
            if let category = selectedCategory, let budget = budgetForCategory(category) {
                EditBudgetView(budget: budget, context: context)
            }
        }

    }
}

struct BudgetRowView: View {
    let budget: BudgetModel
    let spending: Decimal
    let currencyFormatter: NumberFormatter
    
    var progress: Double {
        let limit = budget.limit.doubleValue
        let spent = NSDecimalNumber(decimal: spending).doubleValue
        if limit == 0 { return 0 }
        return max(0, min(spent / limit, 1.0))
    }
    
    var progressColor: Color {
        if progress >= 1.0 {
            return .red
        } else if progress >= 0.8 {
            return .orange
        } else {
            return .blue
        }
    }
    
    var formattedSpending: String {
        return currencyFormatter.string(from: NSDecimalNumber(decimal: spending)) ?? "Rp0"
    }
    
    var formattedLimit: String {
        return currencyFormatter.string(from: budget.limit) ?? "Rp0"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.category.name)
                    .font(.headline)
                Spacer()
                Text("\(formattedSpending) / \(formattedLimit)")
                    .font(.subheadline)
                    .foregroundColor(progress >= 1.0 ? .red : .primary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 12)
                        .cornerRadius(6)
                    
                    // Progress
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: max(0, min(geometry.size.width * progress, geometry.size.width)), height: 12)
                        .cornerRadius(6)
                }
            }
            .frame(height: 12)
            
            // Percentage and time period
            HStack {
                if progress >= 1.0 {
                    Text("Exceeded limit!")
                        .font(.caption)
                        .foregroundColor(.red)
                } else {
                    Text("\(Int(progress * 100))% of budget used")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Show month period
                Text(currentMonthDisplay())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    func currentMonthDisplay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
}

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
                        .keyboardType(.decimalPad)
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
                        .keyboardType(.decimalPad)
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

#Preview {
    BudgetingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
