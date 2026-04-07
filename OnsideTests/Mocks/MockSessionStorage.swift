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

    func timeRange() -> ClosedRange<Date>? {
        guard let first = positions.min(by: { $0.timestamp < $1.timestamp }),
              let last = positions.max(by: { $0.timestamp < $1.timestamp }),
              first.timestamp < last.timestamp else { return nil }
        return first.timestamp...last.timestamp
    }

    func positions(at timestamp: Date) -> [UInt8: PlayerPosition] {
        var result: [UInt8: PlayerPosition] = [:]
        let grouped = Dictionary(grouping: positions, by: \.id)
        for (id, posArr) in grouped {
            if let closest = posArr.min(by: { abs($0.timestamp.timeIntervalSince(timestamp)) < abs($1.timestamp.timeIntervalSince(timestamp)) }) {
                result[id] = closest
            }
        }
        return result
    }

    // MARK: - Test helpers

    func allPositions() -> [PlayerPosition] {
        positions
    }
}
