//
//  RinkViewModel.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI

@Observable
@MainActor
final class RinkViewModel {
    private(set) var playerCount: Int = 0
    private(set) var playerIDs: Set<UInt8> = []
    private(set) var playerPositions: [UInt8: SIMD3<Float>] = [:]
    private(set) var isRecording: Bool = false
    private(set) var recordedPositionCounts: [UInt8: Int] = [:]
    
    /// Barva válce pro každého hráče podle aktivních skupin
    var playerColors: [UInt8: UIColor] = [:]
    /// Popisek na válci — číslo dresu pokud hráč existuje v DB
    var playerLabels: [UInt8: String] = [:]
    
    let playback: PlaybackController
    
    @ObservationIgnored
    private let dataProcessor: any DataProcessorProtocol
    @ObservationIgnored
    private let sessionStorage: any SessionStorageProtocol
    @ObservationIgnored
    private let liveActivityManager: LiveActivityManager
    private let positionScale: Float = 0.01
    
    init(dataProcessor: any DataProcessorProtocol, sessionStorage: any SessionStorageProtocol, liveActivityManager: LiveActivityManager) {
        self.dataProcessor = dataProcessor
        self.sessionStorage = sessionStorage
        self.liveActivityManager = liveActivityManager
        self.playback = PlaybackController(sessionStorage: sessionStorage)
        Task { await dataProcessor.connect() }
        startListening()
        setupPlaybackCallback()
    }
    
    func toggleRecording() {
        Task {
            if isRecording {
                await sessionStorage.stopRecording()
                liveActivityManager.stopLiveActivity()
                await playback.loadTimeRange()
            } else {
                playback.stop()
                await sessionStorage.startRecording()
                liveActivityManager.startLiveActivity(startDate: Date())
            }
            isRecording = await sessionStorage.isRecording()
            recordedPositionCounts = isRecording ? await sessionStorage.positionCounts() : [:]
        }
    }
    
    func getCurrentPlayers() -> [UInt8] {
        playerIDs.sorted()
    }
    
    // MARK: - Private
    
    private func setupPlaybackCallback() {
        playback.onPositionsChanged = { [weak self] positions in
            guard let self else { return }
            var newPositions: [UInt8: SIMD3<Float>] = [:]
            var ids: Set<UInt8> = []
            for (id, pos) in positions {
                let scaled = SIMD3<Float>(
                    Float(pos.x) * self.positionScale,
                    0.01,
                    Float(pos.y) * self.positionScale
                )
                newPositions[id] = scaled
                ids.insert(id)
            }
            self.playerPositions = newPositions
            self.playerIDs = ids
            self.playerCount = ids.count
        }
    }
    
    private func startListening() {
        Task { [weak self] in
            guard let self else { return }
            let stream = dataProcessor.positions
            for await position in stream {
                guard !Task.isCancelled else { break }
                // V režimu replay ignorujeme živá data
                guard !playback.isActive else { continue }
                let scaled = SIMD3<Float>(
                    Float(position.x) * positionScale,
                    0.01,
                    Float(position.y) * positionScale
                )
                playerPositions[position.id] = scaled
                if playerIDs.insert(position.id).inserted {
                    playerCount = playerIDs.count
                    if isRecording {
                        liveActivityManager.updatePlayerCount(playerCount)
                    }
                }
                if isRecording {
                    recordedPositionCounts = await sessionStorage.positionCounts()
                }
            }
        }
    }
}
