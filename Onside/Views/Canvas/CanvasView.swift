//
//  CanvasView.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

import SwiftUI

struct CanvasView: View {
    var onMove: (CGPoint, Float) -> Void
    var onLift: () -> Void
    
    var body: some View {
        #if os(iOS)
        PencilCaptureViewWrapper(onMove: onMove, onLift: onLift)
        #elseif os(macOS)
        MacPencilCaptureViewWrapper(onMove: onMove, onLift: onLift)
        #elseif(os(tvOS))
            EmptyView()
        #endif
    }
}
