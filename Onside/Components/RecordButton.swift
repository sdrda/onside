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

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isRecording {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                }
                Text(isRecording ? "STOP" : "REC")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(isDisabled ? .gray : .black)
                    .animation(nil, value: isRecording)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .disabled(isDisabled)
        .background(
            Capsule()
                .fill(isDisabled ? Color.onsideOrange.opacity(0.85) : Color.onsideOrange)
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
