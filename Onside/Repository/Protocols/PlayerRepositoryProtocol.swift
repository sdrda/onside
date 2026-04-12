//
//  PlayerRepositoryProtocol.swift
//  Onside
//
//  Created by Šimon Drda on 12.04.2026.
//

protocol PlayerRepositoryProtocol {
    func fetchPlayers() throws -> [Player]
    func addPlayer(_ player: Player)
    func deletePlayer(_ player: Player)
}
