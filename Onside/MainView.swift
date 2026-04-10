//
//  MainView.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    let container: AppContainer
    @State private var rinkViewModel: RinkViewModel?
    @State private var selectedTab: AppTab = .rink
    
    var body: some View {
        Group {
            if let rinkViewModel {
                TabView(selection: $selectedTab) {
                    RinkView(rink: rinkViewModel, config: container.rinkConfiguration)
                        .tabItem {
                            Label("Hřiště", systemImage: "sportscourt")
                        }
                        .tag(AppTab.rink)
                    
                    PlayerListView()
                        .tabItem {
                            Label("Hráči", systemImage: "person")
                        }
                        .tag(AppTab.players)
                    
                    GroupListView()
                        .tabItem {
                            Label("Skupiny", systemImage: "person.3")
                        }
                        .tag(AppTab.groups)
                    
                    Text("Nastavení")
                        .tabItem {
                            Label("Nastavení", systemImage: "gearshape")
                        }
                        .tag(AppTab.settings)
                }
                .tabViewStyle(.sidebarAdaptable)
                .focusedSceneValue(\.selectedTab, $selectedTab)
            }
        }
        .onAppear {
            if rinkViewModel == nil {
                rinkViewModel = container.makeRinkViewModel(modelContext: modelContext)
            }
        }
    }
}
