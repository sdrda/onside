//
//  UDPReceiver.swift
//  Onside
//
//  Created by Šimon Drda on 05.03.2026.
//

import Foundation
import Network

actor UDPReceiver: UDPReceiverProtocol {
    private var listenerTask: Task<Void, Never>?
    private let port: NWEndpoint.Port
    private var continuation: AsyncThrowingStream<UDPPacket, Error>.Continuation?

    init(port: UInt16) {
        self.port = NWEndpoint.Port(rawValue: port)!
    }

    func startReceiving() -> AsyncThrowingStream<UDPPacket, Error> {
        let (stream, continuation) = AsyncThrowingStream.makeStream(of: UDPPacket.self)
        self.continuation = continuation

        self.listenerTask = Task {
            do {
                // Inicializujeme NetworkListener
                let listener = try NetworkListener(
                    using: .parameters {
                        UDP()
                    }.localPort(self.port)
                )

                // Spustíme NetworkListener
                try await listener.run { connection in
                    for try await (data, _) in connection.messages {
                        let packet = UDPPacket(
                            timestamp: Date(),
                            rawBytes: data
                        )
                        continuation.yield(packet)
                    }
                }

                continuation.finish()
            } catch {
                if error is CancellationError {
                    continuation.finish()
                } else {
                    continuation.finish(throwing: error)
                }
            }
        }

        return stream
    }

    func stopReceiving() {
        // Ukončíme continuation
        continuation?.finish()
        continuation = nil

        // Zrušíme task
        listenerTask?.cancel()
        listenerTask = nil
    }
}
