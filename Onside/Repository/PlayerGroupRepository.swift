//
//  GroupRepository.swift
//  Onside
//
//  Created by Šimon Drda on 12.04.2026.
//

import SwiftData
import Foundation

final class PlayerGroupRepository: PlayerGroupRepositoryProtocol {
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchGroups() throws -> [PlayerGroup] {
        let descriptor = FetchDescriptor<PlayerGroup>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor)
    }
    
    func addGroup(_ group: PlayerGroup) {
        context.insert(group)
        try? context.save()
    }
    
    func deleteGroup(_ group: PlayerGroup) {
        context.delete(group)
        try? context.save()
    }
}
