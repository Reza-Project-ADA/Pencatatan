//
//  HomeView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import SwiftUI

struct HomeView: View {
    @State private var path: [Screen] = []
    @Environment(\.managedObjectContext) var context
    
    // Fetch transactions
    @FetchRequest(
        entity: TransactionModel.entity(),
        sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]
    ) var transactions: FetchedResults<TransactionModel>
    
    // Fetch payment balances
    @FetchRequest(
        entity: PaymentBalanceModel.entity(),
        sortDescriptors: [NSSortDescriptor(key: "lastUpdated", ascending: false)],
        predicate: NSPredicate(format: "paymentType.deletedAt == nil")
    ) var balances: FetchedResults<PaymentBalanceModel>
    
    // Computed properties for summary
    var totalIncome: Decimal {
        let incomeTransactions = transactions.filter { $0.transactionType == "income" }
        return incomeTransactions.reduce(Decimal(0)) { $0 + ($1.amount as Decimal) }
    }
    
    var totalExpense: Decimal {
        let expenseTransactions = transactions.filter { $0.transactionType == "expense" }
        return expenseTransactions.reduce(Decimal(0)) { $0 + ($1.amount as Decimal) }
    }
    
    var difference: Decimal {
        return totalIncome - totalExpense
    }
    
    // Formatter for currency
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID") // Indonesian Rupiah
        return formatter
    }()
    
    var total: [(key: String, value: [String: Any])] {
        [
            ("income", [
                "amount": totalIncome,
                "color": Color.green
            ]),
            ("expense", [
                "amount": totalExpense,
                "color": Color.red
            ]),
            ("difference", [
                "amount": totalIncome - totalExpense,
                "color": (totalIncome - totalExpense) >= 0 ? Color.green : Color.red
            ])
        ]
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                // Totals Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Totals")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(total, id: \.key) { key, amountDict in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(key.capitalized)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if let amount = amountDict["amount"] as? Decimal,
                                       let color = amountDict["color"] as? Color {
                                        Text(currencyFormatter.string(from: NSDecimalNumber(decimal: amount)) ?? "Rp. 0")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(color)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }
                                }
                                .padding(12)
                                .frame(width: 160, height: 80)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Payment Method Balances Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Payment Methods")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(balances, id: \.id) { balance in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(balance.paymentType.name)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(currencyFormatter.string(from: balance.balance) ?? "Rp 0")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(balance.balance.decimalValue >= 0 ? .green : .red)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .padding(12)
                                .frame(width: 160, height: 80)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Transaction List
                List {
                    ForEach(transactions, id: \.id) { transaction in
                        TransactionRow(transaction: transaction, formatter: currencyFormatter)
                    }
                    .onDelete(perform: deleteTransaction) // Add this line
                }
                .listStyle(PlainListStyle())
            }
            .padding(.vertical)
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        path.append(.addTransaction)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        path.append(.balanceReconciliation)
                    } label: {
                        Image(systemName: "arrow.circlepath")
                    }
                }
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .addTransaction:
                    AddTransactionView(path: $path)
                    // Handle other destinations as needed
                case .income:
                    IncomeView(path: $path)
                        .environment(\.managedObjectContext, context)
                case .expense:
                    ExpenseView(path: $path)
                        .environment(\.managedObjectContext, context)
                case .transfer:
                    TransferView(path: $path)
                        .environment(\.managedObjectContext, context)
                case .balanceReconciliation:
                    BalanceReconciliationView(path: $path)
                        .environment(\.managedObjectContext, context)
                default:
                    EmptyView() // Handle other screen cases if needed
                }
            }
        }
        
    }
    private func deleteTransaction(at offsets: IndexSet) {
        for index in offsets {
            let transaction = transactions[index]
            context.delete(transaction)
        }
        
        do {
            try context.save()
        } catch {
            print("Error deleting transaction: \(error.localizedDescription)")
        }
    }
}

struct TransactionRow: View {
    let transaction: TransactionModel
    let formatter: NumberFormatter
    
    var body: some View {
        HStack {
            // Transaction type icon
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconName)
                    .foregroundColor(.white)
            }
            
            // Transaction details
            VStack(alignment: .leading) {
                Text(transactionTitle)
                    .font(.headline)
                
                if let summary = transaction.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text(dateFormatted)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount
            Text(formatter.string(from: transaction.amount) ?? "Rp 0")
                .fontWeight(.semibold)
                .foregroundColor(amountColor)
        }
        .padding(.vertical, 4)
    }
    
    // Helper computed properties
    var backgroundColor: Color {
        switch transaction.transactionType {
        case "income": return .green
        case "expense": return .red
        case "transfer": return .blue
        default: return .gray
        }
    }
    
    var iconName: String {
        switch transaction.transactionType {
        case "income": return "arrow.down"
        case "expense": return "arrow.up"
        case "transfer": return "arrow.left.arrow.right"
        case "init": return "arrow.triangle.2.circlepath"
        default: return "questionmark"
        }
    }
    
    var transactionTitle: String {
        switch transaction.transactionType {
        case "income": return "Income to \(transaction.paymentType?.name ?? "Unknown")"
        case "expense": return "Expense from \(transaction.paymentType?.name ?? "Unknown")"
        case "transfer": return "Transfer: \(transaction.paymentType?.name ?? "Unknown") → \(transaction.destinationPaymentType?.name ?? "Unknown")"
        case "init": return "Initial from \(transaction.paymentType?.name ?? "Unknown")"
        default: return "Unknown Transaction"
        }
    }
    
    var amountColor: Color {
        switch transaction.transactionType {
        case "income": return .green
        case "expense": return .red
        default: return .primary
        }
    }
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: transaction.timestamp)
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
