//
//  PlayerTrackTests.swift
//  OnsideTests
//

import Testing
import Foundation
@testable import Onside

struct PlayerTrackTests {

    private func makePosition(x: CGFloat, y: CGFloat, secondsOffset: TimeInterval = 0) -> PlayerPosition {
        PlayerPosition(id: 1, x: x, y: y, timestamp: Date(timeIntervalSince1970: secondsOffset))
    }

    // MARK: - Basic

    @Test func newTrackHasZeroPositions() {
        let track = PlayerTrack(playerID: 1)
        #expect(track.positions.isEmpty)
        #expect(track.totalDistance == 0)
        #expect(track.currentSpeed == 0)
        #expect(track.averageSpeed == 0)
    }

    @Test func appendFirstPositionDoesNotComputeDistance() {
        var track = PlayerTrack(playerID: 1)
        track.append(makePosition(x: 10, y: 5, secondsOffset: 0))

        #expect(track.positions.count == 1)
        #expect(track.totalDistance == 0)
    }

    // MARK: - Distance

    @Test func distanceComputedCorrectly() {
        var track = PlayerTrack(playerID: 1)
        track.append(makePosition(x: 0, y: 0, secondsOffset: 0))
        track.append(makePosition(x: 3, y: 4, secondsOffset: 1))

        // distance = sqrt(9 + 16) = 5.0
        #expect(abs(track.totalDistance - 5.0) < 0.001)
    }

    @Test func totalDistanceAccumulates() {
        var track = PlayerTrack(playerID: 1)
        track.append(makePosition(x: 0, y: 0, secondsOffset: 0))
        track.append(makePosition(x: 3, y: 4, secondsOffset: 1))
        track.append(makePosition(x: 3, y: 4 + 5, secondsOffset: 2))

        // 5 + 5 = 10
        #expect(abs(track.totalDistance - 10.0) < 0.001)
    }

    // MARK: - Speed

    @Test func speedComputedCorrectly() {
        var track = PlayerTrack(playerID: 1)
        track.append(makePosition(x: 0, y: 0, secondsOffset: 0))
        track.append(makePosition(x: 3, y: 4, secondsOffset: 1))

        // speed = distance / time = 5 / 1 = 5 m/s
        #expect(abs(track.currentSpeed - 5.0) < 0.001)
        #expect(abs(track.averageSpeed - 5.0) < 0.001)
    }

    @Test func averageSpeedOverMultipleSegments() {
        var track = PlayerTrack(playerID: 1)
        track.append(makePosition(x: 0, y: 0, secondsOffset: 0))
        track.append(makePosition(x: 3, y: 4, secondsOffset: 1))  // speed = 5
        track.append(makePosition(x: 3, y: 14, secondsOffset: 2)) // speed = 10

        // average = (5 + 10) / 2 = 7.5
        #expect(abs(track.averageSpeed - 7.5) < 0.001)
        #expect(abs(track.currentSpeed - 10.0) < 0.001)
    }

    // MARK: - Heatmap points

    @Test func heatmapPointsMatchPositions() {
        var track = PlayerTrack(playerID: 1)
        track.append(makePosition(x: 1.5, y: -2.3, secondsOffset: 0))
        track.append(makePosition(x: 10.0, y: 5.0, secondsOffset: 1))

        let points = track.heatmapPoints
        #expect(points.count == 2)
        #expect(points[0].x == 1.5)
        #expect(points[0].y == -2.3)
    }

    // MARK: - Position lookup

    @Test func positionAtTimestampReturnsClosest() {
        var track = PlayerTrack(playerID: 1)
        let t0 = Date(timeIntervalSince1970: 0)
        let t1 = Date(timeIntervalSince1970: 1)
        let t2 = Date(timeIntervalSince1970: 2)

        track.append(PlayerPosition(id: 1, x: 0, y: 0, timestamp: t0))
        track.append(PlayerPosition(id: 1, x: 5, y: 5, timestamp: t1))
        track.append(PlayerPosition(id: 1, x: 10, y: 10, timestamp: t2))

        let result = track.position(at: t1)
        #expect(result?.x == 5)
        #expect(result?.y == 5)
    }

    @Test func positionAtReturnsNilForEmptyTrack() {
        let track = PlayerTrack(playerID: 1)
        let result = track.position(at: .now)
        #expect(result == nil)
    }

    // MARK: - Serialization

    @Test func snapshotAndRestorePreservesData() {
        var track = PlayerTrack(playerID: 7)
        track.append(makePosition(x: 1, y: 2, secondsOffset: 0))
        track.append(makePosition(x: 4, y: 6, secondsOffset: 1))

        let snapshot = track.snapshot()
        let restored = PlayerTrack.restore(from: snapshot)

        #expect(restored.playerID == 7)
        #expect(restored.positions.count == 2)
        #expect(abs(restored.totalDistance - track.totalDistance) < 0.001)
        #expect(abs(restored.averageSpeed - track.averageSpeed) < 0.001)
        #expect(abs(restored.currentSpeed - track.currentSpeed) < 0.001)
    }

    @Test func snapshotEncodesAndDecodesAsJSON() throws {
        var track = PlayerTrack(playerID: 3)
        track.append(makePosition(x: 1, y: 2, secondsOffset: 0))

        let snapshot = track.snapshot()
        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(SerializedTrack.self, from: data)

        #expect(decoded.playerID == 3)
        #expect(decoded.positions.count == 1)
    }
}
