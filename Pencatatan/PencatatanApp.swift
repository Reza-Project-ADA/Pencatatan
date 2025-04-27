//
//  PencatatanApp.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 26/04/25.
//

import SwiftUI

@main
struct PencatatanApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
