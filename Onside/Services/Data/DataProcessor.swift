import Foundation
import os

actor DataProcessor: DataProcessorProtocol {
    private let sessionStorage: any SessionStorageProtocol
    private let receiver: any UDPReceiverProtocol
    private var listenTask: Task<Void, Never>?
    private var positionContinuation: AsyncStream<PlayerPosition>.Continuation?
    
    private let logger = Logger(subsystem: "Onside", category: "DataProcessor")
    var onNetworkError: ((Error) -> Void)?
    
    /// Stream pozic pro odběratele (např. RinkViewModel)
    nonisolated let positions: AsyncStream<PlayerPosition>
    
    init(receiver: any UDPReceiverProtocol = UDPReceiver(port: 9001), sessionStorage: any SessionStorageProtocol) {
        self.receiver = receiver
        self.sessionStorage = sessionStorage
        
        let (stream, continuation) = AsyncStream<PlayerPosition>.makeStream()
        self.positions = stream
        self.positionContinuation = continuation
    }
    
    func connect() {
        guard listenTask == nil else { return }
        listenTask = Task {
            do {
                for try await packet in await receiver.startReceiving() {
                    guard !Task.isCancelled else { break }
                    if let position = transformToPlayerPosition(packet: packet) {
                        positionContinuation?.yield(position)
                        if await sessionStorage.isRecording() {
                            await sessionStorage.appendPosition(position: position)
                        }
                    }
                }
            } catch is CancellationError {
                logger.debug("Naslouchání bylo zrušeno.")
            } catch {
                logger.error("Listener selhal: \(error.localizedDescription)")
                self.listenTask = nil
                self.onNetworkError?(error)
            }
        }
    }

    func disconnect() {
        listenTask?.cancel()
        listenTask = nil
        Task { await receiver.stopReceiving() }
    }
    
    private func transformToPlayerPosition(packet: UDPPacket) -> PlayerPosition? {
        let data = packet.rawBytes
        
        guard data.count >= 32 else { return nil }

        return data.withUnsafeBytes { buffer in
            let x = buffer.load(fromByteOffset: 0, as: Double.self)
            let y = buffer.load(fromByteOffset: 8, as: Double.self)
            
            let playerId = buffer.load(fromByteOffset: 16, as: UInt8.self)
        
            let timestampDouble = buffer.load(fromByteOffset: 24, as: Double.self)

            let timestampDate = Date(timeIntervalSince1970: timestampDouble)

            return PlayerPosition(id: playerId, x: CGFloat(x), y: CGFloat(y), timestamp: timestampDate)
        }
    }
}
