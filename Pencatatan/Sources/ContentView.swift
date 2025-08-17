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
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            HomeView()
                .tabItem {
                    Label("Record", systemImage: "dollarsign")
                }
                .tag(0)

            
            
            BudgetingView()
                .tabItem {
                    Label("Budgeting", systemImage: "banknote.fill")
                }
                .tag(1)
            
            SettingView()
                .tabItem {
                    Label("Setting", systemImage: "gear")
                }
                .tag(2)
        }
    }
}


enum Screen: Hashable {
    case profileSetting
    case paymentMethodSetting
    case itemCategorySetting
    case periodSetting
    case addTransaction
    case income
    case expense
    case transfer
    case balanceReconciliation
}

#Preview {
    ContentView()
}
