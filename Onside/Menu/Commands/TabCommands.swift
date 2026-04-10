//
//  TabCommands.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

import SwiftUI

struct TabCommands: Commands {
    @FocusedBinding(\.selectedTab) var selectedTab: AppTab?
    
    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Button("Plocha") {
                selectedTab = .rink
            }
            .keyboardShortcut("1", modifiers: .command)
            
            Button("Hráči") {
                selectedTab = .players
            }
            .keyboardShortcut("2", modifiers: .command)
            
            Button("Skupiny") {
                selectedTab = .groups
            }
            .keyboardShortcut("3", modifiers: .command)
            
            Button("Nastavení") {
                selectedTab = .settings
            }
            .keyboardShortcut("4", modifiers: .command)
        }
    }
}
