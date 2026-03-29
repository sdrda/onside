//
//  LiveActivityManager.swift
//  Onside
//
//  Created by Šimon Drda on 29.03.2026.
//

import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {
    private var activity: Activity<RecordingAttributes>?

    func startLiveActivity(startDate: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = RecordingAttributes(startDate: startDate)
        let state = RecordingAttributes.ContentState(playerCount: 0)
        let content = ActivityContent(state: state, staleDate: nil)

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: content
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func updatePlayerCount(_ count: Int) {
        guard let activity else { return }

        let state = RecordingAttributes.ContentState(playerCount: count)
        let content = ActivityContent(state: state, staleDate: nil)

        Task {
            await activity.update(content)
        }
    }

    func stopLiveActivity() {
        guard let activity else { return }

        let state = RecordingAttributes.ContentState(playerCount: 0)
        let content = ActivityContent(state: state, staleDate: nil)

        Task {
            await activity.end(content, dismissalPolicy: .immediate)
        }
        self.activity = nil
    }
}
