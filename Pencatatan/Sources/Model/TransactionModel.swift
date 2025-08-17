//
//  TransactionModel.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import Foundation
import CoreData

@objc(TransactionModel)
public class TransactionModel: NSManagedObject {
    @NSManaged public var actor: ActorModel
    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var transactionType: String // "income", "expense", "transfer", "init"
    @NSManaged public var summary: String?
    @NSManaged public var paymentType: PaymentTypeModel? // <- untuk relationship to-one
    @NSManaged public var destinationPaymentType: PaymentTypeModel? // Only for transfer transaction
    @NSManaged public var timestamp: Date
    @NSManaged public var transactionID: String
}

extension TransactionModel {
    /// Create a new income transaction
    static func createIncome(
        amount: Decimal,
        summary: String?,
        actor: ActorModel,
        paymentType: PaymentTypeModel,
        context: NSManagedObjectContext
    ) -> TransactionModel {
        let transaction = TransactionModel(context: context)
        transaction.amount = NSDecimalNumber(decimal: amount)
        transaction.transactionType = "income"
        transaction.summary = summary
        transaction.timestamp = Date()
        transaction.actor = actor
        transaction.paymentType = paymentType
        transaction.transactionID = UUID().uuidString
        
        // Update payment balance
        let balance = PaymentBalanceModel.getOrCreateBalance(for: paymentType, in: context)
        balance.updateBalance(amount: NSDecimalNumber(decimal: amount), transactionType: "income")
        
        return transaction
    }
    
    /// Create a new expense transaction
    static func createExpense(
        amount: Decimal,
        summary: String?,
        actor: ActorModel,
        paymentType: PaymentTypeModel,
        context: NSManagedObjectContext
    ) -> TransactionModel {
        let transaction = TransactionModel(context: context)
        transaction.amount = NSDecimalNumber(decimal: amount)
        transaction.transactionType = "expense"
        transaction.summary = summary
        transaction.timestamp = Date()
        transaction.actor = actor
        transaction.paymentType = paymentType
        transaction.transactionID = UUID().uuidString
        
        // Update payment balance
        let balance = PaymentBalanceModel.getOrCreateBalance(for: paymentType, in: context)
        balance.updateBalance(amount: NSDecimalNumber(decimal: amount), transactionType: "expense")
        
        return transaction
    }
    
    static func createInitialBalance(
        amount: NSDecimalNumber,
        paymentType: PaymentTypeModel,
        actor: ActorModel,
        context: NSManagedObjectContext
    ) -> TransactionModel {
        let transaction = TransactionModel(context: context)
        transaction.amount = amount
        transaction.transactionType = "init"
        transaction.timestamp = Date()
        transaction.actor = actor
        transaction.summary = "Initial balance"
        transaction.paymentType = paymentType
        transaction.transactionID = UUID().uuidString
        
        // Update payment balance
        let balance = PaymentBalanceModel.getOrCreateBalance(for: paymentType, in: context)
        balance.balance = amount
        balance.lastUpdated = Date()
        
        return transaction
    }
    
    /// Create a new transfer transaction
    static func createTransfer(
        amount: Decimal,
        summary: String?,
        actor: ActorModel,
        sourcePaymentType: PaymentTypeModel,
        destinationPaymentType: PaymentTypeModel,
        context: NSManagedObjectContext
    ) -> TransactionModel {
        let transaction = TransactionModel(context: context)
        transaction.amount = NSDecimalNumber(decimal: amount)
        transaction.transactionType = "transfer"
        transaction.summary = summary
        transaction.timestamp = Date()
        transaction.actor = actor
        transaction.paymentType = sourcePaymentType // Source
        transaction.destinationPaymentType = destinationPaymentType // Destination
        transaction.transactionID = UUID().uuidString
        
        // Update source payment balance
        let sourceBalance = PaymentBalanceModel.getOrCreateBalance(for: sourcePaymentType, in: context)
        sourceBalance.updateBalance(amount: NSDecimalNumber(decimal: amount), transactionType: "transfer_out")
        
        // Update destination payment balance
        let destBalance = PaymentBalanceModel.getOrCreateBalance(for: destinationPaymentType, in: context)
        destBalance.updateBalance(amount: NSDecimalNumber(decimal: amount), transactionType: "transfer_in")
        
        return transaction
    }
}
