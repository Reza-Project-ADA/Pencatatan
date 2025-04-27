//
//  GenericSettingsView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//


import SwiftUI
import CoreData

struct GenericSettingsView<T: SettingsEntity>: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    // Properties needed for any settings view
    let entityName: String
    let entityTitle: String
    let entityDescription: String
    let fieldConfigurations: [(field: String, label: String, placeholder: String)]
    let softDeleteEnabled: Bool
    
    // FetchRequest for the specific entity type
    @FetchRequest var items: FetchedResults<T>
    
    @State private var editMode: EditMode = .inactive
    @State private var showingAddItem = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var newItemValues: [String: String] = [:]
    @State private var editingItem: T?
    @State private var editingValues: [String: String] = [:]
    
    init(
        entityName: String,
        entityTitle: String,
        entityDescription: String,
        fieldConfigurations: [(field: String, label: String, placeholder: String)],
        sortKey: String = "name",
        softDeleteEnabled: Bool = false
    ) {
        self.entityName = entityName
        self.entityTitle = entityTitle
        self.entityDescription = entityDescription
        self.fieldConfigurations = fieldConfigurations
        self.softDeleteEnabled = softDeleteEnabled
        
        // Create fetch request with the provided entity name
        let request = NSFetchRequest<T>(entityName: entityName)
        
        if softDeleteEnabled {
            request.predicate = NSPredicate(format: "deletedAt == nil")
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: true)]
        _items = FetchRequest(fetchRequest: request)
        
        // Initialize empty values for all fields
        var initialValues: [String: String] = [:]
        for config in fieldConfigurations {
            initialValues[config.field] = ""
        }
        _newItemValues = State(initialValue: initialValues)
        _editingValues = State(initialValue: initialValues)
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(items, id: \.id) { item in
                    if editingItem?.id == item.id {
                        // Edit mode for this row
                        VStack(alignment: .leading) {
                            ForEach(fieldConfigurations, id: \.field) { config in
                                EntityFieldEditor(
                                    entity: item,
                                    fieldName: config.field,
                                    fieldLabel: config.label,
                                    placeholder: config.placeholder,
                                    value: fieldBinding(for: config.field),
                                    isEditing: editingStateBinding()
                                )
                            }
                            
                            HStack {
                                Spacer()
                                Button("Save") {
                                    updateItem()
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        // Normal display
                        Text(item.displayTitle())
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if editMode == .active {
                                    setupEditing(for: item)
                                }
                            }
                    }
                }
                .onDelete(perform: deleteItems)
                .listRowSeparator(.hidden)
            }
            
            Spacer()
        }
        .navigationTitle(entityTitle)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if editMode == .active {
                    Button("Done") {
                        editMode = .inactive
                        editingItem = nil
                    }
                } else {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if editMode == .inactive {
                    Button("Edit") {
                        editMode = .active
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if editMode == .inactive {
                    Button(action: {
                        showingAddItem = true
                        // Reset new item values
                        for config in fieldConfigurations {
                            newItemValues[config.field] = ""
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showingAddItem) {
            NavigationView {
                Form {
                    Section(header: Text("\(entityDescription) Information")) {
                        ForEach(fieldConfigurations, id: \.field) { config in
                            VStack(alignment: .leading) {
                                Text(config.label)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField(config.placeholder, text: addItemBinding(for: config.field))
                            }
                        }
                    }
                }
                .navigationTitle("Add \(entityDescription)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingAddItem = false
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            addItem()
                        }
                        .disabled(!canAddItem())
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // Helper method to check if all required fields are filled
    private func canAddItem() -> Bool {
        for config in fieldConfigurations {
            if let value = newItemValues[config.field], value.isEmpty {
                return false
            }
        }
        return true
    }
    
    // Binding for add item fields
    private func addItemBinding(for field: String) -> Binding<String> {
        return Binding(
            get: { self.newItemValues[field] ?? "" },
            set: { self.newItemValues[field] = $0 }
        )
    }
    
    // Binding for edit fields
    private func fieldBinding(for field: String) -> Binding<String> {
        return Binding(
            get: { self.editingValues[field] ?? "" },
            set: { self.editingValues[field] = $0 }
        )
    }
    
    // Binding for editing state
    private func editingStateBinding() -> Binding<Bool> {
        return Binding(
            get: { self.editingItem != nil },
            set: { if !$0 { self.editingItem = nil } }
        )
    }
    
    // Set up editing for a specific item
    private func setupEditing(for item: T) {
        editingItem = item
        
        // Initialize editing values
        for config in fieldConfigurations {
            if config.field == "name" {
                editingValues[config.field] = item.displayTitle()
            }
            // Add more field initializations here based on your entity structure
        }
    }
    
    private func addItem() {
        // Create new entity of the generic type
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        let newItem = NSManagedObject(entity: entity, insertInto: context) as! T
        
        // Update all fields from the newItemValues dictionary
        for (field, value) in newItemValues {
            newItem.updateField(field, withValue: value)
        }
        
        do {
            try context.save()
            showingAddItem = false
            
            // Reset new item values
            for config in fieldConfigurations {
                newItemValues[config.field] = ""
            }
        } catch {
            errorMessage = "Error saving \(entityDescription.lowercased()): \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
    
    private func updateItem() {
        if let item = editingItem {
            // Update all fields from the editingValues dictionary
            for (field, value) in editingValues {
                if !item.validateNewValue(value, forField: field) {
                    errorMessage = "Invalid value for \(field)"
                    showingErrorAlert = true
                    return
                }
                
                item.updateField(field, withValue: value)
            }
            
            do {
                try context.save()
                editingItem = nil
            } catch {
                errorMessage = "Error updating \(entityDescription.lowercased()): \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            
            if softDeleteEnabled, let paymentType = item as? PaymentTypeModel {
                // Perform soft delete
                paymentType.deletedAt = Date()
            } else {
                // Perform hard delete
                context.delete(item)
            }
        }
        
        do {
            try context.save()
        } catch {
            errorMessage = "Error deleting \(entityDescription.lowercased()): \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
}
