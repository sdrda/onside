//
//  MainView.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI
import PencilKit

struct MainView: View {
    
    @Environment(\.modelContext) private var modelContext
    let container: AppContainer
    @State private var rinkViewModel: RinkViewModel?
    
    var body: some View {
        Group {
            if let rinkViewModel {
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
        .onAppear {
            if rinkViewModel == nil {
                rinkViewModel = container.makeRinkViewModel(modelContext: modelContext)
            }
        }
    }
}
