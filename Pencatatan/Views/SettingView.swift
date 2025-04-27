//
//  SettingView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Settings")) {
                        NavigationLink {
                            ProfileSettingView()
                        } label: {
                            Text("Profile")
                        }
                        NavigationLink {
                            PaymentMethodSettingView()
                                .environment(\.managedObjectContext, context)
                        } label: {
                            Text("Payment Method")
                        }
                        Text("Friends")
                        NavigationLink {
                            ItemCategorySettingView()
                                .environment(\.managedObjectContext, context)
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
}

#Preview {
    SettingView()
}
