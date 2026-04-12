//
//  SessionData.swift
//  Onside
//
//  Created by Šimon Drda on 11.04.2026.
//

import Foundation

struct SessionData: Codable {
    let tracks: [SerializedTrack]
    let exportDate: Date
    
    init(tracks: [SerializedTrack]) {
        self.tracks = tracks
        self.exportDate = Date()
    }
}
