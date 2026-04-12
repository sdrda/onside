//
//  PlaybackControls.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

import SwiftUI

struct PlaybackControls: View {
    var playback: PlaybackController
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    playback.togglePlayback()
                } label: {
                    Image(systemName: playback.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.bordered)
                
                Slider(
                    value: Binding(
                        get: { playback.progress },
                        set: { playback.seek(to: $0) }
                    ),
                    in: 0...1
                )
                
                if let current = playback.currentTime {
                    Text(formatTime(current))
                        .monospacedDigit()
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
