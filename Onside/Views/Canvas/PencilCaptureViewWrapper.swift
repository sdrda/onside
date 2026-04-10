//
//  PencilCaptureViewWrapper.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

#if os(iOS)

import UIKit

class PencilCaptureView: UIView {
    var onMove: ((CGPoint, Float) -> Void)?
    var onLift: (() -> Void)?

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touch.type == .pencil else { return }
        onMove?(touch.location(in: self), Float(touch.force))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onLift?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        onLift?()
    }
}

#endif
