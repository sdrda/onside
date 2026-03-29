//
//  OnsideWidgetExtensionLiveActivity.swift
//  OnsideWidgetExtension
//
//  Created by Šimon Drda on 29.03.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct OnsideWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct OnsideWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OnsideWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension OnsideWidgetExtensionAttributes {
    fileprivate static var preview: OnsideWidgetExtensionAttributes {
        OnsideWidgetExtensionAttributes(name: "World")
    }
}

extension OnsideWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: OnsideWidgetExtensionAttributes.ContentState {
        OnsideWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: OnsideWidgetExtensionAttributes.ContentState {
         OnsideWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: OnsideWidgetExtensionAttributes.preview) {
   OnsideWidgetExtensionLiveActivity()
} contentStates: {
    OnsideWidgetExtensionAttributes.ContentState.smiley
    OnsideWidgetExtensionAttributes.ContentState.starEyes
}
