//
//  ProfileSettingView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//
import SwiftUI
import CoreData

// Example of how to use the generic view for specific entities
struct ProfileSettingView: View {
    @Binding var path: [Screen]
    var body: some View {
        GenericSettingsView<ActorModel>(
            entityName: "ActorModel",
            entityTitle: "Profiles",
            entityDescription: "Profile",
            fieldConfigurations: [
                (field: "name", label: "Profile Name", placeholder: "Enter profile name")
                // Add more fields as needed
            ]
        )
    }
}
