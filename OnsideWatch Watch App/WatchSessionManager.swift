//
//  WatchSessionManager.swift
//  Onside
//
//  Created by Šimon Drda on 08.03.2026.
//

import WatchConnectivity
import Foundation

@Observable
class WatchSessionManager: NSObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    var players: [PlayerPosition] = []

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let data = message["players"] as? Data,
              let decoded = try? JSONDecoder().decode([PlayerPosition].self, from: data) else { return }
        DispatchQueue.main.async {
            self.players = decoded
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
}
