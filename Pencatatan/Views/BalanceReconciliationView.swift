//
//  BalanceReconciliationView.swift
//  Pencatatan
//
//  Created on 28/04/25.
//

import SwiftUI

struct BalanceReconciliationView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Binding var path: [Screen]

    
    @FetchRequest(
        entity: PaymentTypeModel.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
        predicate: NSPredicate(format: "deletedAt == nil")
    ) var paymentTypes: FetchedResults<PaymentTypeModel>
    
    @State private var selectedPaymentType: PaymentTypeModel?
    @State private var isReconciling = false
    @State private var showResultAlert = false
    @State private var reconciliationResult: (old: NSDecimalNumber, new: NSDecimalNumber)? = nil
    
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID") // Indonesian Rupiah
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Reconcile Balance")) {
                    Text("Select a payment method to reconcile its balance based on transaction history, or reconcile all balances at once.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Payment Method", selection: $selectedPaymentType) {
                        Text("Select Payment Method").tag(nil as PaymentTypeModel?)
                        ForEach(paymentTypes, id: \.self) { paymentType in
                            Text(paymentType.name).tag(paymentType as PaymentTypeModel?)
                        }
                    }
                    
                    Button("Reconcile Selected Balance") {
                        guard let paymentType = selectedPaymentType else { return }
                        reconcileBalance(for: paymentType)
                    }
                    .disabled(selectedPaymentType == nil || isReconciling)
                    
                    Button("Reconcile All Balances") {
                        reconcileAllBalances()
                    }
                    .disabled(isReconciling)
                }
                
                Section(header: Text("Payment Balances")) {
                    if paymentTypes.isEmpty {
                        Text("No payment methods found")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(paymentTypes, id: \.self) { paymentType in
                            PaymentBalanceRow(paymentType: paymentType, formatter: currencyFormatter)
                        }
                    }
                }
            }
            .navigationTitle("Reconcile Balances")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reconciliation Complete", isPresented: $showResultAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let result = reconciliationResult {
                    Text("Previous balance: \(currencyFormatter.string(from: result.old) ?? "0")\nNew balance: \(currencyFormatter.string(from: result.new) ?? "0")")
                } else {
                    Text("All balances have been reconciled.")
                }
            }
            .disabled(isReconciling)
            .overlay {
                if isReconciling {
                    ProgressView("Reconciling...")
                        .padding()
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func reconcileBalance(for paymentType: PaymentTypeModel) {
        isReconciling = true
        
        // Get current balance for comparison
        let currentBalance = PaymentBalanceModel.getOrCreateBalance(for: paymentType, in: context).balance
        
        // Use background task for better UI responsiveness
        Task {
            let newBalance = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    let reconciled = BalanceReconciliationService.reconcileBalance(for: paymentType, in: context)
                    continuation.resume(returning: reconciled)
                }
            }
            
            // Update UI on main thread
            await MainActor.run {
                reconciliationResult = (old: currentBalance, new: newBalance)
                isReconciling = false
                showResultAlert = true
            }
        }
    }
    
    private func reconcileAllBalances() {
        isReconciling = true
        
        // Use background task for better UI responsiveness
        Task {
            await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    BalanceReconciliationService.reconcileAllBalances(in: context)
                    continuation.resume(returning: ())
                }
            }
            
            // Update UI on main thread
            await MainActor.run {
                reconciliationResult = nil
                isReconciling = false
                showResultAlert = true
            }
        }
    }
}

struct PaymentBalanceRow: View {
    let paymentType: PaymentTypeModel
    let formatter: NumberFormatter
    
    @FetchRequest var balance: FetchedResults<PaymentBalanceModel>
    
    init(paymentType: PaymentTypeModel, formatter: NumberFormatter) {
        self.paymentType = paymentType
        self.formatter = formatter
        
        // Create a fetch request for this specific payment type's balance
        let request = FetchRequest<PaymentBalanceModel>(
            entity: PaymentBalanceModel.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "paymentType == %@", paymentType)
        )
        self._balance = request
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(paymentType.name)
                    .font(.headline)
                
                if let lastUpdated = balance.first?.lastUpdated {
                    Text("Last updated: \(formattedDate(lastUpdated))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let balanceAmount = balance.first?.balance {
                Text(formatter.string(from: balanceAmount) ?? "Rp 0")
                    .fontWeight(.medium)
                    .foregroundColor(balanceAmount.decimalValue >= 0 ? .green : .red)
            } else {
                Text("Not set")
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    BalanceReconciliationView(path: .constant([]))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
