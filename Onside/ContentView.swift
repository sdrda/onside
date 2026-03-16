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
    @State private var isPlayerListExpanded = false

    init() {
        self._viewModel = State(initialValue: DataViewModel())
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                RealityRinkView(viewModel: viewModel)
                    .onAppear { viewModel.startLiveTransfer() }
                    .onDisappear {
                        do {
                            try viewModel.stopLiveTransfer()
                        } catch {
                            print("Failed to stop live transfer: \(error)")
                        }
                    }
                    .ignoresSafeArea(edges: .top)

                if loading {
                    Color.clear
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                    ProgressView()
                }

                if viewModel.isReplaying {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                        Text("REPLAY")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.red)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial, in: Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 8)
                    .padding(.trailing, 16)
                }

                if !viewModel.playerIDs.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Button {
                            withAnimation(.spring(duration: 0.25)) {
                                isPlayerListExpanded.toggle()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "person.2.fill")
                                    .font(.caption)
                                Text("\(viewModel.playerIDs.count)")
                                    .font(.caption.weight(.semibold))
                                Image(systemName: isPlayerListExpanded ? "chevron.up" : "chevron.down")
                                    .font(.caption2)
                            }
                            .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)

                        if isPlayerListExpanded {
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
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(
                                    viewModel.selectedPlayerID == id
                                        ? Color.orange.opacity(0.15)
                                        : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 6)
                                )
                                .onTapGesture {
                                    viewModel.selectedPlayerID = (viewModel.selectedPlayerID == id) ? nil : id
                                }
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
                }

                VStack(alignment: .trailing, spacing: 8) {
                    if viewModel.isRecording, let start = viewModel.recordingStartTime {
                        TimelineView(.periodic(from: start, by: 1)) { context in
                            let elapsed = Int(context.date.timeIntervalSince(start))
                            Text(String(format: "%02d:%02d", elapsed / 60, elapsed % 60))
                                .monospacedDigit()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        }
                    } else if let duration = viewModel.loadedFileDuration {
                        let secs = Int(duration)
                        Text(String(format: "%02d:%02d", secs / 60, secs % 60))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    } else if viewModel.recordedCount > 0, let duration = viewModel.recordingDuration {
                        let secs = Int(duration)
                        Text(String(format: "%02d:%02d", secs / 60, secs % 60))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }

                    if !viewModel.isRecording && viewModel.recordedCount > 0 {
                        Button {
                            if viewModel.isReplaying {
                                viewModel.stopReplay()
                            } else {
                                viewModel.startReplay()
                            }
                        } label: {
                            Label(
                                viewModel.isReplaying ? "Stop" : "Replay",
                                systemImage: viewModel.isReplaying ? "stop.fill" : "play.fill"
                            )
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.78, green: 1.0, blue: 0.0))
                    }
                }
                .padding()

                if let name = viewModel.loadedFileName {
                    HStack(spacing: 5) {
                        Image(systemName: "doc.fill")
                            .font(.caption2)
                        Text(name)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial, in: Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding()
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ZStack {
                    RecordButton(
                        isRecording: viewModel.isRecording,
                        isDisabled: viewModel.loadedFileName != nil
                    ) {
                        viewModel.isRecording ? viewModel.stopRecording() : viewModel.startRecording()
                    }

                    if viewModel.loadedFileName != nil {
                        Button {
                            viewModel.clearLoadedFile()
                        } label: {
                            Label("Live", systemImage: "antenna.radiowaves.left.and.right")
                                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(.red, in: Capsule())
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("Hřiště")
                            .font(.headline)
                        Circle()
                            .fill(viewModel.isReceivingData ? .green : .red)
                            .frame(width: 8, height: 8)
                    }
                }
                ToolbarItemGroup(placement: toolbarTrailingPlacement) {
                    if viewModel.recordedCount > 0 && !viewModel.isRecording {
                        Button {
                            exportDocument = OnsideDocument(tracks: viewModel.tracks.values.map { $0.snapshot() })
                            isExporting = true
                        } label: {
                            Label("Uložit", systemImage: "square.and.arrow.up")
                        }
                    }

                    Button {
                        isImporting = true
                    } label: {
                        Label("Otevřít", systemImage: "folder")
                    }
                }
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
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.onside]
            ) { result in
                if case .success(let url) = result {
                    viewModel.loadFromFile(url: url)
                }
            }
        }
    }

    private var toolbarTrailingPlacement: ToolbarItemPlacement {
#if os(iOS)
        .topBarTrailing
#else
        .automatic
#endif
    }
}

#Preview {
    ContentView()
}
