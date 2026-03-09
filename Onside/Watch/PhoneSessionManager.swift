//
//  PhoneSessionManager.swift
//  Onside
//
//  Created by Šimon Drda on 08.03.2026.
//

import WatchConnectivity
import Foundation

class PhoneSessionManager: NSObject, WCSessionDelegate {
    static let shared = PhoneSessionManager()
    private var session: WCSession?
    private var lastSentTime: Date = .distantPast

    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func sendPlayerData(_ players: [PlayerPosition]) {
        let now = Date()
        guard now.timeIntervalSince(lastSentTime) >= 1.0 else { return }
        guard session?.isReachable == true else { return }
        lastSentTime = now

        // Encode do dat
        guard let encoded = try? JSONEncoder().encode(players) else { return }
        let message: [String: Any] = ["players": encoded]
        
        session?.sendMessage(message, replyHandler: nil, errorHandler: { error in
            print("Watch send error: \(error)")
        })
    }

    // WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
}
