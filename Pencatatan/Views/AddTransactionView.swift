//
//  AddTransactionView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import SwiftUI

struct AddTransactionView: View {
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Transaction Type")) {
                    NavigationLink {
                        IncomeView()
                    } label: {
                        Text("Income")
                    }
                    NavigationLink {
                        ExpenseView()
                    } label: {
                        Text("Expense")
                    }
                    NavigationLink {
                        TransferView()
                    } label: {
                        Text("Transfer")
                    }
                }
            }
        }
    }
}

#Preview {
    AddTransactionView()
}
