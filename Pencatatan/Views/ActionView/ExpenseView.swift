//
//  ExpenseView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import SwiftUI
import CoreData

struct ExpenseView: View {
    @Binding var path: [Screen]
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentationMode
    
    // State variables for form fields
    @State private var amount: String = ""
    @State private var summary: String = ""
    @State private var selectedPaymentTypeID: NSManagedObjectID?
    @State private var selectedActorID: NSManagedObjectID?
    
    // Error handling
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Fetch payment types
    @FetchRequest(
        entity: PaymentTypeModel.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) private var paymentTypes: FetchedResults<PaymentTypeModel>
    
    // Fetch actors
    @FetchRequest(
        entity: ActorModel.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) private var actors: FetchedResults<ActorModel>
    
    // Computed properties for selected entities
    private var selectedPaymentType: PaymentTypeModel? {
        guard let id = selectedPaymentTypeID else { return nil }
        return context.object(with: id) as? PaymentTypeModel
    }
    
    private var selectedActor: ActorModel? {
        guard let id = selectedActorID else { return nil }
        return context.object(with: id) as? ActorModel
    }
    
    var body: some View {
        Form {
            // Expense amount
            Section(header: Text("Amount")) {
                TextField("0", text: $amount)
                    .keyboardType(.decimalPad)
            }
            
            // Payment Method
            Section(header: Text("Payment Method")) {
                Picker("Payment From", selection: $selectedPaymentTypeID) {
                    Text("Select payment method").tag(nil as NSManagedObjectID?)
                    ForEach(paymentTypes, id: \.id) { paymentType in
                        Text(paymentType.name).tag(paymentType.id as NSManagedObjectID?)
                    }
                }
            }
            
            // Actor selection
            Section(header: Text("Actor")) {
                Picker("Select who made this expense", selection: $selectedActorID) {
                    Text("Select actor").tag(nil as NSManagedObjectID?)
                    ForEach(actors, id: \.id) { actor in
                        Text(actor.name).tag(actor.id as NSManagedObjectID?)
                    }
                }
            }
            
            // Notes/Summary
            Section(header: Text("Notes")) {
                TextField("What was this expense for?", text: $summary)
            }
            
            // Submit button
            Section {
                Button(action: saveExpense) {
                    Text("Save Expense")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
                .disabled(!canSaveExpense())
            }
        }
        .navigationTitle("Expense")
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func canSaveExpense() -> Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }
        guard selectedPaymentTypeID != nil else { return false }
        return true
    }
    
    private func saveExpense() {
        guard let paymentType = selectedPaymentType,
              let amountDecimal = Decimal(string: amount) else {
            alertMessage = "Please check your input values."
            showingAlert = true
            return
        }
        
        // Get payment balance to check if enough funds
        let balance = PaymentBalanceModel.getOrCreateBalance(for: paymentType, in: context)
        if balance.balance.decimalValue < amountDecimal {
            alertMessage = "Insufficient funds in the selected payment method."
            showingAlert = true
            return
        }
        
        if selectedActor == nil {
            alertMessage = "Please select an actor."
            showingAlert = true
            return
        }
        
        // Create the transaction
        _ = TransactionModel.createExpense(
            amount: amountDecimal,
            summary: summary,
            actor: selectedActor!,
            paymentType: paymentType,
            context: context
        )
        
        // Save context
        do {
            try context.save()
            // Go back to previous screen
            presentationMode.wrappedValue.dismiss()
        } catch {
            alertMessage = "Failed to save expense: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    ExpenseView(path: .constant([]))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
