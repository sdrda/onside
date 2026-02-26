//
//  RinkView.swift
//  Onside
//
//  Created by Šimon Drda on 26.02.2026.
//

import SwiftUI
import SpriteKit

struct RinkView: View {
    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: makeScene(size: geometry.size))
                .ignoresSafeArea()
        }
    }
    
    /// SKScene creation
    private func makeScene(size: CGSize) -> SKScene {
        let scene = RinkScene(size: size)
        scene.scaleMode = .fill
        return scene
    }
}
        
