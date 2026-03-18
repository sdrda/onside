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
    
    @ObservationIgnored
    private let dataProcessor: DataProcessor
    private let positionScale: Float = 0.01
    
    init(dataProcessor: DataProcessor) {
        self.dataProcessor = dataProcessor
        startListening()
    }
    
    private func startListening() {
        Task { [weak self] in
            guard let self else { return }
            let stream = dataProcessor.positions
            for await position in stream {
                guard !Task.isCancelled else { break }
                let scaled = SIMD3<Float>(
                    Float(position.x) * positionScale,
                    0,
                    Float(position.y) * positionScale
                )
                playerPositions[position.id] = scaled
                if playerIDs.insert(position.id).inserted {
                    playerCount = playerIDs.count
                }
            }
        }
    }
}
