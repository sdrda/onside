//
//  UDPPacket.swift
//  Onside
//
//  Created by Šimon Drda on 24.03.2026.
//

import Foundation

struct UDPPacket: Sendable {
    let timestamp: Date
    let rawBytes: Data
}
