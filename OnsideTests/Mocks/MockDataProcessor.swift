//
//  MockDataProcessor.swift
//  OnsideTests
//

import Foundation
@testable import Onside

actor MockDataProcessor: DataProcessorProtocol {
    private var continuation: AsyncStream<PlayerPosition>.Continuation?
    nonisolated let positions: AsyncStream<PlayerPosition>

    init() {
        var cont: AsyncStream<PlayerPosition>.Continuation?
        self.positions = AsyncStream { cont = $0 }
        self.continuation = cont
    }

    func connect() {}
    func disconnect() {
        continuation?.finish()
    }

    // MARK: - Test helpers

    func send(position: PlayerPosition) {
        continuation?.yield(position)
    }
}
