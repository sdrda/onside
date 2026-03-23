//
//  AppContainer.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

final class AppContainer {

    let sessionStorage: any SessionStorageProtocol
    let dataProcessor: any DataProcessorProtocol
    let rinkConfiguration: any RinkConfiguration

    init(
        sessionStorage: any SessionStorageProtocol = SessionStorage(),
        dataProcessor: (any DataProcessorProtocol)? = nil,
        rinkConfiguration: any RinkConfiguration = IIHFRinkConfiguration.standard
    ) {
        self.sessionStorage = sessionStorage
        self.dataProcessor = dataProcessor ?? DataProcessor(sessionStorage: sessionStorage)
        self.rinkConfiguration = rinkConfiguration
    }
    
    func makeRinkViewModel() -> RinkViewModel {
        RinkViewModel(dataProcessor: dataProcessor, sessionStorage: sessionStorage)
    }
    
    func makeAnalyticsViewModel() -> AnalyticsViewModel {
        AnalyticsViewModel(sessionStorage: sessionStorage, rinkConfig: rinkConfiguration)
    }
}

