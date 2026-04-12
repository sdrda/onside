//
//  PlayersInspector.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

import SwiftUI

struct PlayersInspector: View {
    var playerIDs: [UInt8]
    var playerLabels: [UInt8: String] = [:]
    var playerSpeed: [UInt8: Float] = [:]
    
    var body: some View {
        List {
            Section(header: Text("Aktivní hráči (\(playerIDs.count))")) {
                ForEach(playerIDs, id: \.self) { playerID in
                    HStack {
                        let label = playerLabels[playerID].map { "#\($0)" } ?? "ID \(playerID)"
                        Text(label)
                            .font(.headline)
                        Spacer()
                        if let speed = playerSpeed[playerID] {
                            Text(String(format: "%.1f m/s", speed))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
