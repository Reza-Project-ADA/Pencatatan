//
//  HomeViewModel.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 28/04/25.
//
import Foundation

class HomeViewModel: ObservableObject {
    @Published var showReconcileAlert = false
    @Published  var isReconciling = false
    @Published var reconciliationResult: (old: NSDecimalNumber, new: NSDecimalNumber)? = nil
}
