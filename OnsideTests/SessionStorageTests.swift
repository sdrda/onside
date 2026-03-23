//
//  SessionStorageTests.swift
//  OnsideTests
//

import Testing
import Foundation
@testable import Onside

struct SessionStorageTests {

    private func makePosition(id: UInt8, x: CGFloat, y: CGFloat) -> PlayerPosition {
        PlayerPosition(id: id, x: x, y: y, timestamp: .now)
    }

    // MARK: - Recording state

    @Test func initiallyNotRecording() async {
        let storage = SessionStorage()
        let recording = await storage.isRecording()
        #expect(recording == false)
    }

    @Test func startRecordingSetsFlag() async {
        let storage = SessionStorage()
        await storage.startRecording()
        let recording = await storage.isRecording()
        #expect(recording == true)
    }

    @Test func stopRecordingClearsFlag() async {
        let storage = SessionStorage()
        await storage.startRecording()
        await storage.stopRecording()
        let recording = await storage.isRecording()
        #expect(recording == false)
    }

    // MARK: - Append & counts

    @Test func appendPositionCreatesTrack() async {
        let storage = SessionStorage()
        await storage.appendPosition(position: makePosition(id: 1, x: 0, y: 0))
        let count = await storage.playerTrackCount
        #expect(count == 1)
    }

    @Test func appendMultiplePlayersCreatesSeparateTracks() async {
        let storage = SessionStorage()
        await storage.appendPosition(position: makePosition(id: 1, x: 0, y: 0))
        await storage.appendPosition(position: makePosition(id: 2, x: 1, y: 1))
        await storage.appendPosition(position: makePosition(id: 1, x: 2, y: 2))

        let count = await storage.playerTrackCount
        #expect(count == 2)

        let counts = await storage.positionCounts()
        #expect(counts[1] == 2)
        #expect(counts[2] == 1)
    }

    @Test func playerIDsReturnsSorted() async {
        let storage = SessionStorage()
        await storage.appendPosition(position: makePosition(id: 5, x: 0, y: 0))
        await storage.appendPosition(position: makePosition(id: 2, x: 0, y: 0))
        await storage.appendPosition(position: makePosition(id: 9, x: 0, y: 0))

        let ids = await storage.playerIDs()
        #expect(ids == [2, 5, 9])
    }

    // MARK: - Heatmap points

    @Test func heatmapPointsReturnsCorrectCoordinates() async {
        let storage = SessionStorage()
        await storage.appendPosition(position: makePosition(id: 1, x: 10.5, y: -3.2))
        await storage.appendPosition(position: makePosition(id: 1, x: 20.0, y: 5.0))

        let points = await storage.heatmapPoints(for: 1)
        #expect(points.count == 2)
        #expect(points[0].x == 10.5)
        #expect(points[0].y == -3.2)
        #expect(points[1].x == 20.0)
        #expect(points[1].y == 5.0)
    }

    @Test func heatmapPointsForUnknownPlayerReturnsEmpty() async {
        let storage = SessionStorage()
        await storage.appendPosition(position: makePosition(id: 1, x: 0, y: 0))

        let points = await storage.heatmapPoints(for: 99)
        #expect(points.isEmpty)
    }
}
