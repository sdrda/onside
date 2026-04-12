//
//  PlayerRepository.swift
//  Onside
//
//  Created by Šimon Drda on 12.04.2026.
//

import SwiftData
import Foundation

final class PlayerRepository: PlayerRepositoryProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchPlayers() throws -> [Player] {
        let descriptor = FetchDescriptor<Player>(sortBy: [SortDescriptor(\.jerseyNumber)])
        return try context.fetch(descriptor)
    }
    
    func addPlayer(_ player: Player) {
        context.insert(player)
        try? context.save()
    }
    
    func deletePlayer(_ player: Player) {
        context.delete(player)
        try? context.save()
    }
}
