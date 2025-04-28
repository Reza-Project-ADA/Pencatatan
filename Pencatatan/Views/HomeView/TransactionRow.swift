//
//  TransactionRow.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 28/04/25.
//


import SwiftUI

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
