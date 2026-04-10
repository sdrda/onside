//
//  OnsideApp.swift
//  Onside
//
//  Created by Šimon Drda on 06.02.2026.
//

import SwiftUI
import SwiftData

@main
struct OnsideApp: App {
    private let container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            MainView(container: container)
                .modelContainer(for: [Player.self, PlayerGroup.self])
        }
        .commands {
            TabCommands()
            DrawingCommands()
        }
    }
}

