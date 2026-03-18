//
//  UDPReceiver.swift
//  Onside
//
//  Created by Šimon Drda on 05.03.2026.
//

import Foundation
import Network
import SwiftUI

struct UDPPacket: Sendable {
    let timestamp: Date
    let rawBytes: Data
}

actor UDPReceiver {
    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private let port: NWEndpoint.Port
    private var continuation: AsyncStream<UDPPacket>.Continuation?

    init(port: UInt16) {
        self.port = NWEndpoint.Port(rawValue: port)!
    }

    func start() -> AsyncStream<UDPPacket> {
        let (stream, continuation) = AsyncStream.makeStream(of: UDPPacket.self)
        self.continuation = continuation

        let params = NWParameters.udp
        guard let listener = try? NWListener(using: params, on: self.port) else {
            print("[UDPReceiver] Failed to create listener on port \(self.port)")
            continuation.finish()
            return stream
        }
        self.listener = listener

        listener.stateUpdateHandler = { state in
            print("[UDPReceiver] Listener state: \(state)")
        }

        listener.newConnectionHandler = { [weak self] conn in
            Task { await self?.handleConnection(conn) }
        }
        listener.start(queue: .global(qos: .userInteractive))

        return stream
    }

    private func handleConnection(_ conn: NWConnection) {
        connections.append(conn)
        conn.start(queue: .global(qos: .userInteractive))
        receiveLoop(conn)
    }

    private func receiveLoop(_ conn: NWConnection) {
        conn.receiveMessage { [weak self] data, _, _, error in
            guard let self, error == nil, let data else { return }
            let packet = UDPPacket(timestamp: .now, rawBytes: data)
            Task {
                await self.continuation?.yield(packet)
                await self.receiveLoop(conn)
            }
        }
    }

    func stop() {
        continuation?.finish()
        continuation = nil
        for conn in connections {
            conn.cancel()
        }
        connections.removeAll()
        listener?.cancel()
        listener = nil
    }
}
