//
//  OnsideWidgetExtensionLiveActivity.swift
//  OnsideWidgetExtension
//
//  Created by Šimon Drda on 29.03.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct OnsideWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RecordingAttributes.self) { context in
            HStack(spacing: 16) {
                Image(systemName: "record.circle")
                    .font(.title2)
                    .foregroundStyle(.red)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Nahrávání session")
                        .font(.headline)
                    Text(context.attributes.startDate, style: .timer)
                        .font(.system(.title3, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("\(context.state.playerCount)")
                        .font(.system(.title, design: .rounded).bold())
                    Text("hráčů")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "record.circle")
                        .foregroundStyle(.red)
                        .font(.title2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(spacing: 2) {
                        Text("\(context.state.playerCount)")
                            .font(.system(.title3, design: .rounded).bold())
                        Text("hráčů")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("Nahrávání session")
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.startDate, style: .timer)
                        .font(.system(.title2, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            } compactLeading: {
                Image(systemName: "record.circle")
                    .foregroundStyle(.red)
            } compactTrailing: {
                Text(context.attributes.startDate, style: .timer)
                    .font(.system(.caption, design: .monospaced))
                    .frame(width: 48)
            } minimal: {
                Image(systemName: "record.circle")
                    .foregroundStyle(.red)
            }
            .keylineTint(.red)
        }
    }
}

#Preview("Notification", as: .content, using: RecordingAttributes(startDate: .now)) {
    OnsideWidgetExtensionLiveActivity()
} contentStates: {
    RecordingAttributes.ContentState(playerCount: 5)
    RecordingAttributes.ContentState(playerCount: 12)
}
