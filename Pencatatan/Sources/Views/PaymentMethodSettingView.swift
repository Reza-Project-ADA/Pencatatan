//
//  PaymentMethodSettingView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//


import SwiftUI
import CoreData

struct PaymentMethodSettingView: View {
    @Binding var path: [Screen]
    var body: some View {
        GenericSettingsView<PaymentTypeModel>(
            entityName: "PaymentTypeModel",
            entityTitle: "Payment Type",
            entityDescription: "Payment Type",
            fieldConfigurations: [
                (field: "name", label: "Method Name", placeholder: "Enter method name"),
                (field: "initialBalance", label: "Initial Balance", placeholder: "0.00")
            ],
            softDeleteEnabled: true
        )
    }
}
