//
//  PlayerDataSource.swift
//  Onside
//
//  Created by Šimon Drda on 06.03.2026.
//

import Foundation

protocol PlayerDataSource: AnyObject {
    var players: [UInt8: PlayerPosition] { get }
}
