//
//  HeatmapRenderer.swift
//  Onside
//
//  Created by Šimon Drda on 21.03.2026.
//

import CoreGraphics
import Foundation

/// Generuje obrázek ledové plochy s heatmapou pohybu hráče.
struct HeatmapRenderer {
    let config: any RinkConfiguration
    
    /// Velikost výstupního obrázku v bodech.
    private let imageSize = CGSize(width: 2048, height: 1024)
    
    /// Poloměr Gaussova jádra v pixelech.
    private let kernelRadius: CGFloat = 40
    
    /// Vygeneruje CGImage hřiště s heatmapou.
    func render(points: [(x: CGFloat, y: CGFloat)]) -> CGImage? {
        guard let rinkImage = RinkRenderer(config: config).render(size: imageSize) else { return nil }
        
        let w = rinkImage.width
        let h = rinkImage.height
        
        guard let ctx = CGContext(
            data: nil,
            width: w,
            height: h,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
                      | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return nil }
        
        // Nakresli led
        ctx.draw(rinkImage, in: CGRect(x: 0, y: 0, width: w, height: h))
        
        // Vygeneruj heatmapu jako samostatný layer
        guard let heatLayer = renderHeatLayer(points: points, width: w, height: h) else {
            return ctx.makeImage()
        }
        
        // Překryj heatmapu s průhledností
        ctx.setAlpha(0.6)
        ctx.draw(heatLayer, in: CGRect(x: 0, y: 0, width: w, height: h))
        
        return ctx.makeImage()
    }
    
    // MARK: - Heat layer
    
    private func renderHeatLayer(points: [(x: CGFloat, y: CGFloat)], width: Int, height: Int) -> CGImage? {
        guard !points.isEmpty else { return nil }
        
        let fw = CGFloat(width)
        let fh = CGFloat(height)
        
        // Škálovací faktor: pozice hráčů jsou v metrech, obrázek v pixelech
        let sx = fw / config.width
        let sy = fh / config.height
        
        // Akumulační buffer intenzit
        var intensity = [Float](repeating: 0, count: width * height)
        let r = Int(kernelRadius)
        
        for point in points {
            // Pozice hráčů jsou od středu hřiště → posunout do souřadnic obrázku
            let px = Int((point.x + config.width / 2) * sx)
            // CG má Y nahoru, pozice hráčů mají Y dolů
            let py = height - Int((point.y + config.height / 2) * sy)
            
            let minX = max(0, px - r)
            let maxX = min(width - 1, px + r)
            let minY = max(0, py - r)
            let maxY = min(height - 1, py + r)
            
            guard minX <= maxX, minY <= maxY else { continue }
            
            for iy in minY...maxY {
                for ix in minX...maxX {
                    let dx = Float(ix - px)
                    let dy = Float(iy - py)
                    let dist2 = dx * dx + dy * dy
                    let sigma = Float(kernelRadius) * 0.5
                    let value = expf(-dist2 / (2 * sigma * sigma))
                    intensity[iy * width + ix] += value
                }
            }
        }
        
        // Normalizace
        let maxVal = intensity.max() ?? 1
        guard maxVal > 0 else { return nil }
        
        // Vykresli do RGBA
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for i in 0..<(width * height) {
            let t = min(intensity[i] / maxVal, 1.0)
            let (r, g, b) = heatColor(t)
            pixels[i * 4 + 0] = b   // BGRA (byteOrder32Little + premultipliedFirst)
            pixels[i * 4 + 1] = g
            pixels[i * 4 + 2] = r
            pixels[i * 4 + 3] = t > 0.01 ? UInt8(min(t * 2, 1.0) * 255) : 0
        }
        
        guard let provider = CGDataProvider(data: Data(pixels) as CFData),
              let image = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue
                                                 | CGBitmapInfo.byteOrder32Little.rawValue),
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
              ) else { return nil }
        
        return image
    }
    
    /// Mapuje intenzitu 0...1 na barvu (modrá → zelená → žlutá → červená).
    private func heatColor(_ t: Float) -> (UInt8, UInt8, UInt8) {
        let r: Float
        let g: Float
        let b: Float
        
        switch t {
        case 0..<0.25:
            let f = t / 0.25
            r = 0; g = f; b = 1.0 - f
        case 0.25..<0.5:
            let f = (t - 0.25) / 0.25
            r = 0; g = 1.0; b = 0
            _ = f // zelená zůstává
        case 0.5..<0.75:
            let f = (t - 0.5) / 0.25
            r = f; g = 1.0; b = 0
        default:
            let f = (t - 0.75) / 0.25
            r = 1.0; g = 1.0 - f; b = 0
        }
        
        return (UInt8(r * 255), UInt8(g * 255), UInt8(b * 255))
    }
}
