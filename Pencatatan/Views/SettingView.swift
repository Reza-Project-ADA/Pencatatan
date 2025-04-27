//
//  SettingView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import SwiftUI

struct SettingView: View {
    @Binding var path: [Screen]
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Settings")) {
                    Button {
                        path.append(.profileSetting)
                    } label: {
                        Text("Profile")
                    }
                    Button {
                        path.append(.paymentMethodSetting)
                    } label: {
                        Text("Payment Method")
                    }
                    Text("Friends")
                    Button {
                        path.append(.itemCategorySetting)
                    } label: {
                        Text("Item Categories")
                    }
                }
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    
                }
            }
        }
    }
    
}

#Preview {
    SettingView(path: .constant([]))
}
