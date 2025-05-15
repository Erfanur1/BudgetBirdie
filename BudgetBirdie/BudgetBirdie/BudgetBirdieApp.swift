//
//  BudgetBirdieApp.swift
//  BudgetBirdie
//
//  Created by Erfanur on 15/5/2025.
//

import SwiftUI

@main
struct BudgetBirdieApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
