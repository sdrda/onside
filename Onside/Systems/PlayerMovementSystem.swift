//
//  PlayerMovementSystem.swift
//  Onside
//
//  Created by Šimon Drda on 17.03.2026.
//

import RealityKit

class PlayerMovementSystem: System {
    private static let query = EntityQuery(where: .has(PlayerComponent.self))

    required init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        let t = SIMD3<Float>(repeating: min(1.0, 10.0 * Float(context.deltaTime)))

        for entity in context.scene.performQuery(Self.query) {
            guard let comp = entity.components[PlayerComponent.self] else { continue }
            entity.position = simd_mix(entity.position, comp.targetPosition, t)
        }
    }
}
