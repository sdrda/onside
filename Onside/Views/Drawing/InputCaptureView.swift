//
//  CanvasView.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

import SwiftUI

struct InputCaptureView: View {
    var onMove: (CGPoint, Float) -> Void
    var onLift: () -> Void
    
    var body: some View {
        #if os(iOS)
        TouchCaptureViewWrapper(onMove: onMove, onLift: onLift)
        #elseif os(macOS)
        MouseCaptureViewWrapper(onMove: onMove, onLift: onLift)
        #endif
    }
}
