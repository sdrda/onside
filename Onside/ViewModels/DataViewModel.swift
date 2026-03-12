//
//  DataViewModel.swift
//  Onside
//
//  Created by Šimon Drda on 06.03.2026.
//

import Foundation
import SwiftUI

struct AppError: LocalizedError {
    let errorDescription: String?
}

struct PlayerStats {
    var speed: Double = 0
    var distance: Double = 0
}

@Observable
@MainActor
final class DataViewModel {
    private(set) var playerIDs: Set<UInt8> = []
    private(set) var isConnected = false
    private(set) var isRecording = false
    private(set) var recordedCount = 0

    private(set) var stats: [UInt8: PlayerStats] = [:]
    var selectedPlayerID: UInt8? = nil

    // Hlavní úložiště – nahrazuje recordingBuffer i players
    @ObservationIgnored
    private(set) var tracks: [UInt8: PlayerTrack] = [:]
    @ObservationIgnored
    private var packetCount: [UInt8: Int] = [:]

    private let receiver: UDPReceiver
    private var task: Task<Void, Never>?

    init() {
        self.receiver = UDPReceiver(port: 9000)
    }

    // MARK: - Live transfer

    func startLiveTransfer() {
        isConnected = true
        task = Task {
            let stream = await receiver.start()
            for await packet in stream {
                guard !Task.isCancelled else { break }
                let pos = transformToPlayerPosition(packet: packet)

                updateBridge(pos)

                if !playerIDs.contains(pos.id) { playerIDs.insert(pos.id) }

                if isRecording {
                    tracks[pos.id, default: PlayerTrack(playerID: pos.id)].append(pos)
                    recordedCount += 1
                } else {
                    if tracks[pos.id] == nil {
                        tracks[pos.id] = PlayerTrack(playerID: pos.id)
                    }
                    tracks[pos.id]?.append(pos)
                }

                // Stats update každých 10 paketů na hráče
                packetCount[pos.id, default: 0] += 1
                if packetCount[pos.id]! % 10 == 0, let track = tracks[pos.id] {
                    stats[pos.id] = PlayerStats(speed: track.currentSpeed, distance: track.totalDistance)
                }
            }
            isConnected = false
        }
    }

    func stopLiveTransfer() throws {
        if isRecording {
            throw AppError(errorDescription: "Cannot stop live transfer while recording")
        }

        task?.cancel()
        Task { await receiver.stop() }
        isConnected = false
        playerIDs = []
        tracks = [:]

        PlayerPositionBridge.shared.positions = [:]
    }

    // MARK: - Recording

    func startRecording() {
        tracks = [:]
        recordedCount = 0
        isRecording = true
    }

    func stopRecording() {
        isRecording = false
    }

    // MARK: - Load

    func loadRecordedData(tracks: [SerializedTrack]) {
        self.tracks = [:]
        for snapshot in tracks {
            self.tracks[snapshot.playerID] = PlayerTrack.restore(from: snapshot)
        }
        recordedCount = self.tracks.values.reduce(0) { $0 + $1.positions.count }
    }

    func loadFromFile(url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)
            let snapshots = try JSONDecoder().decode([SerializedTrack].self, from: data)
            loadRecordedData(tracks: snapshots)
        } catch {
            print("Chyba při načítání: \(error)")
        }
    }

    // MARK: - Analytics helpers

    func totalDistance(for playerID: UInt8) -> Double {
        stats[playerID]?.distance ?? 0
    }

    func currentSpeed(for playerID: UInt8) -> Double {
        stats[playerID]?.speed ?? 0
    }

    func heatmapPoints(for playerID: UInt8) -> [(x: CGFloat, y: CGFloat)] {
        tracks[playerID]?.heatmapPoints ?? []
    }

    // MARK: - Replay

    private(set) var isReplaying = false

    @ObservationIgnored
    private var replayTask: Task<Void, Never>?

    func startReplay() {
        // Vezmi všechny pozice přes všechny hráče, seřaď podle timestampu
        let allPositions = tracks.values
            .flatMap { $0.positions }
            .sorted { $0.timestamp < $1.timestamp }

        guard !allPositions.isEmpty else { return }

        do { try stopLiveTransfer() } catch {
            print("Chyba při zastavení live transferu: \(error)")
        }

        isReplaying = true
        replayTask = Task {
            let startTime = ContinuousClock.now
            let recordingStart = allPositions[0].timestamp

            for position in allPositions {
                guard !Task.isCancelled else { break }

                let offset = position.timestamp.timeIntervalSince(recordingStart)
                let targetTime = startTime + .seconds(offset)

                try? await Task.sleep(until: targetTime, clock: .continuous)
                updateBridge(position)
            }

            isReplaying = false
        }
    }

    func stopReplay() {
        replayTask?.cancel()
        isReplaying = false
    }

    // MARK: - Private

    private func updateBridge(_ pos: PlayerPosition) {
        let scale: Float = 0.01
        PlayerPositionBridge.shared.positions[pos.id] = [
            Float(pos.x) * scale,
            0,
            Float(pos.y) * scale
        ]
    }

    private func transformToPlayerPosition(packet: UDPPacket) -> PlayerPosition {
        let data = packet.rawBytes
        guard data.count >= 17 else {
            return PlayerPosition(id: 0, x: 0, y: 0, timestamp: packet.timestamp)
        }

        let x = data.withUnsafeBytes { $0.load(fromByteOffset: 0, as: Double.self) }
        let y = data.withUnsafeBytes { $0.load(fromByteOffset: 8, as: Double.self) }
        let playerId: UInt8 = data.withUnsafeBytes { $0.load(fromByteOffset: 16, as: UInt8.self) }

        return PlayerPosition(id: playerId, x: CGFloat(x), y: CGFloat(y), timestamp: packet.timestamp)
    }
}
