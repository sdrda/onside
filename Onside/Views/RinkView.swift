//
//  RinkView.swift
//  Onside
//
//  Created by Šimon Drda on 26.02.2026.
//

import SwiftUI
import SpriteKit

struct RinkView: View {
    @State private var vm = DataViewModel()
    @State private var scene = RinkScene()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                SpriteView(scene: makeScene(size: geometry.size))
                    .ignoresSafeArea()

                PlayerListOverlay(players: Array(vm.players.values))
            }
        }
        .onAppear {
            scene.dataSource = vm
            vm.start()
        }
        .onDisappear {
            vm.stop()
        }
    }

    private func makeScene(size: CGSize) -> SKScene {
        scene.size = size
        scene.scaleMode = .fill
        return scene
    }
}
        
struct PlayerListOverlay: View {
    let players: [PlayerPosition]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hráči (\(players.count))")
                .font(.caption.bold())
                .foregroundStyle(.white)

            ForEach(players) { player in
                HStack(spacing: 8) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                    Text("ID \(player.id)  \(player.speed, specifier: "%.1f") j/s")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(10)
        .background(.black.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
    }
}
