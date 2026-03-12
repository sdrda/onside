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

@Observable
@MainActor
final class DataViewModel: PlayerDataSource {
    private(set) var playerIDs: Set<UInt8> = []
    private(set) var isConnected = false
    private(set) var isRecording = false
    private(set) var recordedCount = 0
    
    @ObservationIgnored
    private(set) var recordingBuffer: [PlayerPosition] = []
    
    @ObservationIgnored
    private(set) var players: [UInt8: PlayerPosition] = [:]

    private let receiver: UDPReceiver
    private var task: Task<Void, Never>?

    init() {
        self.receiver = UDPReceiver(port: 9000)
    }

    func startLiveTransfer() {
        isConnected = true
        task = Task {
            let stream = await receiver.start()
            for await packet in stream {
                guard !Task.isCancelled else { break }
                let pos = transformToPlayerPosition(packet: packet)
                players[pos.id] = pos

                let scale: Float = 0.01
                PlayerPositionBridge.shared.positions[pos.id] = [Float(pos.x) * scale, 0, Float(pos.y) * scale]

                if !playerIDs.contains(pos.id) { playerIDs.insert(pos.id) }

                if isRecording {
                    recordingBuffer.append(pos)
                    recordedCount += 1
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
        players = [:]
        
        // Odstranění dat z bridge
        PlayerPositionBridge.shared.positions = [:]
    }

    func startRecording() {
        recordingBuffer = []
        recordedCount = 0
        isRecording = true
    }

    func stopRecording() {
        isRecording = false
    }
    
    func loadRecordedData(positions: [PlayerPosition]) {
        self.recordingBuffer = positions
        self.recordedCount = positions.count
    }
    
    func loadFromFile(url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            let positions = try JSONDecoder().decode([PlayerPosition].self, from: data)
            loadRecordedData(positions: positions)
        } catch {
            print("Chyba při načítání: \(error)")
        }
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
