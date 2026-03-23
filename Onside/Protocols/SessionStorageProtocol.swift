//
//  SessionStorageProtocol.swift
//  Onside
//
//  Created by Šimon Drda on 20.03.2026.
//

import Foundation

protocol SessionStorageProtocol: Actor {
    func appendPosition(position: PlayerPosition)
    func startRecording()
    func stopRecording()
    var playerTrackCount: Int { get }
    func isRecording() -> Bool
    func positionCounts() -> [UInt8: Int]
    func playerIDs() -> [UInt8]
    func heatmapPoints(for playerID: UInt8) -> [(x: CGFloat, y: CGFloat)]
}
