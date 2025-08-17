//
//  BudgetingView.swift
//  Pencatatan
//
//  Created on 28/04/25.
//

import CoreData
import SwiftUI

struct BudgetingView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var showingAddBudgetSheet = false
    @State private var showingInitBudgetSheet = false
    @State private var selectedBudget: BudgetModel? = nil
    @State private var selectedCategory: ItemModelCategory? = nil

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
                  let items = receipt.items as? Set<ItemModel>
            else {
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
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    selectedBudget = nil
                                    selectedCategory = nil
                                    showingAddBudgetSheet = true
                                }) {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                }
            }
            .navigationTitle("Budgeting")
            .sheet(isPresented: $showingAddBudgetSheet, onDismiss: {
                // Force a refresh of the fetch request
                if let budget = selectedBudget {
                    context.refresh(budget, mergeChanges: true)
                }
                // Clear the selected budget
                selectedBudget = nil
            }) {
                if let budget = selectedBudget {
                    EditBudgetView(budget: budget, context: context)
                } else {
                    AddBudgetView(context: context, categories: Array(categories))
                }
            }
            .sheet(isPresented: $showingInitBudgetSheet, onDismiss: {
                // Force a refresh of the fetch request
                if let budget = selectedBudget {
                    context.refresh(budget, mergeChanges: true)
                }
                // Clear the selected budget
                selectedBudget = nil
            }) {
                if let budget = selectedBudget {
                    EditBudgetView(budget: budget, context: context)
                } else {
                    InitBudgetView(context: context, categories: Array(categories))
                }
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

            VStack(spacing: 15) {
                Button(action: {
                    selectedBudget = nil
                    selectedCategory = nil
                    showingInitBudgetSheet = true
                }) {
                    Text("Initiate Budget")
                        .fontWeight(.semibold)
                        .frame(width: 250, height: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
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
                        selectedBudget = budget
                        showingAddBudgetSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

#Preview {
    BudgetingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
