//
//  AnalyticsViewModel.swift
//  Onside
//
//  Created by Šimon Drda on 21.03.2026.
//

import SwiftUI

@Observable
@MainActor
final class AnalyticsViewModel {
    private(set) var players: [UInt8] = []
    private(set) var analyticsImage: CGImage? = nil
    private(set) var isGeneratingImage = false

    @ObservationIgnored
    private let sessionStorage: any SessionStorageProtocol
    @ObservationIgnored
    private let rinkConfig: any RinkConfiguration

    init(sessionStorage: any SessionStorageProtocol, rinkConfig: any RinkConfiguration = IIHFRinkConfiguration.standard) {
        self.sessionStorage = sessionStorage
        self.rinkConfig = rinkConfig
        loadPlayers()
    }
    
    func loadPlayers() {
        Task {
            players = await sessionStorage.playerIDs()
        }
    }
    
    func showMovement(for playerID: UInt8) {
        Task {
            isGeneratingImage = true
            let points = await sessionStorage.heatmapPoints(for: playerID)
            let cfg = rinkConfig
            let image = await Task.detached(priority: .userInitiated) {
                MovementRenderer(config: cfg).render(points: points)
            }.value
            analyticsImage = image
            isGeneratingImage = false
        }
    }
    
    func generateHeatmap(for playerID: UInt8) {
        Task {
            isGeneratingImage = true
            let points = await sessionStorage.heatmapPoints(for: playerID)
            let cfg = rinkConfig
            let image = await Task.detached(priority: .userInitiated) {
                HeatmapRenderer(config: cfg).render(points: points)
            }.value
            analyticsImage = image
            isGeneratingImage = false
        }
    }
}
