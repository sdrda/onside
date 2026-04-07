//
//  Group.swift
//  Onside
//
//  Created by Šimon Drda on 05.04.2026.
//

import SwiftData
import Foundation

@Model
class PlayerGroup {
    var name: String
    var colorHex: String?

    @Relationship
    var players: [Player] = []

    init(name: String, colorHex: String? = nil) {
        self.name = name
        self.colorHex = colorHex
    }
}
