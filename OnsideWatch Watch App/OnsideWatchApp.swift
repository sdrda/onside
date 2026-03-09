//
//  OnsideWatchApp.swift
//  OnsideWatch Watch App
//
//  Created by Šimon Drda on 08.03.2026.
//

import SwiftUI

@main
struct OnsideWatch_Watch_AppApp: App {
    init() {
        _ = WatchSessionManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
