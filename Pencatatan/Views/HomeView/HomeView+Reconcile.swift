//
//  HomeView+Reconcile.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 28/04/25.
//
import SwiftUI

extension HomeView {
    internal func reconcileAllBalances(withAlert: Bool = true) {
        viewModel.isReconciling = true
        
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
                viewModel.reconciliationResult = nil
                viewModel.isReconciling = false
                viewModel.showReconcileAlert = withAlert
            }
        }
    }
    internal func reconcileBalance(for paymentType: PaymentTypeModel, withAlert: Bool = true) {
        viewModel.isReconciling = true
        
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
                viewModel.reconciliationResult = (old: currentBalance, new: newBalance)
                viewModel.isReconciling = false
                viewModel.showReconcileAlert = true
            }
        }
    }
}
