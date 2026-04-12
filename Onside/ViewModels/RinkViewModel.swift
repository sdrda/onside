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
    
    /// ID aktivních skupin
    var activeGroupIDs: Set<PersistentIdentifier> = []
    
    var playerColors: [UInt8: Color] = [:]
    
    /// Popisky hráčů (sensorId -> číslo dresu). Hráči bez záznamu v DB nemají záznam.
    var playerLabels: [UInt8: String] = [:]
    
    var playerSpeed: [UInt8: Float] = [:]
    
    let playback: PlaybackController
     
    @ObservationIgnored private let playerGroupRepository: any PlayerGroupRepositoryProtocol
    @ObservationIgnored private let playerRepository: any PlayerRepositoryProtocol
    @ObservationIgnored private let dataProcessor: any DataProcessorProtocol
    @ObservationIgnored private let sessionStorage: any SessionStorageProtocol
    
    @ObservationIgnored private var listeningTask: Task<Void, Never>? = nil
    @ObservationIgnored private var previousPositions: [UInt8: PlayerPosition] = [:]
    
    private let positionScale: Float = 0.01
    
    var playerCount: Int {
        playerIDs.count
    }
    
    init(playerGroupRepository: any PlayerGroupRepositoryProtocol, playerReopsitory: any PlayerRepositoryProtocol, dataProcessor: any DataProcessorProtocol, sessionStorage: any SessionStorageProtocol) {
        self.playerGroupRepository = playerGroupRepository
        self.playerRepository = playerReopsitory
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
        (try? playerGroupRepository.fetchGroups()) ?? []
    }
    
    func toggleGroup(_ group: PlayerGroup) {
        if activeGroupIDs.contains(group.persistentModelID) {
            activeGroupIDs.remove(group.persistentModelID)
        } else {
            activeGroupIDs.insert(group.persistentModelID)
        }
        rebuildPlayerColors()
    }
    
    func isGroupActive(_ group: PlayerGroup) -> Bool {
        activeGroupIDs.contains(group.persistentModelID)
    }
    
    /// Přepočítá barvy hráčů podle aktivních skupin
    private func rebuildPlayerColors() {
        var newColors: [UInt8: Color] = [:]
        
        let groups = (try? playerGroupRepository.fetchGroups()) ?? []
        
        for group in groups {
            guard activeGroupIDs.contains(group.persistentModelID) else { continue }
            let color = color(from: group.colorHex)
            for player in group.players ?? [] {
                newColors[UInt8(player.sensorId)] = color
            }
        }
        
        playerColors = newColors
    }
    
    /// Přepočítá popisky hráčů z DB (sensorId -> jerseyNumber)
    func rebuildPlayerLabels() {
        let descriptor = FetchDescriptor<Player>()
        
        guard let players = try? playerRepository.fetchPlayers() else {
            return
        }
        
        var labels: [UInt8: String] = [:]
        for player in players {
            labels[UInt8(player.sensorId)] = "\(player.jerseyNumber)"
        }
        playerLabels = labels
    }
    
    private func color(from hex: String?) -> Color {
        guard let hex, !hex.isEmpty else { return .orange }
        var rgb: UInt64 = 0
        Scanner(string: hex.replacingOccurrences(of: "#", with: "")).scanHexInt64(&rgb)
        return Color(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
    
    // MARK: - Private
    
    /// Vypočítá rychlost hráče v m/s z aktuální a předchozí pozice.
    private func updateSpeed(for position: PlayerPosition) {
        if let previous = previousPositions[position.id] {
            let dt = position.timestamp.timeIntervalSince(previous.timestamp)
            if dt > 0 {
                let dx = Float(position.x - previous.x)
                let dy = Float(position.y - previous.y)
                let distance = sqrt(dx * dx + dy * dy)
                playerSpeed[position.id] = distance / Float(dt)
            }
        }
        previousPositions[position.id] = position
    }
    
    private func setupPlaybackCallback() {
        playback.onPositionsChanged = { [weak self] positions in
            guard let self else { return }
            var newPositions: [UInt8: SIMD3<Float>] = [:]
            var ids: Set<UInt8> = []
            for (id, pos) in positions {
                newPositions[id] = pos.scaledPosition(scale: self.positionScale)
                ids.insert(id)
                self.updateSpeed(for: pos)
            }
            self.playerPositions = newPositions
            if ids != self.playerIDs {
                self.playerIDs = ids
                self.rebuildPlayerLabels()
            }
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
                self.updateSpeed(for: position)
                
                let isNew = self.playerIDs.insert(position.id).inserted
                if isNew {
                    self.rebuildPlayerLabels()
                }
            }
        }
    }
    
    
    func getDataForExport() async -> SessionData {
        await sessionStorage.getExportData()
    }
    
    // Při zániku zavřeme asynchronní úkol
    deinit {
        listeningTask?.cancel()
    }
}
