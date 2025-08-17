//
//  ItemCategoryView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import SwiftUI
import CoreData

struct ItemCategorySettingView: View {
    @Binding var path: [Screen]
    var body: some View {
        GenericSettingsView<ItemModelCategory>(
            entityName: "ItemModelCategory",
            entityTitle: "Item Category",
            entityDescription: "Item Cateogory",
            fieldConfigurations: [
                (field: "name", label: "Method Name", placeholder: "Enter method name"),
            ]
        )
    }
}
