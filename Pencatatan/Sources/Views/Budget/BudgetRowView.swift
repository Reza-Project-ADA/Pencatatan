//
//  BudgetRowView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 28/04/25.
//


import SwiftUI
import CoreData

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