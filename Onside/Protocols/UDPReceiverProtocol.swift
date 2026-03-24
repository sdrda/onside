//
//  UDPReceiverProtocol.swift
//  Onside
//
//  Created by Šimon Drda on 20.03.2026.
//

import Foundation

protocol UDPReceiverProtocol: Actor {
    func startReceiving() -> AsyncThrowingStream<UDPPacket, Error>
    func stopReceiving()
}
