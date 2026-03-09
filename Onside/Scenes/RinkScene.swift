//
//  RinkScene.swift
//  Onside
//
//  Created by Šimon Drda on 26.02.2026.
//

import SpriteKit
import UIKit

class RinkScene: SKScene, UIGestureRecognizerDelegate {
    var config: RinkConfiguration = .standard
    weak var dataSource: PlayerDataSource?
    private var playerSprites: [UInt8: SKShapeNode] = [:]
    private var lastTime: TimeInterval = 0
    private var backgroundNode: SKSpriteNode?

    var cameraNode = SKCameraNode()

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        if backgroundNode == nil {
            setupRink()
            setupCamera()
        }
        setupGestures(in: view)
    }

    // MARK: - Setup

    private func setupRink() {
        backgroundColor = config.iceColor

        let image = RinkRenderer(config: config).render(size: size)
        let node = SKSpriteNode(texture: SKTexture(image: image), size: size)
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        node.zPosition = -1
        addChild(node)
        backgroundNode = node
    }

    private func setupCamera() {
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cameraNode.setScale(0.5)
    }

    private func setupGestures(in view: SKView) {
        // Zabráníme přidání duplicitních gesture recognizerů
        let existingTypes = view.gestureRecognizers?.map { type(of: $0) } ?? []
        if !existingTypes.contains(where: { $0 == UIPanGestureRecognizer.self }) {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            pan.delegate = self
            view.addGestureRecognizer(pan)
        }
        if !existingTypes.contains(where: { $0 == UIPinchGestureRecognizer.self }) {
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            pinch.delegate = self
            view.addGestureRecognizer(pinch)
        }
    }

    // MARK: - Herní smyčka

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastTime == 0 ? 0 : currentTime - lastTime
        lastTime = currentTime

        guard let players = dataSource?.players else { return }

        let smoothing = CGFloat(1.0 - pow(0.01, deltaTime))
        for (id, pos) in players {
            let target = config.toScene(point: CGPoint(x: pos.x, y: pos.y), sceneSize: size)
            if let sprite = playerSprites[id] {
                sprite.position = lerp(from: sprite.position, to: target, t: smoothing)
            } else {
                let sprite = SKShapeNode(circleOfRadius: 10)
                sprite.fillColor = .red
                sprite.strokeColor = .clear
                sprite.position = target
                addChild(sprite)
                playerSprites[id] = sprite
            }
        }
    }

    private func lerp(from: CGPoint, to: CGPoint, t: CGFloat) -> CGPoint {
        CGPoint(x: from.x + (to.x - from.x) * t,
                y: from.y + (to.y - from.y) * t)
    }

    // MARK: - Gesta (pan + pinch)

    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard sender.state == .changed, let view = self.view else { return }
        let translation = sender.translation(in: view)
        let zoom = cameraNode.xScale
        cameraNode.position = CGPoint(
            x: cameraNode.position.x - translation.x * zoom,
            y: cameraNode.position.y + translation.y * zoom
        )
        sender.setTranslation(.zero, in: view)
    }

    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        guard sender.state == .changed else { return }
        cameraNode.setScale(cameraNode.xScale / sender.scale)
        sender.scale = 1.0
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool { true }
}
