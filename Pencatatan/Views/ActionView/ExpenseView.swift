//
//  ExpenseView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import SwiftUI
import CoreData

struct ExpenseView: View {
    var body: some View {
        Text("ExpenseView")
    }
}

// Simple preview
#Preview {
    ExpenseView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
