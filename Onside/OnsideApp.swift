//
//  OnsideApp.swift
//  Onside
//
//  Created by Šimon Drda on 06.02.2026.
//

import SwiftUI

@main
struct OnsideApp: App {
    private let container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.container, container)
                .onAppear { container.connect() }
        }
    }
}

private struct AppContainerKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue = AppContainer()
}

extension EnvironmentValues {
    var container: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}
