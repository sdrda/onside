//
//  MainView.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI

struct MainView: View {
    
    @Environment(\.container) private var container
    @State private var rinkViewModel: RinkViewModel?
    
    var body: some View {
        TabView {
            Tab("Hřiště", systemImage: "sportscourt") {
                if let rinkViewModel {
                    RinkView(rink: rinkViewModel, config: container.rinkConfiguration)
                } else {
                    ProgressView()
                }
            }
            Tab("Hráči", systemImage: "person") {
                PairingView()
            }
            Tab("Skupiny", systemImage: "person.3") {
                PairingView()
            }
            Tab("Nastavení", systemImage: "gearshape") {
                PairingView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onAppear {
            if rinkViewModel == nil {
                rinkViewModel = container.makeRinkViewModel()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    static var previews: some View {
        MainView()
    }
}
