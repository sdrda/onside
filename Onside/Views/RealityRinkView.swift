//
//  RealityRinkView.swift
//  Onside
//
//  Created by Šimon Drda on 10.03.2026.
//

import SwiftUI
import RealityKit

struct PlayerComponent: Component {
    var targetPosition: SIMD3<Float>
    var playerID: UInt8
}

class PlayerMovementSystem: System {
    private static let query = EntityQuery(where: .has(PlayerComponent.self))
    
    required init(scene: RealityKit.Scene) {}
    
    func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)
        
        for entity in context.scene.performQuery(Self.query) {
            guard let playerComp = entity.components[PlayerComponent.self] else { continue }
            
            let currentPosition = entity.position
            let targetPosition = playerComp.targetPosition
            
            // Plynulé "dojíždění" k cíli pomocí LERP
            let newPosition = simd_mix(currentPosition, targetPosition, SIMD3<Float>(repeating: min(1.0, 10.0 * deltaTime)))
            
            entity.position = newPosition
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
                    
                    // Kotva, která hledá vodorovnou plochu
                    let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: [0.5, 0.5]))
                    let rinkEntity = createRinkEntity()
                    
                    anchor.addChild(rinkEntity)
                    content.add(anchor)
                    
                } update: { content in
                    // Hledání hřiště pod kotvou
                    var rinkEntity: Entity? = nil
                    for entity in content.entities {
                        if entity.name == "RinkPlane" { rinkEntity = entity; break }
                        if let child = entity.children.first(where: { $0.name == "RinkPlane" }) { rinkEntity = child; break }
                    }
                    
                    if let rink = rinkEntity {
                        updatePlayers(on: rink)
                    }
                }
                
            } else {
                RealityView { content in
                    content.camera = .virtual
                    
                    let rinkEntity = createRinkEntity()
                    content.add(rinkEntity)
                    
                } update: { content in
                    // Hledání hřiště ve virtuálním prostoru
                    var rinkEntity: Entity? = nil
                    for entity in content.entities {
                        if entity.name == "RinkPlane" { rinkEntity = entity; break }
                        if let child = entity.children.first(where: { $0.name == "RinkPlane" }) { rinkEntity = child; break }
                    }
                    
                    if let rink = rinkEntity {
                        updatePlayers(on: rink)
                    }
                }
                .realityViewCameraControls(.orbit)
            }
        }
    }
    
    // MARK: - Společná logika pro pohyb a tvorbu hráčů
    private func updatePlayers(on rink: Entity) {
        for player in viewModel.players.values {
            // Převod fyzických dat (střed hřiště = 0,0) na metry v RealityKit
            let scale: Float = 0.01
            let targetX = Float(player.x) * scale
            let targetZ = Float(player.y) * scale
            let targetPos: SIMD3<Float> = [targetX, 0, targetZ]
            
            // Unikátní jméno pro vyhledání v RealityKitu
            let playerName = "player_\(player.id)"
            
            if let existingEntity = rink.findEntity(named: playerName) {
                // Hráč už existuje
                // Jen zaktualizujeme jeho cíl v komponentě
                
                var comp = existingEntity.components[PlayerComponent.self]!
                comp.targetPosition = targetPos
                existingEntity.components.set(comp)
                
            } else {
                // Hráč neexistuje
                // Vytvoříme ho a přidáme přímo na hřiště
                let newEntity = createPlayerEntity(data: player, startPos: targetPos)
                
                // Nastavíme jméno hráče pro příští vyhledání
                newEntity.name = playerName
                
                rink.addChild(newEntity)
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
    
    private func createPlayerEntity(data: PlayerPosition, startPos: SIMD3<Float>) -> Entity {
        // Zmenšené válce, aby proporčně seděly na menší kluziště
        let mesh = MeshResource.generateCylinder(height: 0.02, radius: 0.008)
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        entity.position = startPos
        
        // Přidání komponenty, aby ho systém okamžitě zaregistroval a posouval
        let comp = PlayerComponent(targetPosition: startPos, playerID: data.id)
        entity.components.set(comp)
        
        return entity
    }
}

#Preview {
    RealityRinkView(viewModel: DataViewModel())
}
