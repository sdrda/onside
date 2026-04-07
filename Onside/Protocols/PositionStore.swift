//
//  PositionStore.swift
//  Onside
//

import Foundation

protocol PositionStore: Actor {
    func appendPosition(position: PlayerPosition)
    var playerTrackCount: Int { get }
    func positionCounts() -> [UInt8: Int]
    func playerIDs() -> [UInt8]
    func heatmapPoints(for playerID: UInt8) -> [(x: CGFloat, y: CGFloat)]
    func timeRange() -> ClosedRange<Date>?
    func positions(at timestamp: Date) -> [UInt8: PlayerPosition]
}
