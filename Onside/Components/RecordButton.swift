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

    @State private var recordingStart: Date?
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?

    init(isRecording: Bool, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.isRecording = isRecording
        self.isDisabled = isDisabled
        self.action = action
    }

    private let size: CGFloat = 70
    private let ringWidth: CGFloat = 4

    var body: some View {
        VStack(spacing: 8) {
            if isRecording {
                Text(formattedElapsed)
                    .font(.system(.caption, design: .monospaced).weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.red.opacity(0.8), in: Capsule())
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Button(action: action) {
                ZStack {
                    Circle()
                        .stroke(.white, lineWidth: ringWidth)
                        .frame(width: size, height: size)

                    if isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.red)
                            .frame(width: size * 0.35, height: size * 0.35)
                    } else {
                        Circle()
                            .fill(.red)
                            .frame(width: size - ringWidth * 2 - 6,
                                   height: size - ringWidth * 2 - 6)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isRecording)
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1)
        }
        .animation(.easeInOut(duration: 0.2), value: isRecording)
        .onChange(of: isRecording) { _, recording in
            if recording {
                recordingStart = Date()
                elapsed = 0
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    if let start = recordingStart {
                        elapsed = Date().timeIntervalSince(start)
                    }
                }
            } else {
                timer?.invalidate()
                timer = nil
                recordingStart = nil
                elapsed = 0
            }
        }
    }

    private var formattedElapsed: String {
        let total = Int(elapsed)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
