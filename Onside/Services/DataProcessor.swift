//
//  DataProcessor.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import Foundation

actor DataProcessor: DataProcessorProtocol {
    private let sessionStorage: any SessionStorageProtocol
    private let receiver: any UDPReceiverProtocol
    private var listenTask: Task<Void, Never>?
    private let positionScale: Float = 0.01
    private var positionContinuation: AsyncStream<PlayerPosition>.Continuation?
    
    /// Stream pozic pro odběratele (např. RinkViewModel)
    nonisolated let positions: AsyncStream<PlayerPosition>
    
    init(receiver: any UDPReceiverProtocol = UDPReceiver(port: 9001), sessionStorage: any SessionStorageProtocol = SessionStorage()) {
        self.receiver = receiver
        self.sessionStorage = sessionStorage
        
        var cont: AsyncStream<PlayerPosition>.Continuation?
        self.positions = AsyncStream { cont = $0 }
        self.positionContinuation = cont
    }
    
    func connect() {
        guard listenTask == nil else { return }
        listenTask = Task {
            let stream = await receiver.start()
            for await packet in stream {
                guard !Task.isCancelled else { break }
                if let position = transformToPlayerPosition(packet: packet) {
                    positionContinuation?.yield(position)
                    if await sessionStorage.isRecording() {
                        await sessionStorage.appendPosition(position: position)
                    }
                }
            }
        }
    }

    func disconnect() {
        listenTask?.cancel()
        listenTask = nil
        Task { await receiver.stop() }
    }
    
    /// Parsuje UDPPacket na PlayerPosition
    private func transformToPlayerPosition(packet: UDPPacket) -> PlayerPosition? {
        let data = packet.rawBytes
        guard data.count >= 17 else { return nil }

        let x = data.withUnsafeBytes { $0.load(fromByteOffset: 0, as: Double.self) }
        let y = data.withUnsafeBytes { $0.load(fromByteOffset: 8, as: Double.self) }
        let playerId: UInt8 = data.withUnsafeBytes { $0.load(fromByteOffset: 16, as: UInt8.self) }

        return PlayerPosition(id: playerId, x: CGFloat(x), y: CGFloat(y), timestamp: packet.timestamp)
    }
}
