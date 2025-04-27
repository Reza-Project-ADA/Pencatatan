//
//  ContentView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 26/04/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTabIndex = 0
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            HomeView()
                .tabItem {
                    Label("Record", systemImage: "dollarsign")
                }
                .tag(0)
            Text("Budgeting")
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

#Preview {
    ContentView()
}
