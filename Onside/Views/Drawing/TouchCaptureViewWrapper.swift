//
//  PencilCaptureView.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

#if os(iOS)

import SwiftUI

struct TouchCaptureViewWrapper: UIViewRepresentable {
    var onMove: (CGPoint, Float) -> Void
    var onLift: () -> Void

    func makeUIView(context: Context) -> TouchCaptureView {
        let view = TouchCaptureView()
        view.onMove = onMove
        view.onLift = onLift
        return view
    }

    func updateUIView(_ uiView: TouchCaptureView, context: Context) {
        uiView.onMove = onMove
        uiView.onLift = onLift
    }
}

#endif
