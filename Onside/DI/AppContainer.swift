//
//  AppContainer.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

final class AppContainer {

    let sessionStorage: SessionStorage
    let dataProcessor: DataProcessor

    init() {
        self.sessionStorage = SessionStorage()
        self.dataProcessor = DataProcessor(sessionStorage: sessionStorage)
    }
    
    func connect() {
        Task { await dataProcessor.connect() }
    }
    
    func disconnect() {
        Task { await dataProcessor.disconnect() }
    }
    
    func makeRinkViewModel() -> RinkViewModel {
        RinkViewModel(dataProcessor: dataProcessor)
    }
}

