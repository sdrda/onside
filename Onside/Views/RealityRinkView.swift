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

struct RealityRinkView: View {
    @State private var isARMode = false
    let config: RinkConfiguration = .standard
    var viewModel: DataViewModel
    
    init(viewModel: DataViewModel) {
        self.viewModel = viewModel
        
        // Registrace ECS subsystému před vykreslením
        PlayerComponent.registerComponent()
        PlayerMovementSystem.registerSystem()
    }
    
    var body: some View {
        VStack {
            Toggle("Přepnout do AR módu", isOn: $isARMode)
                .padding()
            if isARMode {
                RealityView { content in
                    #if os(iOS)
                    content.camera = .spatialTracking
                    #endif
                    
                    let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: [0.5, 0.5]))
                    let rinkEntity = createRinkEntity()
                    
                    anchor.addChild(rinkEntity)
                    content.add(anchor)
                    
                } update: { content in
                    let ids = viewModel.playerIDs
                    guard let rink = findRink(in: content.entities) else { return }
                    syncPlayers(ids: ids, on: rink)
                }

            } else {
                RealityView { content in
                    content.camera = .virtual
                    let rinkEntity = createRinkEntity()
                    content.add(rinkEntity)

                } update: { content in
                    let ids = viewModel.playerIDs
                    guard let rink = findRink(in: content.entities) else { return }
                    syncPlayers(ids: ids, on: rink)
                }
                .realityViewCameraControls(.orbit)
            }
        }
    }
    
    // MARK: - Pomocné funkce

    private func findRink(in entities: some Sequence<Entity>) -> Entity? {
        for entity in entities {
            if entity.name == "RinkPlane" { return entity }
            if let child = entity.children.first(where: { $0.name == "RinkPlane" }) { return child }
        }
        return nil
    }

    // Volá se jen při změně playerIDs – přidá nové, odstraní zaniklé entity
    private func syncPlayers(ids: Set<UInt8>, on rink: Entity) {
        // Přidat chybějící
        for playerID in ids {
            let playerName = "player_\(playerID)"
            guard rink.findEntity(named: playerName) == nil else { continue }
            let startPos = PlayerPositionBridge.shared.positions[playerID] ?? .zero
            let newEntity = createPlayerEntity(id: playerID, startPos: startPos)
            newEntity.name = playerName
            rink.addChild(newEntity)
        }
        // Odstranit zaniklé
        for child in rink.children where child.name.hasPrefix("player_") {
            if let id = UInt8(child.name.dropFirst("player_".count)), !ids.contains(id) {
                child.removeFromParent()
            }
        }
    }
    
    private func createRinkEntity() -> ModelEntity {
        let renderer = RinkRenderer(config: config)
        
        // Vygenerování textury pro hřiště
        let rinkUIImage = renderer.render(size: CGSize(width: 2048, height: 1024))
        
        let mesh = MeshResource.generatePlane(width: 0.6, depth: 0.3, cornerRadius: 0.085)
        var material = SimpleMaterial()
        material.roughness = 0.15
        
        if let cgImage = rinkUIImage.cgImage {
            if let texture = try? TextureResource(image: cgImage, options: .init(semantic: .color)) {
                material.color = .init(texture: .init(texture))
            }
        }
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        // Přiřadíme jméno pro vyhledávání
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
}
