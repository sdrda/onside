//
//  RealityRinkView.swift
//  Onside
//

import SwiftUI
import RealityKit

struct RealityRinkView: View {
    @State private var cachedRinkImage: CGImage? = nil
    @State private var drawingContext: CGContext? = nil
    @State private var textureResource: TextureResource? = nil
    @State private var rinkEntity: ModelEntity? = nil
    @State private var lastDrawPoint: CGPoint? = nil

    // Uložíme si RealityView frame pro přepočet souřadnic
    @State private var realityViewFrame: CGRect = .zero

    let config: any RinkConfiguration
    var rinkViewModel: RinkViewModel
    @State private var cameraEntity: Entity = Entity()

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
                CanvasView(
                    onMove: { screenPoint, force in
                        handlePencilInput(at: screenPoint, force: force)
                    },
                    onLift: {
                        lastDrawPoint = nil
                    }
                )
                .onAppear { setupDrawingTextureIfNeeded() }
            }
        }
        .onChange(of: isDrawing) { _, newValue in
            if !newValue { lastDrawPoint = nil }
        }
    }

    // MARK: - Pencil & UV výpočet

    private func handlePencilInput(at screenPoint: CGPoint, force: Float) {
        // Přepočítáme souřadnice dotyku na plochu ledu
        let uv = screenPointToRinkUV(screenPoint: screenPoint)
        guard let uv else { return }

        drawOnTexture(at: uv, force: force)
    }

    /// Přepočítá 2D screen point na UV souřadnici rink plane (Y=0).
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

    // MARK: - Drawing do textury

    private func setupDrawingTextureIfNeeded() {
        guard drawingContext == nil else { return }

        let width = 2048
        let height = 1024

        guard let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }

        if let base = cachedRinkImage {
            ctx.draw(base, in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        drawingContext = ctx
    }

    private func drawOnTexture(at uv: CGPoint, force: Float) {
        guard let ctx = drawingContext else { return }

        let w = CGFloat(ctx.width)
        let h = CGFloat(ctx.height)

        let x = uv.x * w
        let y = uv.y * h
        let radius = CGFloat(2 + force * 8)

        #if os(iOS)
        let drawColor = UIColor.red.withAlphaComponent(0.85).cgColor
        #elseif os(macOS)
        let drawColor = NSColor.red.withAlphaComponent(0.85).cgColor
        #endif

        if let last = lastDrawPoint {
            ctx.setStrokeColor(drawColor)
            ctx.setLineWidth(radius * 2)
            ctx.setLineCap(.round)
            ctx.move(to: last)
            ctx.addLine(to: CGPoint(x: x, y: y))
            ctx.strokePath()
        } else {
            ctx.setFillColor(drawColor)
            ctx.fillEllipse(in: CGRect(
                x: x - radius, y: y - radius,
                width: radius * 2, height: radius * 2
            ))
        }

        lastDrawPoint = CGPoint(x: x, y: y)

        if let image = ctx.makeImage() {
            Task {
                try? await textureResource?.replace(
                    withImage: image,
                    options: .init(semantic: .color)
                )
            }
        }
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
            self.textureResource = texture
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

        for playerID in ids {
            let playerName = "player_\(playerID)"
            if let existing = rink.findEntity(named: playerName) {
                if var comp = existing.components[PlayerComponent.self],
                   let pos = positions[playerID] {
                    comp.targetPosition = pos
                    existing.components.set(comp)
                }
            } else {
                let startPos = positions[playerID] ?? .zero
                let newEntity = createPlayerEntity(id: playerID, startPos: startPos)
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

    private func createPlayerEntity(id: UInt8, startPos: SIMD3<Float>) -> Entity {
        let parent = Entity()
        parent.position = startPos
        parent.components.set(PlayerComponent(targetPosition: startPos, playerID: id))

        let height: Float = 0.02
        let cylinder = ModelEntity(
            mesh: MeshResource.generateCylinder(height: height, radius: 0.008),
            materials: [SimpleMaterial(color: .black, isMetallic: false)]
        )
        parent.addChild(cylinder)

        let textMesh = MeshResource.generateText(
            "\(id)",
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.008, weight: .bold),
            alignment: .center
        )
        let textEntity = ModelEntity(mesh: textMesh, materials: [SimpleMaterial(color: .white, isMetallic: false)])
        let center = textEntity.visualBounds(relativeTo: nil).center
        textEntity.position = SIMD3<Float>(-center.x, height / 2 + 0.001, center.y)
        textEntity.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
        parent.addChild(textEntity)

        return parent
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
