//
//  PencilCaptureView.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

#if os(iOS)

import SwiftUI

struct PencilCaptureViewWrapper: UIViewRepresentable {
    var onMove: (CGPoint, Float) -> Void
    var onLift: () -> Void

    func makeUIView(context: Context) -> PencilCaptureView {
        let view = PencilCaptureView()
        view.onMove = onMove
        view.onLift = onLift
        return view
    }

    func updateUIView(_ uiView: PencilCaptureView, context: Context) {
        uiView.onMove = onMove
        uiView.onLift = onLift
    }
}

#endif
