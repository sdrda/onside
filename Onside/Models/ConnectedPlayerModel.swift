//
//  ConnectedPlayerModel.swift
//  Onside
//
//  Created by Šimon Drda on 08.03.2026.
//

import SwiftData

@Model
class ConnectedPlayerModel {
    var sensorId: Int
    var name: String

    init(sensorId: Int, name: String) {
        self.sensorId = sensorId
        self.name = name
    }
}
