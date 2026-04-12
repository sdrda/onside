//
//  RinkDrawingUtility.swift
//  Onside
//
//  Created by Šimon Drda on 11.04.2026.
//

import Foundation
import CoreGraphics
import RealityKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@MainActor
class RinkDrawingUtility {
    private var drawingContext: CGContext? = nil
    private var lastDrawPoint: CGPoint? = nil
    var textureResource: TextureResource?
    
    func setupDrawingTextureIfNeeded(baseImage: CGImage?) {
        guard drawingContext == nil else { return }
        
        let width = 2048
        let height = 1024
        
        guard let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }
        
        if let base = baseImage {
            ctx.draw(base, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        self.drawingContext = ctx
    }
    
    func draw(at uv: CGPoint, force: Float) {
        guard let ctx = drawingContext else { return }
        
        let w = CGFloat(ctx.width)
        let h = CGFloat(ctx.height)
        
        let x = uv.x * w
        let y = uv.y * h
        let radius = CGFloat(2 + force * 8)
        
        #if os(iOS)
        let drawColor = UIColor.red.withAlphaComponent(0.85).cgColor
        #elseif os(macOS)
        let drawColor = NSColor.red.withAlphaComponent(0.85).cgColor
        #endif
        
        if let last = lastDrawPoint {
            ctx.setStrokeColor(drawColor)
            ctx.setLineWidth(radius * 2)
            ctx.setLineCap(.round)
            ctx.move(to: last)
            ctx.addLine(to: CGPoint(x: x, y: y))
            ctx.strokePath()
        } else {
            ctx.setFillColor(drawColor)
            ctx.fillEllipse(in: CGRect(
                x: x - radius, y: y - radius,
                width: radius * 2, height: radius * 2
            ))
        }
        
        lastDrawPoint = CGPoint(x: x, y: y)
        
        if let image = ctx.makeImage(), let texture = textureResource {
            Task {
                try? await texture.replace(
                    withImage: image,
                    options: .init(semantic: .color)
                )
            }
        }
    }
    
    func resetLift() {
        lastDrawPoint = nil
    }
}
