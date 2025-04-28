//
//  BalanceReconciliationService.swift
//  Pencatatan
//
//  Created on 28/04/25.
//

import Foundation
import CoreData

class BalanceReconciliationService {
    /// Reconciles the balance for a specific payment type by recalculating from transaction history
    static func reconcileBalance(for paymentType: PaymentTypeModel, in context: NSManagedObjectContext) -> NSDecimalNumber {
        // Fetch all transactions for this payment type
        let request = NSFetchRequest<TransactionModel>(entityName: "TransactionModel")
        request.predicate = NSPredicate(format: "paymentType == %@ OR destinationPaymentType == %@", paymentType, paymentType)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        guard let transactions = try? context.fetch(request) else {
            print("Error fetching transactions for reconciliation")
            return NSDecimalNumber.zero
        }
        
        // Recalculate balance from scratch
        var calculatedBalance = NSDecimalNumber.zero
        
        for transaction in transactions {
            switch transaction.transactionType {
            case "income":
                if transaction.paymentType == paymentType {
                    calculatedBalance = calculatedBalance.adding(transaction.amount)
                }
                
            case "expense":
                if transaction.paymentType == paymentType {
                    calculatedBalance = calculatedBalance.subtracting(transaction.amount)
                }
                
            case "transfer":
                if transaction.paymentType == paymentType {
                    // Money going out from this payment type
                    calculatedBalance = calculatedBalance.subtracting(transaction.amount)
                }
                if transaction.destinationPaymentType == paymentType {
                    // Money coming in to this payment type
                    calculatedBalance = calculatedBalance.adding(transaction.amount)
                }
                
            case "init":
                if transaction.paymentType == paymentType {
                    // Initial balance setting
                    calculatedBalance = transaction.amount
                }
                
            default:
                break
            }
        }
        
        // Update the balance record
        let balance = PaymentBalanceModel.getOrCreateBalance(for: paymentType, in: context)
        balance.balance = calculatedBalance
        balance.lastUpdated = Date()
        
        // Save the context
        do {
            try context.save()
            print("Balance reconciled successfully for \(paymentType.name): \(calculatedBalance)")
        } catch {
            print("Error saving reconciled balance: \(error.localizedDescription)")
        }
        
        return calculatedBalance
    }
    
    /// Reconciles balances for all payment types
    static func reconcileAllBalances(in context: NSManagedObjectContext) {
        // Fetch all payment types
        let request = NSFetchRequest<PaymentTypeModel>(entityName: "PaymentTypeModel")
        request.predicate = NSPredicate(format: "deletedAt == nil")
        
        guard let paymentTypes = try? context.fetch(request) else {
            print("Error fetching payment types for reconciliation")
            return
        }
        
        // Reconcile each payment type balance
        for paymentType in paymentTypes {
            _ = reconcileBalance(for: paymentType, in: context)
        }
    }
}
