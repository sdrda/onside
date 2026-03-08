//
//  ContentView.swift
//  Onside
//
//  Created by Šimon Drda on 06.02.2026.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Rink", systemImage: "hockey.puck") {
                RinkView()
            }

            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
}
