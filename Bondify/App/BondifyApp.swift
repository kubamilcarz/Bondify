//
//  BondifyApp.swift
//  Bondify
//
//  Created by Kuba Milcarz on 5/21/24.
//

import SwiftUI

@main
struct BondifyApp: App {
    
    let persistence = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
