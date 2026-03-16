//
//  SessionStorage.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

actor SessionStorage {
    private var playerTracks: [PlayerTrack] = []
    
    func append(position: PlayerPosition) {
        if let index = playerTracks.firstIndex(where: { $0.playerID == position.id }) {
            playerTracks[index].append(position)
        } else {
            var newTrack = PlayerTrack(playerID: position.id)
            newTrack.append(position)
            playerTracks.append(newTrack)
        }
    }
}
