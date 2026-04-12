//
//  MainView.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI

struct MainView: View {
    let container: AppContainer
    @State private var rinkViewModel: RinkViewModel?
    @State private var selectedTab: AppTab = .rink
    
    init(container: AppContainer) {
        self.container = container
        _rinkViewModel = State(initialValue: container.makeRinkViewModel())
    }
    
    var body: some View {
        Group {
            if let rinkViewModel {
                TabView(selection: $selectedTab) {
                    RinkView(viewModel: rinkViewModel, config: container.rinkConfiguration)
                        .tabItem {
                            Label(.rink, systemImage: "sportscourt")
                        }
                        .tag(AppTab.rink)
                    
                    PlayerListView()
                        .tabItem {
                            Label(.players, systemImage: "person")
                        }
                        .tag(AppTab.players)
                    
                    GroupListView()
                        .tabItem {
                            Label(.groups, systemImage: "person.3")
                        }
                        .tag(AppTab.groups)
                    
                    SettingsView()
                        .tabItem {
                            Label("Nastavení", systemImage: "gearshape")
                        }
                        .tag(AppTab.settings)
                }
                .tabViewStyle(.sidebarAdaptable)
                .focusedSceneValue(\.selectedTab, $selectedTab)
                .tint(.orange)
            }
        }
    }
}
