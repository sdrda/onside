//
//  MacPencilCaptureView.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

#if os(macOS)
import AppKit

class MacPencilCaptureView: NSView {
    var onMove: ((CGPoint, Float) -> Void)?
    var onLift: (() -> Void)?

    override var isFlipped: Bool {
        return true
    }

    override func mouseDragged(with event: NSEvent) {
        let localPoint = convert(event.locationInWindow, from: nil)
        let pressure = Float(event.pressure)
        onMove?(localPoint, pressure)
    }
    
    override func mouseDown(with event: NSEvent) {
        let localPoint = convert(event.locationInWindow, from: nil)
        let pressure = Float(event.pressure)
        onMove?(localPoint, pressure)
    }

    override func mouseUp(with event: NSEvent) {
        onLift?()
    }
}

#endif
