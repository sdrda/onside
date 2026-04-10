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
    let timestamp: Date

    /// Převede 2D pozici na 3D SIMD vektor škálovaný daným faktorem.
    /// Y osa je nastavena na fixní výšku (ground plane).
    func scaledPosition(scale: Float, groundY: Float = 0.01) -> SIMD3<Float> {
        SIMD3<Float>(
            Float(x) * scale,
            groundY,
            Float(y) * scale
        )
    }
}
