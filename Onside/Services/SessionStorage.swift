//
//  SessionStorage.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI

actor SessionStorage: SessionStorageProtocol {
    private var playerTracks: [PlayerTrack] = []
    private(set) var recording: Bool = false
    
    /// Přidá pozici do tracku konkrétního hráče
    ///
    /// - Parameter playerID: Identifikátor hráče.
    func appendPosition(position: PlayerPosition) {
        if let index = playerTracks.firstIndex(where: { $0.playerID == position.id }) {
            playerTracks[index].append(position)
        } else {
            var newTrack = PlayerTrack(playerID: position.id)
            newTrack.append(position)
            playerTracks.append(newTrack)
        }
    }
    
    /// Začně ukládat do SessionStorage
    func startRecording() {
        recording = true
    }
    
    /// Zastaví ukládání
    func stopRecording() {
        recording = false
    }
    
    /// Počet unikátních hráčů
    var playerTrackCount: Int {
        playerTracks.count
    }
    
    /// Příznak, zda se nahrává
    func isRecording() -> Bool {
        recording
    }
    
    /// Počet nahraných pozic pro každého hráče
    func positionCounts() -> [UInt8: Int] {
        Dictionary(uniqueKeysWithValues: playerTracks.map { ($0.playerID, $0.positions.count) })
    }
    
    /// Seznam ID hráčů
    func playerIDs() -> [UInt8] {
        playerTracks.map { $0.playerID }.sorted()
    }
    
    /// Body pro heatmapu konkrétního hráče
    func heatmapPoints(for playerID: UInt8) -> [(x: CGFloat, y: CGFloat)] {
        playerTracks.first(where: { $0.playerID == playerID })?.heatmapPoints ?? []
    }
    
    /// Časový rozsah záznamu (od první do poslední pozice)
    func timeRange() -> ClosedRange<Date>? {
        let allPositions = playerTracks.flatMap { $0.positions }
        guard let first = allPositions.min(by: { $0.timestamp < $1.timestamp }),
              let last = allPositions.max(by: { $0.timestamp < $1.timestamp }),
              first.timestamp < last.timestamp else { return nil }
        return first.timestamp...last.timestamp
    }
    
    /// Pozice všech hráčů nejblíže danému timestampu
    func positions(at timestamp: Date) -> [UInt8: PlayerPosition] {
        var result: [UInt8: PlayerPosition] = [:]
        for track in playerTracks {
            if let pos = track.position(at: timestamp) {
                result[track.playerID] = pos
            }
        }
        return result
    }
}
