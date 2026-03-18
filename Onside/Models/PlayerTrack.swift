//
//  PlayerTrack.swift
//  Onside
//
//  Created by Šimon Drda on 12.03.2026.
//

import Foundation
import CoreGraphics

struct SerializedTrack: Codable {
    let playerID: UInt8
    let positions: [PlayerPosition]
    let totalDistance: Double
    let currentSpeed: Double
    let averageSpeed: Double
    let speedSum: Double
    let speedCount: Int
}

struct PlayerTrack {
    let playerID: UInt8
    private(set) var positions: [PlayerPosition] = []
    
    init(playerID: UInt8) {
        self.playerID = playerID
    }

    private(set) var totalDistance: Double = 0
    private(set) var currentSpeed: Double = 0
    private(set) var averageSpeed: Double = 0
    private var speedSum: Double = 0
    private var speedCount: Int = 0

    mutating func append(_ position: PlayerPosition) {
        if let last = positions.last {
            let dx = Double(position.x - last.x)
            let dy = Double(position.y - last.y)
            let dist = (dx * dx + dy * dy).squareRoot()
            let dt = position.timestamp.timeIntervalSince(last.timestamp)

            totalDistance += dist

            if dt > 0 {
                let speed = dist / dt
                currentSpeed = speed
                speedSum += speed
                speedCount += 1
                averageSpeed = speedSum / Double(speedCount)
            }
        }
        positions.append(position)
    }

    // Pro Metal heatmapu – přímý přístup
    var heatmapPoints: [(x: CGFloat, y: CGFloat)] {
        positions.map { ($0.x, $0.y) }
    }

    // Pro replay – pozice nejbližší danému timestampu
    func position(at timestamp: Date) -> PlayerPosition? {
        guard !positions.isEmpty else { return nil }
        // Binary search
        var lo = positions.startIndex
        var hi = positions.endIndex - 1
        while lo < hi {
            let mid = (lo + hi) / 2
            if positions[mid].timestamp < timestamp {
                lo = mid + 1
            } else {
                hi = mid
            }
        }
        return positions[lo]
    }
    
    func snapshot() -> SerializedTrack {
        SerializedTrack(
            playerID: playerID,
            positions: positions,
            totalDistance: totalDistance,
            currentSpeed: currentSpeed,
            averageSpeed: averageSpeed,
            speedSum: speedSum,
            speedCount: speedCount
        )
    }

    static func restore(from snapshot: SerializedTrack) -> PlayerTrack {
        var track = PlayerTrack(playerID: snapshot.playerID)
        track.positions = snapshot.positions
        track.totalDistance = snapshot.totalDistance
        track.currentSpeed = snapshot.currentSpeed
        track.averageSpeed = snapshot.averageSpeed
        track.speedSum = snapshot.speedSum
        track.speedCount = snapshot.speedCount
        return track
    }
}
