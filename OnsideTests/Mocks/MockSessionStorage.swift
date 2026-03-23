//
//  MockSessionStorage.swift
//  OnsideTests
//

import Foundation
@testable import Onside

actor MockSessionStorage: SessionStorageProtocol {
    private var positions: [PlayerPosition] = []
    private var recording = false

    func appendPosition(position: PlayerPosition) {
        positions.append(position)
    }

    func startRecording() {
        recording = true
    }

    func stopRecording() {
        recording = false
    }

    var playerTrackCount: Int {
        Set(positions.map(\.id)).count
    }

    func isRecording() -> Bool {
        recording
    }

    func positionCounts() -> [UInt8: Int] {
        Dictionary(grouping: positions, by: \.id).mapValues(\.count)
    }

    func playerIDs() -> [UInt8] {
        Array(Set(positions.map(\.id))).sorted()
    }

    func heatmapPoints(for playerID: UInt8) -> [(x: CGFloat, y: CGFloat)] {
        positions.filter { $0.id == playerID }.map { (x: $0.x, y: $0.y) }
    }

    // MARK: - Test helpers

    func allPositions() -> [PlayerPosition] {
        positions
    }
}
