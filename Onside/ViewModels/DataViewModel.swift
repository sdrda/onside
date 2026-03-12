//
//  DataViewModel.swift
//  Onside
//
//  Created by Šimon Drda on 06.03.2026.
//

import Foundation
import SwiftUI

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

    func start() {
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

    func stop() {
        task?.cancel()
        Task { await receiver.stop() }
        isConnected = false
        playerIDs = []
        players = [:]
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
