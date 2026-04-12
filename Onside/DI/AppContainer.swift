//
//  AppContainer.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftData

final class AppContainer {

    let sessionStorage: any SessionStorageProtocol
    let dataProcessor: any DataProcessorProtocol
    let rinkConfiguration: any RinkConfiguration
    
    // SwiftData vrstva
    let modelContainer: ModelContainer
    let playerRepository: any PlayerRepositoryProtocol
    let playerGroupRepository: any PlayerGroupRepositoryProtocol

    init(
        sessionStorage: any SessionStorageProtocol = SessionStorage(),
        dataProcessor: (any DataProcessorProtocol)? = nil,
        rinkConfiguration: any RinkConfiguration = IIHFRinkConfiguration.standard
    ) {
        self.sessionStorage = sessionStorage
        self.dataProcessor = dataProcessor ?? DataProcessor(sessionStorage: sessionStorage)
        self.rinkConfiguration = rinkConfiguration
        
        do {
            self.modelContainer = try ModelContainer(for: Player.self, PlayerGroup.self)
            self.playerRepository = PlayerRepository(context: modelContainer.mainContext)
            self.playerGroupRepository = PlayerGroupRepository(context: modelContainer.mainContext)
        } catch {
            fatalError("Nepodařilo se inicializovat SwiftData kontejner: \(error)")
        }
    }
    
    func makeRinkViewModel() -> RinkViewModel {
        RinkViewModel(playerGroupRepository: playerGroupRepository, playerReopsitory: playerRepository, dataProcessor: dataProcessor, sessionStorage: sessionStorage)
    }
    
    func makeAnalyticsViewModel() -> AnalyticsViewModel {
        AnalyticsViewModel(sessionStorage: sessionStorage, rinkConfig: rinkConfiguration)
    }
}

