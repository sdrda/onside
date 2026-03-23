//
//  RinkView.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI

struct RinkView: View {
    @Environment(\.container) private var container
    @State var rink: RinkViewModel
    let config: any RinkConfiguration

    var body: some View {
        ZStack {
            Color.white
            
            VStack {
                Text("Players: \(rink.playerCount)")
                RealityRinkView(rinkViewModel: rink, config: config)
            }

            VStack {
                Spacer()

                HStack(alignment: .bottom) {
                    NavigationLink(destination: AnalyticsView(viewModel: container.makeAnalyticsViewModel())) {
                        Text("Analýza")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.white, in: Capsule())
                    }
                    .buttonStyle(.plain)

                    Spacer()

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
                }
                .padding()
            }
        }
    }
}
