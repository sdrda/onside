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
    var id = UUID()
    var sensorId: Int = 0
    var name: String = ""
    var jerseyNumber: Int = 0

    @Relationship(deleteRule: .nullify, inverse: \PlayerGroup.players)
    var groups: [PlayerGroup]?
    
    init(sensorId: Int, name: String, jerseyNumber: Int) {
        self.sensorId = sensorId
        self.name = name
        self.jerseyNumber = jerseyNumber
    }
}
