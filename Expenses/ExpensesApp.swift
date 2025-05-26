//
//  ExpensesApp.swift
//  Expenses
//
//  Created by Dominik Horký on 22.01.2025.
//

import SwiftUI

@main
struct ExpensesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
