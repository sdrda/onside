//
//  RealityRinkView.swift
//  Onside
//
//  Created by Šimon Drda on 10.03.2026.
//

import SwiftUI
import RealityKit

final class PlayerPositionBridge {
    static let shared = PlayerPositionBridge()
    private init() {}
    nonisolated(unsafe) var positions: [UInt8: SIMD3<Float>] = [:]
}

struct PlayerComponent: Component {
    var targetPosition: SIMD3<Float>
    var playerID: UInt8
}

class PlayerMovementSystem: System {
    private static let query = EntityQuery(where: .has(PlayerComponent.self))

    required init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        let positions = PlayerPositionBridge.shared.positions
        let t = SIMD3<Float>(repeating: min(1.0, 10.0 * Float(context.deltaTime)))

        for entity in context.scene.performQuery(Self.query) {
            guard var comp = entity.components[PlayerComponent.self] else { continue }
            if let pos = positions[comp.playerID] {
                comp.targetPosition = pos
                entity.components.set(comp)
            }
            entity.position = simd_mix(entity.position, comp.targetPosition, t)
        }
    }
}

private final class EntityClearState {
    var lastToken = -1
}

struct RealityRinkView: View {
    @State private var isARMode = false
    @State private var cachedRinkImage: CGImage? = nil
    @State private var clearState = EntityClearState()
    let config: RinkConfiguration = .standard
    var viewModel: DataViewModel

    init(viewModel: DataViewModel) {
        self.viewModel = viewModel
        PlayerComponent.registerComponent()
        PlayerMovementSystem.registerSystem()
    }

    var body: some View {
        RealityView { content in
            content.camera = .virtual
            content.add(await createRinkEntity())
        } update: { content in
            let ids = viewModel.playerIDs
            let token = viewModel.entityClearToken
            guard let rink = findRink(in: content.entities) else { return }

            if clearState.lastToken != token {
                clearState.lastToken = token
                for child in rink.children where child.name.hasPrefix("player_") {
                    child.removeFromParent()
                }
            }

            syncPlayers(ids: ids, on: rink)
        }
        .realityViewCameraControls(.orbit)
    }

    // MARK: - Pomocné funkce

    private func findRink(in entities: some Sequence<Entity>) -> Entity? {
        for entity in entities {
            if entity.name == "RinkPlane" { return entity }
            if let child = entity.children.first(where: { $0.name == "RinkPlane" }) { return child }
        }
        return nil
    }

    private func syncPlayers(ids: Set<UInt8>, on rink: Entity) {
        for playerID in ids {
            let playerName = "player_\(playerID)"
            guard rink.findEntity(named: playerName) == nil else { continue }
            let startPos = PlayerPositionBridge.shared.positions[playerID] ?? .zero
            let newEntity = createPlayerEntity(id: playerID, startPos: startPos)
            newEntity.name = playerName
            rink.addChild(newEntity)
        }
        for child in rink.children where child.name.hasPrefix("player_") {
            if let id = UInt8(child.name.dropFirst("player_".count)), !ids.contains(id) {
                child.removeFromParent()
            }
        }
    }

    private func createRinkEntity() async -> ModelEntity {
        let cgImage: CGImage
        if let cached = cachedRinkImage {
            cgImage = cached
        } else {
            let cfg = config
            let rendered = await Task.detached(priority: .userInitiated) {
                RinkRenderer(config: cfg).render(size: CGSize(width: 2048, height: 1024))
            }.value
            cgImage = rendered ?? emptyCGImage()
            cachedRinkImage = cgImage
        }

        let mesh = MeshResource.generatePlane(width: 0.6, depth: 0.3, cornerRadius: 0.085)
        var material = SimpleMaterial()
        material.roughness = 0.15
        if let texture = try? await TextureResource(image: cgImage, options: .init(semantic: .color)) {
            material.color = .init(texture: .init(texture))
        }
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "RinkPlane"
        return entity
    }

    private func createPlayerEntity(id: UInt8, startPos: SIMD3<Float>) -> Entity {
        let mesh = MeshResource.generateCylinder(height: 0.02, radius: 0.008)
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = startPos
        entity.components.set(PlayerComponent(targetPosition: startPos, playerID: id))
        return entity
    }

    /// Minimální fallback 1×1 obrázek pokud render selže.
    private func emptyCGImage() -> CGImage {
        let ctx = CGContext(data: nil, width: 1, height: 1,
                           bitsPerComponent: 8, bytesPerRow: 0,
                           space: CGColorSpaceCreateDeviceRGB(),
                           bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!
        return ctx.makeImage()!
    }
}
