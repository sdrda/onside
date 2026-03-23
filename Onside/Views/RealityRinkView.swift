//
//  RealityRinkView.swift
//  Onside
//
//  Created by Šimon Drda on 10.03.2026.
//

import SwiftUI
import RealityKit

struct RealityRinkView: View {
    @State private var cachedRinkImage: CGImage? = nil
    let config: any RinkConfiguration
    var rinkViewModel: RinkViewModel

    init(rinkViewModel: RinkViewModel, config: any RinkConfiguration = IIHFRinkConfiguration.standard) {
        self.rinkViewModel = rinkViewModel
        self.config = config
        PlayerComponent.registerComponent()
        PlayerMovementSystem.registerSystem()
    }

    var body: some View {
        RealityView { content in
            content.camera = .virtual
            content.add(await createRinkEntity())
        } update: { content in
            guard let rink = findRink(in: content.entities) else { return }
            syncPlayers(on: rink)
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

    private func syncPlayers(on rink: Entity) {
        let ids = rinkViewModel.playerIDs
        let positions = rinkViewModel.playerPositions

        // Spawn nových hráčů
        for playerID in ids {
            let playerName = "player_\(playerID)"
            if let existing = rink.findEntity(named: playerName) {
                // Update targetPosition na existující entitě
                if var comp = existing.components[PlayerComponent.self],
                   let pos = positions[playerID] {
                    comp.targetPosition = pos
                    existing.components.set(comp)
                }
            } else {
                let startPos = positions[playerID] ?? .zero
                let newEntity = createPlayerEntity(id: playerID, startPos: startPos)
                print(playerID)
                newEntity.name = playerName
                rink.addChild(newEntity)
            }
        }

        // Despawn hráčů, kteří zmizeli
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
                await RinkRenderer(config: cfg).render(size: CGSize(width: 2048, height: 1024))
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
        let parent = Entity()
        parent.position = startPos
        parent.components.set(PlayerComponent(targetPosition: startPos, playerID: id))

        // Cylinder body
        let cylinderMesh = MeshResource.generateCylinder(height: 0.02, radius: 0.008)
        let cylinderMaterial = SimpleMaterial(color: .black, isMetallic: false)
        let cylinder = ModelEntity(mesh: cylinderMesh, materials: [cylinderMaterial])
        parent.addChild(cylinder)

        // ID label centered on top face of cylinder
        let textMesh = MeshResource.generateText(
            "\(id)",
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.008, weight: .bold),
            alignment: .center
        )
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        let textBounds = textEntity.visualBounds(relativeTo: nil)
        let center = textBounds.center
        textEntity.position = SIMD3<Float>(-center.x, 0.011, center.y)
        textEntity.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
        parent.addChild(textEntity)

        return parent
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
