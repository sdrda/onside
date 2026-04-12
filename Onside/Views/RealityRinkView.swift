//
//  RealityRinkView.swift
//  Onside
//

import SwiftUI
import RealityKit

import SwiftUI
import RealityKit

struct RealityRinkView: View {
    @State private var cachedRinkImage: CGImage? = nil
    @State private var rinkEntity: ModelEntity? = nil
    @State private var realityViewFrame: CGRect = .zero
    @State private var cameraEntity: Entity = Entity()
    
    @State private var drawingUtility = RinkDrawingUtility()

    let config: any RinkConfiguration
    var rinkViewModel: RinkViewModel

    @Binding var isDrawing: Bool

    init(isDrawing: Binding<Bool>, rinkViewModel: RinkViewModel, config: any RinkConfiguration = IIHFRinkConfiguration.standard) {
        self._isDrawing = isDrawing
        self.rinkViewModel = rinkViewModel
        self.config = config
        PlayerComponent.registerComponent()
        PlayerMovementSystem.registerSystem()
    }

    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .virtual

                let rink = await createRinkEntity()
                content.add(rink)
                self.rinkEntity = rink

                cameraEntity.components.set(PerspectiveCameraComponent())
                cameraEntity.look(at: .zero, from: SIMD3<Float>(0, 0.5, 0), relativeTo: nil)
                content.add(cameraEntity)

            } update: { content in
                guard let rink = findRink(in: content.entities) else { return }
                syncPlayers(on: rink)
            }
            .realityViewCameraControls(isDrawing ? .none : .orbit)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { realityViewFrame = geo.frame(in: .local) }
                        .onChange(of: geo.size) { _ in realityViewFrame = geo.frame(in: .local) }
                }
            )

            if isDrawing {
                InputCaptureView(
                    onMove: { screenPoint, force in
                        handlePencilInput(at: screenPoint, force: force)
                    },
                    onLift: {
                        drawingUtility.resetLift()
                    }
                )
                .onAppear {
                    drawingUtility.setupDrawingTextureIfNeeded(baseImage: cachedRinkImage)
                }
            }
        }
        .onChange(of: isDrawing) { _, newValue in
            if !newValue { drawingUtility.resetLift() }
        }
    }

    // MARK: - Pencil & UV výpočet

    private func handlePencilInput(at screenPoint: CGPoint, force: Float) {
        let uv = screenPointToRinkUV(screenPoint: screenPoint)
        guard let uv else { return }
        drawingUtility.draw(at: uv, force: force)
    }

    private func screenPointToRinkUV(screenPoint: CGPoint) -> CGPoint? {
        let viewWidth = Float(realityViewFrame.width)
        let viewHeight = Float(realityViewFrame.height)
        guard viewWidth > 0, viewHeight > 0 else { return nil }

        let normalizedDeviceX = (Float(screenPoint.x) / viewWidth) * 2 - 1
        let normalizedDeviceY = -((Float(screenPoint.y) / viewHeight) * 2 - 1)

        let fieldOfViewDegrees = cameraEntity.components[PerspectiveCameraComponent.self]?.fieldOfViewInDegrees ?? 60
        let tangentHalfFieldOfView = tan(fieldOfViewDegrees * .pi / 360)

        let rayDirectionInCameraSpace = SIMD3<Float>(
            normalizedDeviceX * (viewWidth / viewHeight) * tangentHalfFieldOfView,
            normalizedDeviceY * tangentHalfFieldOfView,
            -1
        )

        let cameraTransform = cameraEntity.transformMatrix(relativeTo: nil)
        let rotationMatrix = simd_float3x3(
            SIMD3(cameraTransform.columns.0.x, cameraTransform.columns.0.y, cameraTransform.columns.0.z),
            SIMD3(cameraTransform.columns.1.x, cameraTransform.columns.1.y, cameraTransform.columns.1.z),
            SIMD3(cameraTransform.columns.2.x, cameraTransform.columns.2.y, cameraTransform.columns.2.z)
        )
        let rayDirectionInWorldSpace = normalize(rotationMatrix * rayDirectionInCameraSpace)

        let cameraPosition = cameraEntity.position
        guard abs(rayDirectionInWorldSpace.y) > 0.0001 else { return nil }

        let distanceToPlane = -cameraPosition.y / rayDirectionInWorldSpace.y
        guard distanceToPlane > 0 else { return nil }

        let hitPoint = cameraPosition + rayDirectionInWorldSpace * distanceToPlane

        let rinkWidth: Float = 0.6
        let rinkDepth: Float = 0.3
        let textureU = hitPoint.x / rinkWidth + 0.5
        let textureV = 0.5 - hitPoint.z / rinkDepth

        guard (0...1).contains(textureU), (0...1).contains(textureV) else { return nil }

        return CGPoint(x: CGFloat(textureU), y: CGFloat(textureV))
    }

    // MARK: - Rink Entity

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
            drawingUtility.textureResource = texture
        }

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "RinkPlane"
        entity.collision = CollisionComponent(shapes: [.generateBox(width: 0.6, height: 0.001, depth: 0.3)])

        return entity
    }

    // MARK: - Player Sync

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
        let colors = rinkViewModel.playerColors
        let labels = rinkViewModel.playerLabels

        for playerID in ids {
            let playerName = "player_\(playerID)"
            if let existing = rink.findEntity(named: playerName) {
                if var comp = existing.components[PlayerComponent.self],
                   let pos = positions[playerID] {
                    comp.targetPosition = pos
                    existing.components.set(comp)
                }
                if let playerColor = colors[playerID],
                   var modelComp = existing.components[ModelComponent.self] {
                    #if os(macOS)
                    let nativeColor = NSColor(playerColor)
                    #elseif os(iOS)
                    let nativeColor = UIColor(playerColor)
                    #endif
                    modelComp.materials = [SimpleMaterial(color: nativeColor, isMetallic: false)]
                    existing.components.set(modelComp)
                }
            } else {
                let startPos = positions[playerID] ?? .zero
                let label = labels[playerID]
                let newEntity = createPlayerEntity(id: playerID, startPos: startPos, label: label)
                newEntity.name = playerName
                rink.addChild(newEntity)
            }
        }

        for child in rink.children where child.name.hasPrefix("player_") {
            if let id = UInt8(child.name.dropFirst("player_".count)), !ids.contains(id) {
                child.removeFromParent()
            }
        }
    }

    // MARK: - Player Entities

    private func createPlayerEntity(id: UInt8, startPos: SIMD3<Float>, label: String?) -> Entity {
        let height: Float = 0.02
        
        let cylinder = ModelEntity(
            mesh: MeshResource.generateCylinder(height: height, radius: 0.008),
            materials: [SimpleMaterial(color: .black, isMetallic: false)]
        )
        cylinder.position = startPos
        cylinder.components.set(PlayerComponent(targetPosition: startPos, playerID: id))

        if let label {
            let textMesh = MeshResource.generateText(
                label,
                extrusionDepth: 0.001,
                font: .systemFont(ofSize: 0.008, weight: .bold),
                alignment: .center
            )
            let textEntity = ModelEntity(mesh: textMesh, materials: [SimpleMaterial(color: .white, isMetallic: false)])
            let center = textEntity.visualBounds(relativeTo: nil).center
            
            textEntity.position = SIMD3<Float>(-center.x, height / 2 + 0.001, center.y)
            textEntity.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
            
            cylinder.addChild(textEntity)
        }

        return cylinder
    }

    private func emptyCGImage() -> CGImage {
        let ctx = CGContext(
            data: nil, width: 1, height: 1,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )!
        return ctx.makeImage()!
    }
}
