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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ConnectedPlayerModel.self)
    }
}
