//
//  MockUDPReceiver.swift
//  OnsideTests
//

import Foundation
@testable import Onside

actor MockUDPReceiver: UDPReceiverProtocol {
    private var continuation: AsyncStream<UDPPacket>.Continuation?

    func start() -> AsyncStream<UDPPacket> {
        let (stream, continuation) = AsyncStream.makeStream(of: UDPPacket.self)
        self.continuation = continuation
        return stream
    }

    func stop() {
        continuation?.finish()
        continuation = nil
    }

    // MARK: - Test helpers

    /// Pošle packet do streamu jako by přišel po síti.
    func send(packet: UDPPacket) {
        continuation?.yield(packet)
    }

    /// Vytvoří UDPPacket z pozice hráče pro testování.
    static func makePacket(playerID: UInt8, x: Double, y: Double) -> UDPPacket {
        var data = Data()
        withUnsafeBytes(of: x) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: y) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: playerID) { data.append(contentsOf: $0) }
        return UDPPacket(timestamp: .now, rawBytes: data)
    }
}
