//
//  RinkScene.swift
//  Onside
//
//  Created by Šimon Drda on 26.02.2026.
//

import SpriteKit

class RinkScene: SKScene, UIGestureRecognizerDelegate {
    var config: RinkConfiguration = .standard
    weak var dataSource: PlayerDataSource?
    private var playerSprites: [UInt8: SKShapeNode] = [:]
    private var lastTime: TimeInterval = 0

    var cameraNode = SKCameraNode()
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastTime == 0 ? 0 : currentTime - lastTime
        lastTime = currentTime

        guard let players = dataSource?.players else { return }

        let smoothing = CGFloat(1.0 - pow(0.01, deltaTime))
        for (id, pos) in players {
            let target = CGPoint(x: pos.x, y: pos.y)
            if let sprite = playerSprites[id] {
                sprite.position = lerp(from: sprite.position, to: target, t: smoothing)
            } else {
                let sprite = SKShapeNode(circleOfRadius: 2)
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
    
    override func didMove(to view: SKView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        // Set up the camera
        camera = cameraNode
        camera?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        camera?.setScale(0.4)
        
        backgroundColor = .white
        
        // Set up provisional rink
        let square = SKShapeNode(rectOf: CGSize(width: 200, height: 100))
        square.strokeColor = .black
        square.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let label = SKLabelNode(text: "Rink")
        label.fontColor = .black
        label.fontSize = 14
        label.verticalAlignmentMode = .center
        
        square.addChild(label)
        addChild(square)
    }
    
    /// Function for handling pan (camera movement)
    /// Must be an Objective-C function due to UIKit requirements
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let view = self.view else { return }
            
        if sender.state == .changed {
            let translation = sender.translation(in: view)
                
            // Get the current camera scale
            let currentZoom = cameraNode.xScale
                
            // Move the camera accounting for the current zoom level
            cameraNode.position = CGPoint(
                x: cameraNode.position.x - (translation.x * currentZoom),
                y: cameraNode.position.y + (translation.y * currentZoom)
            )
                
            sender.setTranslation(.zero, in: view)
        }
    }
    
    /// Function for handling pinch (zoom)
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .changed {
            let newScale = cameraNode.xScale * (1.0 / sender.scale)
            
            cameraNode.setScale(newScale)
            
            // Reset the gesture scale
            sender.scale = 1.0
        }
    }
    
    /// Allow simultaneous UIGestureRecognizer recognition
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
