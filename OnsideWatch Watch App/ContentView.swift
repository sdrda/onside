//
//  ContentView.swift
//  OnsideWatch Watch App
//
//  Created by Šimon Drda on 08.03.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var session = WatchSessionManager.shared

    var body: some View {
        List(session.players) { player in
            VStack(alignment: .leading) {
                Text("Hráč #\(player.id)")
                    .font(.headline)
                Text(String(format: "x: %.1f  y: %.1f", player.x, player.y))
                Text(String(format: "rychlost: %.1f m/s", player.speed))
                    .foregroundStyle(.secondary)
            }
        }
        .overlay {
            if session.players.isEmpty {
                Text("Čekám na data...")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
}
