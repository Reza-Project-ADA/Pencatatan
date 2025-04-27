//
//  AddTransactionView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import SwiftUI

struct AddTransactionView: View {
    @Binding var path: [Screen]
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Transaction Type")) {
                    Button {
                        path = [.income]
                    } label: {
                        Text("Income")
                    }
                    Button {
                        path = [.expense]
                    } label: {
                        Text("Expense")
                    }
                    Button {
                        path = [.transfer]
                    } label: {
                        Text("Transfer")
                    }
                }
            }
        }
    }
}

#Preview {
    AddTransactionView(path: .constant([]))
}
