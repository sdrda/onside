//
//  ContentView.swift
//  Onside
//
//  Created by Šimon Drda on 06.02.2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State var viewModel: DataViewModel
    @State var loading: Bool = false
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var exportDocument: OnsideDocument?

    init() {
        self._viewModel = State(initialValue: DataViewModel())
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RealityRinkView(viewModel: viewModel)
                .onAppear { viewModel.startLiveTransfer() }
                .onDisappear {
                    do {
                        try viewModel.stopLiveTransfer()
                    }
                    catch {
                        print("Failed to stop live transfer: \(error)")
                    }
                }
            

            if loading {
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                ProgressView()
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(viewModel.playerIDs.sorted(), id: \.self) { (id: UInt8) in
                    HStack(spacing: 12) {
                        Text("Hráč \(id)")
                            .fontWeight(.semibold)
                        
                        Label(
                            String(format: "%.1f m/s", viewModel.currentSpeed(for: id)),
                            systemImage: "speedometer"
                        )

                        Label(
                            String(format: "%.0f m", viewModel.totalDistance(for: id)),
                            systemImage: "figure.run"
                        )
                    }
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        viewModel.selectedPlayerID == id
                            ? Color.orange.opacity(0.4)
                            : Color.clear,
                        in: RoundedRectangle(cornerRadius: 8)
                    )
                    .onTapGesture {
                        viewModel.selectedPlayerID = (viewModel.selectedPlayerID == id) ? nil : id
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("\(viewModel.recordedCount) positions")
                    .monospacedDigit()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                
                if viewModel.recordedCount > 0 && !viewModel.isRecording {
                    Button {
                        exportDocument = OnsideDocument(tracks: viewModel.tracks.values.map { $0.snapshot() })
                        isExporting = true
                    } label: {
                        Text("Uložit")
                    }
                    .fileExporter(
                        isPresented: $isExporting,
                        document: exportDocument,
                        contentType: .onside,
                        defaultFilename: "session"
                    ) { result in
                        switch result {
                        case .success(let url): print("Uloženo: \(url)")
                        case .failure(let error): print("Chyba: \(error)")
                        }
                        exportDocument = nil
                    }
                }
                
                Button {
                    isImporting = true
                } label: {
                    Text("Otevřít")
                }
                .fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.onside]
                ) { result in
                    if case .success(let url) = result {
                        viewModel.loadFromFile(url: url)
                    }
                }
                
                Button(viewModel.isRecording ? "Stop" : "Record") {
                    viewModel.isRecording ? viewModel.stopRecording() : viewModel.startRecording()
                }
                
                Button {
                    if viewModel.isReplaying {
                        viewModel.stopReplay()
                    } else {
                        viewModel.startReplay()
                    }
                } label: {
                    Text(viewModel.isReplaying ? "Zastavit replay" : "Replay")
                }
                .disabled(viewModel.recordedCount == 0)
                
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isRecording ? .red : .accentColor)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
