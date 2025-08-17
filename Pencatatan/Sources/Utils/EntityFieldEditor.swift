//
//  EntityFieldEditor.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//


import SwiftUI
import CoreData

struct EntityFieldEditor: View {
    let entity: NSManagedObject
    let fieldName: String
    let fieldLabel: String
    let placeholder: String
    @Binding var value: String
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(fieldLabel)
                .font(.caption)
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $value)
                .padding(10)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .onSubmit {
                    isEditing = false
                }
        }
        .padding(.vertical, 4)
    }
}