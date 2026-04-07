//
//  MainView.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI

struct MainView: View {
    
    let container: AppContainer
    @State private var rinkViewModel: RinkViewModel
    
    init(container: AppContainer) {
        self.container = container
        self._rinkViewModel = State(wrappedValue: container.makeRinkViewModel())
    }
    
    var body: some View {
        TabView {
            Tab("Hřiště", systemImage: "sportscourt") {
                RinkView(rink: rinkViewModel, config: container.rinkConfiguration)
            }
            Tab("Hráči", systemImage: "person") {
                PlayerListView()
            }
            Tab("Skupiny", systemImage: "person.3") {
                GroupListView()
            }
            Tab("Nastavení", systemImage: "gearshape") {
                PlayerListView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}
