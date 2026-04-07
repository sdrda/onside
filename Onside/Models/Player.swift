//
//  Player.swift
//  Onside
//
//  Created by Šimon Drda on 05.04.2026.
//

import SwiftData
import Foundation

@Model
class Player {
    @Attribute(.unique) var sensorId: String
    var name: String
    var jerseyNumber: Int
    var photoUrl: URL?

    @Relationship(deleteRule: .nullify, inverse: \PlayerGroup.players)
    var groups: [PlayerGroup] = []

    init(
        sensorId: String,
        name: String,
        jerseyNumber: Int,
        photoUrl: URL? = nil,
    ) {
        self.sensorId = sensorId
        self.name = name
        self.jerseyNumber = jerseyNumber
        self.photoUrl = photoUrl
    }
}
