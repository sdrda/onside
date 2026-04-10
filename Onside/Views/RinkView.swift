//
//  RinkView.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI
import SwiftData

struct RinkView: View {
    @State var inspectorPresented: Bool = false
    @State var isDrawing: Bool = false
    @State var rink: RinkViewModel
    let config: any RinkConfiguration
    
    private var playback: PlaybackController { rink.playback }

    var body: some View {
        NavigationStack {
            ZStack {
                RealityRinkView(isDrawing: $isDrawing, rinkViewModel: rink, config: config)
                
                VStack {
                    Spacer()
                    
                    // Playback ovládání
                    if playback.isActive {
                        playbackControls
                            .padding(.horizontal)
                            .padding(.bottom, 4)
                    }
                    
                    HStack(alignment: .bottom) {
                        Button {
                            rink.toggleRecording()
                        } label: {
                            Label(
                                rink.isRecording ? "Zastavit" : "Nahrávat",
                                systemImage: rink.isRecording ? "stop.circle.fill" : "record.circle"
                            )
                            .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(rink.isRecording ? .red : .blue)
                        
                        // Tlačítko pro vstup do replay po záznamu
                        if !rink.isRecording && playback.timeRange != nil && !playback.isActive {
                            Button {
                                playback.enter()
                            } label: {
                                Label("Přehrát", systemImage: "play.circle.fill")
                                    .font(.headline)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        }
                        
                        // Tlačítko pro ukončení replay
                        if playback.isActive {
                            Button {
                                playback.stop()
                            } label: {
                                Label("Živě", systemImage: "antenna.radiowaves.left.and.right")
                                    .font(.headline)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    }
                    .padding()
                }
            }
            .inspector(isPresented: $inspectorPresented) {
                VStack {
                    List {
                        Section(header: Text("Aktivní hráči (\(rink.playerCount))")) {
                            ForEach(rink.getCurrentPlayers(), id: \.self) { playerID in
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.blue)
                                    
                                    Text("Hráč ID: \(playerID)")
                                        .font(.headline)
                                }
                            }
                        }
                    }
                }
                .inspectorColumnWidth(min: 200, ideal: 300, max: 400)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isDrawing.toggle()
                    } label: {
                        Label(
                            isDrawing ? "Nekreslit" : "Kreslit",
                            systemImage: isDrawing ? "pencil.slash" : "pencil"
                        )
                        .contentTransition(.symbolEffect(.replace))
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        let groups = rink.fetchGroups()
                        if groups.isEmpty {
                            Text("Žádné skupiny")
                        } else {
                            ForEach(groups, id: \.persistentModelID) { group in
                                Button {
                                    rink.toggleGroup(group)
                                } label: {
                                    Label(
                                        group.name,
                                        systemImage: rink.isGroupActive(group)
                                            ? "checkmark.circle.fill"
                                            : "circle"
                                    )
                                }
                            }
                        }
                    } label: {
                        Label("Skupiny", systemImage: "person.3")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            inspectorPresented.toggle()
                        }
                    } label: {
                        Label(
                            inspectorPresented ? "Zavřít" : "Detail hráčů",
                            systemImage: inspectorPresented ? "xmark.circle.fill" : "person.circle"
                        )
                        .symbolVariant(.fill)
                        .contentTransition(.symbolEffect(.replace))
                    }
                }
            }
            .focusedSceneValue(\.isDrawingBinding, $isDrawing)
        }
    }
    
    // MARK: - Playback UI
    
    private var playbackControls: some View {
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
