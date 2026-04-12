//
//  GroupRepositoryProtocol.swift
//  Onside
//
//  Created by Šimon Drda on 12.04.2026.
//

protocol PlayerGroupRepositoryProtocol {
    func fetchGroups() throws -> [PlayerGroup]
    func addGroup(_ group: PlayerGroup)
    func deleteGroup(_ group: PlayerGroup)
}
