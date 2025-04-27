//
//  ContentView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 26/04/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var path: [Screen] = []
    @State private var selectedTabIndex = 0
    @Environment(\.managedObjectContext) var context

    var body: some View {
        TabView(selection: $selectedTabIndex) {
            NavigationStack(path: $path) {
                HomeView(path: $path)
                    .tabItem {
                        Label("Record", systemImage: "dollarsign")
                    }
                    .tag(0)
                    .navigationDestination(for: Screen.self) { screen in
                        switch screen {
                        case .addTransaction:
                            AddTransactionView(path: $path)
                        // Handle other destinations as needed
                        case .income:
                            IncomeView(path: $path)
                                .environment(\.managedObjectContext, context)
                        case .expense:
                            ExpenseView(path: $path)
                                .environment(\.managedObjectContext, context)
                        case .transfer:
                            TransferView(path: $path)
                                .environment(\.managedObjectContext, context)
                        default:
                            EmptyView() // Handle other screen cases if needed
                        }
                    }
            }

            BudgetingView()
                .tabItem {
                    Label("Budgeting", systemImage: "banknote.fill")
                }
                .tag(1)

            NavigationStack(path: $path) {
                SettingView(path: $path)
                    .tabItem {
                        Label("Setting", systemImage: "gear")
                    }
                    .tag(2)
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
                        default:
                            EmptyView() // Handle other screen cases if needed
                        }
                    }
            }
        }
    }
}


enum Screen: Hashable {
    case profileSetting
    case paymentMethodSetting
    case itemCategorySetting
    case addTransaction
    case income
    case expense
    case transfer
}

#Preview {
    ContentView()
}
