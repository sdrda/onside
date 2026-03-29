//
//  RecordingAttributes.swift
//  Onside
//
//  Created by Šimon Drda on 29.03.2026.
//

import ActivityKit
import Foundation

struct RecordingAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var playerCount: Int
    }

    var startDate: Date
}
