//
//  PersistenceController.swift
//  Expenses
//
//  Created by Dominik Horký on 22.01.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Expenses") // Musí se shodovat s názvem .xcdatamodeld souboru
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Nepodařilo se načíst úložiště: \(error.localizedDescription)")
            }
        }
    }
}
