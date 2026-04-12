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
    @State var isExporting: Bool = false
    @State var viewModel: RinkViewModel
    
    @State var onsideDocument: OnsideDocument? = nil
    let config: any RinkConfiguration
    
    private var playback: PlaybackController { viewModel.playback }

    var body: some View {
        NavigationStack {
            ZStack {
                RealityRinkView(isDrawing: $isDrawing, rinkViewModel: viewModel, config: config)
                
                VStack {
                    Spacer()

                    HStack(alignment: .bottom) {
                        
                        if !isDrawing {
                            Button {
                                viewModel.toggleRecording()
                            } label: {
                                Label(
                                    viewModel.isRecording ? "Zastavit" : "Nahrávat",
                                    systemImage: viewModel.isRecording ? "stop.circle.fill" : "record.circle"
                                )
                                .font(.headline)
                            }
                            .buttonStyle(.glass)
                            .tint(viewModel.isRecording ? .orange : .white)
                        }
                        
                        if !viewModel.isRecording && playback.timeRange != nil {
                            Button {
                                Task {
                                    let data = await viewModel.getDataForExport()
                                    
                                    self.onsideDocument = OnsideDocument(session: data)
                                    
                                    isExporting = true
                                }
                            } label: {
                                Label("Uložit", systemImage: "square.and.arrow.down")
                                    .font(.headline)
                            }
                            .buttonStyle(.glass)
                        }
                        
                        // Tlačítko pro vstup do replay po záznamu
                        if !viewModel.isRecording && playback.timeRange != nil && !playback.isActive {
                            Button {
                                playback.enter()
                            } label: {
                                Label("Přehrát", systemImage: "play.circle.fill")
                                    .font(.headline)
                            }
                            .buttonStyle(.glass)
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
                    
                    
                    // Playback ovládání
                    if playback.isActive {
                        PlaybackControls(playback: playback)
                            .padding(.horizontal)
                            .padding(.bottom, 4)
                    }
                    
                }
            }
            .inspector(isPresented: $inspectorPresented) {
                PlayersInspector(
                    playerIDs: viewModel.getCurrentPlayers(),
                    playerLabels: viewModel.playerLabels,
                    playerSpeed: viewModel.playerSpeed
                )
                .inspectorColumnWidth(min: 200, ideal: 300, max: 400)
            }
            .toolbar {
                RinkViewToolbar(isDrawing: $isDrawing, inspectorPresented: $inspectorPresented, viewModel: viewModel)
            }
            .focusedSceneValue(\.isDrawingBinding, $isDrawing)
            .fileExporter(
                isPresented: $isExporting,
                document: onsideDocument,
                contentType: .onside,
                defaultFilename: "Zaznam_Treninku"
            ) { result in

            }
        }
    }
}
