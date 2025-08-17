//
//  SettingView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//

import SwiftUI

struct SettingView: View {
    @State private var path: [Screen] = []
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        NavigationStack(path: $path) {
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
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .profileSetting:
                    ProfileSettingView(path: $path)
                        .environment(\.managedObjectContext, context)
                case .paymentMethodSetting:
                    PaymentMethodSettingView(path: $path)
                        .environment(\.managedObjectContext, context)
                case .itemCategorySetting:
                    ItemCategorySettingView(path: $path)
                        .environment(\.managedObjectContext, context)
                case .periodSetting:
                    PeriodSettingView(path: $path)
                        .environment(\.managedObjectContext, context)
                default:
                    EmptyView() // Handle other screen cases if needed
                }
            }
        }
    }
    
}

#Preview {
    SettingView()
}
