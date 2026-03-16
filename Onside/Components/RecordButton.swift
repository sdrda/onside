//
//  RecordButton.swift
//  Onside
//
//  Created by Šimon Drda on 13.03.2026.
//

import SwiftUI

struct RecordButton: View {
    let isRecording: Bool
    let isDisabled: Bool
    let action: () -> Void

    init(isRecording: Bool, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.isRecording = isRecording
        self.isDisabled = isDisabled
        self.action = action
    }

    private let lime = Color(red: 0.78, green: 1.0, blue: 0.0)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isRecording {
                    Circle()
                        .fill(.black.opacity(0.6))
                        .frame(width: 10, height: 10)
                }
                Text(isRecording ? "STOP" : "RECORD")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(isDisabled ? .gray : .black)
                    .animation(nil, value: isRecording)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .disabled(isDisabled)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24
            )
            .fill(isDisabled ? Color(white: 0.9) : (isRecording ? lime.opacity(0.7) : lime))
            .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        Spacer()
        RecordButton(isRecording: false) {}
        RecordButton(isRecording: true) {}
    }
    .ignoresSafeArea(edges: .bottom)
    .background(Color.gray.opacity(0.2))
}
