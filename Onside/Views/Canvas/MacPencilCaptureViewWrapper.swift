//
//  MacPencilCaptureViewWrapper.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

#if os(macOS)
import SwiftUI
import AppKit

struct MacPencilCaptureViewWrapper: NSViewRepresentable {
    var onMove: (CGPoint, Float) -> Void
    var onLift: () -> Void

    func makeNSView(context: Context) -> MacPencilCaptureView {
        let view = MacPencilCaptureView()
        view.onMove = onMove
        view.onLift = onLift
        return view
    }

    func updateNSView(_ nsView: MacPencilCaptureView, context: Context) {
        nsView.onMove = onMove
        nsView.onLift = onLift
    }
}
#endif
