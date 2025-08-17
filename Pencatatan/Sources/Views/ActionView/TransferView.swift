//
//  TransferView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import SwiftUI
import CoreData

struct TransferView: View {
    @Binding var path: [Screen]
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentationMode
    
    // State variables for form fields
    @State private var amount: String = ""
    @State private var summary: String = ""
    @State private var selectedSourcePaymentTypeID: NSManagedObjectID?
    @State private var selectedDestinationPaymentTypeID: NSManagedObjectID?
    @State private var selectedActorID: NSManagedObjectID?
    
    // Error handling
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Fetch payment types
    @FetchRequest(
        entity: PaymentTypeModel.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
        predicate: NSPredicate(format: "deletedAt == nil")
    ) private var paymentTypes: FetchedResults<PaymentTypeModel>
    
    // Fetch actors
    @FetchRequest(
        entity: ActorModel.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) private var actors: FetchedResults<ActorModel>
    
    // Computed properties for selected entities
    private var selectedSourcePaymentType: PaymentTypeModel? {
        guard let id = selectedSourcePaymentTypeID else { return nil }
        return context.object(with: id) as? PaymentTypeModel
    }
    
    private var selectedDestinationPaymentType: PaymentTypeModel? {
        guard let id = selectedDestinationPaymentTypeID else { return nil }
        return context.object(with: id) as? PaymentTypeModel
    }
    
    private var selectedActor: ActorModel? {
        guard let id = selectedActorID else { return nil }
        return context.object(with: id) as? ActorModel
    }
    
    // Format for currency input
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        Form {
            // Transfer amount
            Section(header: Text("Amount")) {
                TextField("0", text: $amount)
                    .keyboardType(.numberPad)
            }
            
            // Source Payment Method
            Section(header: Text("From")) {
                Picker("Source Account", selection: $selectedSourcePaymentTypeID) {
                    Text("Select source account").tag(nil as NSManagedObjectID?)
                    ForEach(paymentTypes, id: \.id) { paymentType in
                        Text(paymentType.name).tag(paymentType.id as NSManagedObjectID?)
                    }
                }
            }
            
            // Destination Payment Method
            Section(header: Text("To")) {
                Picker("Destination Account", selection: $selectedDestinationPaymentTypeID) {
                    Text("Select destination account").tag(nil as NSManagedObjectID?)
                    ForEach(paymentTypes, id: \.id) { paymentType in
                        if paymentType.id != selectedSourcePaymentTypeID {
                            Text(paymentType.name).tag(paymentType.id as NSManagedObjectID?)
                        }
                    }
                }
            }
            
            // Actor selection
            Section(header: Text("Actor")) {
                Picker("Select who made this transfer", selection: $selectedActorID) {
                    Text("Select actor").tag(nil as NSManagedObjectID?)
                    ForEach(actors, id: \.id) { actor in
                        Text(actor.name).tag(actor.id as NSManagedObjectID?)
                    }
                }
            }
            
            // Notes/Summary
            Section(header: Text("Notes")) {
                TextField("Add notes about this transfer", text: $summary)
            }
            
            // Submit button
            Section {
                Button(action: saveTransfer) {
                    Text("Save Transfer")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
                .disabled(!canSaveTransfer())
            }
        }
        .navigationTitle("Transfer")
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func canSaveTransfer() -> Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }
        guard selectedSourcePaymentTypeID != nil else { return false }
        guard selectedDestinationPaymentTypeID != nil else { return false }
        guard selectedSourcePaymentTypeID != selectedDestinationPaymentTypeID else { return false }
        return true
    }
    
    private func saveTransfer() {
        guard let sourcePaymentType = selectedSourcePaymentType,
              let destinationPaymentType = selectedDestinationPaymentType,
              let amountDecimal = Decimal(string: amount) else {
            alertMessage = "Please check your input values."
            showingAlert = true
            return
        }
        
        // Get source payment balance to check if enough funds
        let sourceBalance = PaymentBalanceModel.getOrCreateBalance(for: sourcePaymentType, in: context)
        if sourceBalance.balance.decimalValue < amountDecimal {
            alertMessage = "Insufficient funds in the source account."
            showingAlert = true
            return
        }
        
        if selectedActor == nil {
            alertMessage = "Please select a recipient."
            showingAlert = true
            return
        }
        
        // Create the transaction
        _ = TransactionModel.createTransfer(
            amount: amountDecimal,
            summary: summary,
            actor: selectedActor!,
            sourcePaymentType: sourcePaymentType,
            destinationPaymentType: destinationPaymentType,
            context: context
        )
        
        // Save context
        do {
            try context.save()
            // Go back to previous screen
            presentationMode.wrappedValue.dismiss()
        } catch {
            alertMessage = "Failed to save transfer: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    TransferView(path: .constant([]))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
