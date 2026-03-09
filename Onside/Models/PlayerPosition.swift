//
//  PlayerPosition.swift
//  Onside
//
//  Created by Šimon Drda on 08.03.2026.
//

import Foundation

struct PlayerPosition: Identifiable, Codable, Equatable {
    let id: UInt8
    let x: CGFloat
    let y: CGFloat
    let speed: CGFloat
    let timestamp: Date
}
