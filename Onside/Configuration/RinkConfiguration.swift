//
//  RinkConfiguration.swift
//  Onside
//
//  Created by Šimon Drda on 06.03.2026.
//

import Foundation

struct RinkConfiguration {
    let width: CGFloat
    let height: CGFloat

    static let standard = RinkConfiguration(width: 60, height: 30)
    
    // přepočet z metrů na body SpriteKitu
    func toScene(point: CGPoint, sceneSize: CGSize) -> CGPoint {
        CGPoint(
            x: (point.x / width) * sceneSize.width,
            y: (point.y / height) * sceneSize.height
        )
    }
}
