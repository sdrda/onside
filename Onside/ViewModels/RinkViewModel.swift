//
//  RinkViewModel.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI
import SwiftData

@Observable
@MainActor
final class RinkViewModel {
    private(set) var playerIDs: Set<UInt8> = []
    
    // Aktuální pozice hráčů
    private(set) var playerPositions: [UInt8: SIMD3<Float>] = [:]
    
    private(set) var isRecording: Bool = false
    private(set) var recordedPositionCounts: [UInt8: Int] = [:]

    /// Popisek na válci — číslo dresu pokud hráč existuje v DB
    var playerLabels: [UInt8: String] = [:]
    /// ID aktivních skupin
    var activeGroupIDs: Set<PersistentIdentifier> = []
    
    let playback: PlaybackController
     
    @ObservationIgnored private let modelContext: ModelContext
    @ObservationIgnored private let dataProcessor: any DataProcessorProtocol
    @ObservationIgnored private let sessionStorage: any SessionStorageProtocol
    
    @ObservationIgnored private var listeningTask: Task<Void, Never>? = nil
    
    private let positionScale: Float = 0.01
    
    var playerCount: Int {
        playerIDs.count
    }
    
    init(modelContext: ModelContext, dataProcessor: any DataProcessorProtocol, sessionStorage: any SessionStorageProtocol) {
        self.modelContext = modelContext
        self.dataProcessor = dataProcessor
        self.sessionStorage = sessionStorage
        self.playback = PlaybackController(sessionStorage: sessionStorage)
        Task { await dataProcessor.connect() }
        startListening()
        setupPlaybackCallback()
    }
    
    func toggleRecording() {
        Task {
            if isRecording {
                await sessionStorage.stopRecording()
                await playback.loadTimeRange()
            } else {
                playback.stop()
                await sessionStorage.startRecording()
            }
            isRecording = await sessionStorage.isRecording()
            recordedPositionCounts = isRecording ? await sessionStorage.positionCounts() : [:]
        }
    }
    
    func getCurrentPlayers() -> [UInt8] {
        playerIDs.sorted()
    }
    
    // MARK: - Groups
    
    func fetchGroups() -> [PlayerGroup] {
        let descriptor = FetchDescriptor<PlayerGroup>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func toggleGroup(_ group: PlayerGroup) {
        if activeGroupIDs.contains(group.persistentModelID) {
            activeGroupIDs.remove(group.persistentModelID)
        } else {
            activeGroupIDs.insert(group.persistentModelID)
        }
    }
    
    func isGroupActive(_ group: PlayerGroup) -> Bool {
        activeGroupIDs.contains(group.persistentModelID)
    }
    
    // MARK: - Private
    
    private func setupPlaybackCallback() {
        playback.onPositionsChanged = { [weak self] positions in
            guard let self else { return }
            var newPositions: [UInt8: SIMD3<Float>] = [:]
            var ids: Set<UInt8> = []
            for (id, pos) in positions {
                newPositions[id] = pos.scaledPosition(scale: self.positionScale)
                ids.insert(id)
            }
            self.playerPositions = newPositions
            self.playerIDs = ids
        }
    }
    
    private func startListening() {
        listeningTask = Task { [weak self] in
            guard let self else { return }
            
            let stream = self.dataProcessor.positions

            // Odbavujeme asynchronní stream pozičních dat
            for await position in stream {
                guard !Task.isCancelled else { break }
                
                // V režimu replay ignorujeme živá data
                guard !self.playback.isActive else { continue }
                
                self.playerPositions[position.id] = position.scaledPosition(scale: self.positionScale)
                
                self.playerIDs.insert(position.id)
            }
        }
    }
    
    // Při zániku zavřeme asynchronní úkol
    deinit {
        listeningTask?.cancel()
    }
}
