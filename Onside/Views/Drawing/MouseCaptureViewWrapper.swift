//
//  MacPencilCaptureViewWrapper.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

#if os(macOS)
import SwiftUI
import AppKit

struct MouseCaptureViewWrapper: NSViewRepresentable {
    var onMove: (CGPoint, Float) -> Void
    var onLift: () -> Void

    func makeNSView(context: Context) -> MouseCaptureView {
        let view = MouseCaptureView()
        view.onMove = onMove
        view.onLift = onLift
        return view
    }

    func updateNSView(_ nsView: MouseCaptureView, context: Context) {
        nsView.onMove = onMove
        nsView.onLift = onLift
    }
}
#endif
