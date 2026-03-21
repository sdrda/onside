//
//  DataProcessorProtocol.swift
//  Onside
//
//  Created by Šimon Drda on 20.03.2026.
//

import Foundation

protocol DataProcessorProtocol: Actor {
    nonisolated var positions: AsyncStream<PlayerPosition> { get }
    func connect()
    func disconnect()
}
