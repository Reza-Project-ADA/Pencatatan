//
//  HomeView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(
        entity: ReceiptTransactionModel.entity(),
        sortDescriptors: [])
    var transactions: FetchedResults<ReceiptTransactionModel>
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Text("Income")
                            .fontWeight(.bold)
                        Text("Rp. 100.000")
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                    VStack(spacing: 10) {
                        Text("Outcome")
                            .fontWeight(.bold)
                        Text("Rp. 50.000")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                    VStack(spacing: 10){
                        Text("Difference")
                            .fontWeight(.bold)
                        Text("Rp 50.000")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                }
                .padding(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                }
                List {
                    
                }
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddTransactionView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
