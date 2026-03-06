//
//  DataViewModel.swift
//  Onside
//
//  Created by Šimon Drda on 06.03.2026.
//

import Foundation
import SwiftUI

struct PlayerPosition: Identifiable, Codable, Equatable {
    let id: UInt8
    let x: CGFloat
    let y: CGFloat
    let speed: CGFloat
    let timestamp: Date
}

@Observable
@MainActor
final class DataViewModel: PlayerDataSource {
    private(set) var players: [UInt8: PlayerPosition] = [:]
    private(set) var isConnected = false
    
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
            }
            isConnected = false
        }
    }
    
    func stop() {
        task?.cancel()
        Task { await receiver.stop() }
        isConnected = false
    }
    
    private var smoothedSpeeds: [UInt8: CGFloat] = [:]

    private func transformToPlayerPosition(packet: UDPPacket) -> PlayerPosition {
        let data = packet.rawBytes
        guard data.count >= 17 else {
            return PlayerPosition(id: 0, x: 0, y: 0, speed: 0, timestamp: packet.timestamp)
        }

        let x = data.withUnsafeBytes { $0.load(fromByteOffset: 0, as: Double.self) }
        let y = data.withUnsafeBytes { $0.load(fromByteOffset: 8, as: Double.self) }
        let playerId: UInt8 = data.withUnsafeBytes { $0.load(fromByteOffset: 16, as: UInt8.self) }

        let speed: CGFloat
        if let prev = players[playerId] {
            let dt = packet.timestamp.timeIntervalSince(prev.timestamp)
            guard dt > 0 else {
                return PlayerPosition(id: playerId, x: CGFloat(x), y: CGFloat(y), speed: prev.speed, timestamp: packet.timestamp)
            }
            let dx = CGFloat(x) - prev.x
            let dy = CGFloat(y) - prev.y
            let rawSpeed = sqrt(dx * dx + dy * dy) / CGFloat(dt)
            
            let alpha: CGFloat = 0.2  // 0.1 = více vyhlazené, 0.5 = více reaktivní
            let prev = smoothedSpeeds[playerId, default: rawSpeed]
            speed = alpha * rawSpeed + (1 - alpha) * prev
        } else {
            speed = 0
        }
        
        smoothedSpeeds[playerId] = speed
        return PlayerPosition(id: playerId, x: CGFloat(x), y: CGFloat(y), speed: speed, timestamp: packet.timestamp)
    }
}
