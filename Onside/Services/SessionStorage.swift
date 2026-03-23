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
}
