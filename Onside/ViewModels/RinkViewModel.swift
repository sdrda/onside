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
        Task { await dataProcessor.connect() }
        startListening()
    }
    
    func toggleRecording() {
        Task {
            if isRecording {
                await sessionStorage.stopRecording()
                liveActivityManager.stopLiveActivity()
            } else {
                await sessionStorage.startRecording()
                liveActivityManager.startLiveActivity(startDate: Date())
            }
            isRecording = await sessionStorage.isRecording()
            recordedPositionCounts = isRecording ? await sessionStorage.positionCounts() : [:]
        }
    }
    
    private func startListening() {
        Task { [weak self] in
            guard let self else { return }
            let stream = dataProcessor.positions
            for await position in stream {
                guard !Task.isCancelled else { break }
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
