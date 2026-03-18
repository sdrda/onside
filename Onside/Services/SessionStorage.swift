//
//  SessionStorage.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI

actor SessionStorage {
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
}
