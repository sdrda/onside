//
//  RinkView.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI

struct RinkView: View {
    @State var rink: RinkViewModel
    let config: any RinkConfiguration

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                Text("Players: \(rink.playerCount)")
                RealityRinkView(rinkViewModel: rink, config: config)
            }

            HStack(alignment: .bottom, spacing: 8) {
                if rink.isRecording {
                    VStack(alignment: .trailing, spacing: 2) {
                        ForEach(rink.recordedPositionCounts.sorted(by: { $0.key < $1.key }), id: \.key) { playerId, count in
                            Text("#\(playerId): \(count)")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.white)
                        }
                    }
                }

                RecordButton(isRecording: rink.isRecording) {
                    rink.toggleRecording()
                }
            }
            .padding()
        }
    }
}
