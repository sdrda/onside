//
//  SettingsView.swift
//  Onside
//
//  Created by Šimon Drda on 08.03.2026.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: ConnectedPlayersView()) {
                    Label("Connected Players", systemImage: "person.2.fill")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
