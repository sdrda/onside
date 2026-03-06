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
final class DataViewModel {
    private(set) var packets: [UDPPacket] = []
    private(set) var isConnected = false

    private let receiver: UDPReceiver
    private var task: Task<Void, Never>?

    init() {
        self.receiver = UDPReceiver(port: 9000)
    }

    func start() {
        print("Connection started")
        isConnected = true
        task = Task {
            let stream = await receiver.start()
            for await packet in stream {
                guard !Task.isCancelled else { break }
                packets.append(packet)
            }
            isConnected = false
        }
    }

    func stop() {
        task?.cancel()
        Task { await receiver.stop() }
        isConnected = false
    }
}
