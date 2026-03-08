//
//  RinkRenderer.swift
//  Onside
//
//  Created by Šimon Drda on 08.03.2026.
//

import UIKit

/// Vygeneruje UIImage ledové plochy podle zadané RinkConfiguration.
/// Obrázek lze přímo předat jako texturu do SKSpriteNode.
struct RinkRenderer {
    let config: RinkConfiguration

    func render(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            let cgCtx = ctx.cgContext

            config.iceColor.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))

            if size.height > size.width {
                cgCtx.translateBy(x: 0, y: size.height)
                cgCtx.rotate(by: -.pi / 2)
                let landscapeSize = CGSize(width: size.height, height: size.width)
                draw(in: landscapeSize, cgCtx: cgCtx)
            } else {
                draw(in: size, cgCtx: cgCtx)
            }
        }
    }

    // MARK: - Hlavní vykreslovací sekvence

    private func draw(in size: CGSize, cgCtx: CGContext) {
        let s = Scale(size: size, config: config)

        drawIce(s)

        // Ořez do zaobléného obdélníku kluziště
        cgCtx.saveGState()
        rinkPath(s).addClip()

        drawCreaseFills(s)
        drawCenterLine(s)
        drawBlueLines(s)
        drawGoalLines(s)
        drawRefereeCrease(s)
        drawCenterCircle(s)
        drawCenterDot(s)
        drawFaceoffCircles(s)
        drawNeutralFaceoffDots(s)
        drawBoards(s)

        cgCtx.restoreGState()
    }

    // MARK: - Led (pozadí)

    private func drawIce(_ s: Scale) {
        config.iceColor.setFill()
        rinkPath(s).fill()
    }

    // MARK: - Brankový prostor (crease)

    private func drawCreaseFills(_ s: Scale) {
        let paths = creasePaths(s)
        config.creaseFillColor.setFill()
        paths.forEach { $0.fill() }

        config.creaseLineColor.setStroke()
        paths.forEach { path in
            path.lineWidth = s.lw(config.creaseLineWidth)
            path.stroke()
        }
    }

    private func creasePaths(_ s: Scale) -> [UIBezierPath] {
        let radius = s.r(config.creaseRadius)
        let cy = s.y(config.height / 2)

        // Levý brankový prostor – oblouk se otvírá doprava (ke středu)
        let leftCx = s.x(config.goalLineDistanceFromEnd)
        let leftPath = UIBezierPath()
        leftPath.addArc(withCenter: CGPoint(x: leftCx, y: cy),
                        radius: radius,
                        startAngle: -.pi / 2,
                        endAngle: .pi / 2,
                        clockwise: true)
        leftPath.close()

        // Pravý brankový prostor – oblouk se otvírá doleva (ke středu)
        let rightCx = s.x(config.width - config.goalLineDistanceFromEnd)
        let rightPath = UIBezierPath()
        rightPath.addArc(withCenter: CGPoint(x: rightCx, y: cy),
                         radius: radius,
                         startAngle: -.pi / 2,
                         endAngle: .pi / 2,
                         clockwise: false)
        rightPath.close()

        return [leftPath, rightPath]
    }

    // MARK: - Středová červená čára

    private func drawCenterLine(_ s: Scale) {
        let lineW = s.lw(config.centerLineWidth)
        let cx = s.x(config.width / 2)
        let rect = CGRect(x: cx - lineW / 2, y: 0, width: lineW, height: s.size.height)
        config.centerLineColor.setFill()
        UIBezierPath(rect: rect).fill()
    }

    // MARK: - Modré čáry

    private func drawBlueLines(_ s: Scale) {
        let lineW = s.lw(config.blueLineWidth)
        let positions: [CGFloat] = [
            s.x(config.blueLineDistanceFromEnd),
            s.x(config.width - config.blueLineDistanceFromEnd)
        ]
        config.blueLineColor.setFill()
        positions.forEach { cx in
            let rect = CGRect(x: cx - lineW / 2, y: 0, width: lineW, height: s.size.height)
            UIBezierPath(rect: rect).fill()
        }
    }

    // MARK: - Brankové čáry

    private func drawGoalLines(_ s: Scale) {
        let xPositions: [CGFloat] = [
            s.x(config.goalLineDistanceFromEnd),
            s.x(config.width - config.goalLineDistanceFromEnd)
        ]
        config.goalLineColor.setStroke()
        xPositions.forEach { cx in
            let path = UIBezierPath()
            path.move(to: CGPoint(x: cx, y: 0))
            path.addLine(to: CGPoint(x: cx, y: s.size.height))
            path.lineWidth = s.lw(config.goalLineWidth)
            path.stroke()
        }
    }

    // MARK: - Rozhodcovský půlkruh

    private func drawRefereeCrease(_ s: Scale) {
        let cx = s.x(config.width / 2)
        let radius = s.r(config.refereeCreaseRadius)

        // Horní mantinel – půlkruh dovnitř kluziště
        let topPath = UIBezierPath()
        topPath.addArc(withCenter: CGPoint(x: cx, y: 0),
                       radius: radius,
                       startAngle: 0,
                       endAngle: .pi,
                       clockwise: true)
        topPath.close()

        // Dolní mantinel – půlkruh dovnitř kluziště
        let botPath = UIBezierPath()
        botPath.addArc(withCenter: CGPoint(x: cx, y: s.size.height),
                       radius: radius,
                       startAngle: .pi,
                       endAngle: 0,
                       clockwise: true)
        botPath.close()

        config.refereeCreaseColor.setStroke()
        [topPath, botPath].forEach { path in
            path.lineWidth = s.lw(config.refereeCreaseLineWidth)
            path.stroke()
        }
    }

    // MARK: - Středový kruh

    private func drawCenterCircle(_ s: Scale) {
        let center = s.pt(config.width / 2, config.height / 2)
        let path = UIBezierPath(arcCenter: center,
                                radius: s.r(config.centerCircleRadius),
                                startAngle: 0, endAngle: 2 * .pi,
                                clockwise: true)
        path.lineWidth = s.lw(config.centerCircleLineWidth)
        config.circleColor.setStroke()
        path.stroke()
    }

    // MARK: - Středový bod vhazování

    private func drawCenterDot(_ s: Scale) {
        let center = s.pt(config.width / 2, config.height / 2)
        let path = UIBezierPath(arcCenter: center,
                                radius: s.r(config.centerDotRadius),
                                startAngle: 0, endAngle: 2 * .pi,
                                clockwise: true)
        config.dotColor.setFill()
        path.fill()
    }

    // MARK: - Kruhy vhazování v pásmu

    private func drawFaceoffCircles(_ s: Scale) {
        let leftX  = config.goalLineDistanceFromEnd + config.zoneFaceoffDistanceFromGoalLine
        let rightX = config.width - config.goalLineDistanceFromEnd - config.zoneFaceoffDistanceFromGoalLine
        let upperY = config.height / 2 - config.faceoffLateralOffset
        let lowerY = config.height / 2 + config.faceoffLateralOffset

        let positions: [CGPoint] = [
            CGPoint(x: leftX,  y: upperY),
            CGPoint(x: leftX,  y: lowerY),
            CGPoint(x: rightX, y: upperY),
            CGPoint(x: rightX, y: lowerY)
        ]

        positions.forEach { pos in
            let center = s.pt(pos.x, pos.y)

            // Kruh
            let circle = UIBezierPath(arcCenter: center,
                                      radius: s.r(config.faceoffCircleRadius),
                                      startAngle: 0, endAngle: 2 * .pi,
                                      clockwise: true)
            circle.lineWidth = s.lw(config.circleLineWidth)
            config.circleColor.setStroke()
            circle.stroke()

            // Rysky
            drawHashMarks(center: center, s: s)

            // Bod vhazování
            let dot = UIBezierPath(arcCenter: center,
                                   radius: s.r(config.faceoffDotRadius),
                                   startAngle: 0, endAngle: 2 * .pi,
                                   clockwise: true)
            config.dotColor.setFill()
            dot.fill()
        }
    }

    /// Kreslí 4 rysky na kruhu vhazování.
    /// Dvě rysky jsou na straně blízko mantinelu, dvě směřují dovnitř hřiště
    /// (horní a dolní okraj kruhu). Každý pár tvoří dvě svislé čáry vedle sebe.
    private func drawHashMarks(center: CGPoint, s: Scale) {
        let circleR = s.r(config.faceoffCircleRadius)
        let halfLen = s.y(config.hashMarkLength / 2)  // délka rysky – kolmo k mantinelu (osa Y)
        let halfGap = s.x(config.hashMarkGap / 2)     // mezera mezi čárami páru – podél osy X
        let lineW   = s.lw(config.hashMarkWidth)

        config.circleColor.setStroke()

        // Horní a dolní okraj kruhu (strana u mantinelu / strana dovnitř hřiště)
        for dy in [-circleR, circleR] {
            // Každý pár tvoří dvě svislé čáry: levá a pravá od středu
            for dx in [-halfGap, halfGap] {
                let midX = center.x + dx
                let midY = center.y + dy
                let path = UIBezierPath()
                path.move(to: CGPoint(x: midX, y: midY - halfLen))
                path.addLine(to: CGPoint(x: midX, y: midY + halfLen))
                path.lineWidth = lineW
                path.stroke()
            }
        }
    }

    // MARK: - Body vhazování v neutrální zóně

    private func drawNeutralFaceoffDots(_ s: Scale) {
        let inset  = config.blueLineDistanceFromEnd
                   + config.blueLineWidth / 2
                   + config.neutralFaceoffDistanceFromBlueLine
        let leftX  = inset
        let rightX = config.width - inset
        let upperY = config.height / 2 - config.faceoffLateralOffset
        let lowerY = config.height / 2 + config.faceoffLateralOffset

        let positions: [CGPoint] = [
            CGPoint(x: leftX,  y: upperY),
            CGPoint(x: leftX,  y: lowerY),
            CGPoint(x: rightX, y: upperY),
            CGPoint(x: rightX, y: lowerY)
        ]

        config.dotColor.setFill()
        positions.forEach { pos in
            let center = s.pt(pos.x, pos.y)
            let path = UIBezierPath(arcCenter: center,
                                    radius: s.r(config.faceoffDotRadius),
                                    startAngle: 0, endAngle: 2 * .pi,
                                    clockwise: true)
            path.fill()
        }
    }

    // MARK: - Mantinel (obrys)

    private func drawBoards(_ s: Scale) {
        // Dvojnásobná šířka: polovina tahu leží vně path a je ořezána clipem,
        // takže viditelná část uvnitř odpovídá přesně boardLineWidth.
        let path = rinkPath(s)
        path.lineWidth = s.lw(config.boardLineWidth) * 2
        config.boardColor.setStroke()
        path.stroke()
    }

    // MARK: - Helpers

    /// Zaoblený obdélník odpovídající tvaru kluziště
    private func rinkPath(_ s: Scale) -> UIBezierPath {
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: s.size),
                     cornerRadius: s.r(config.cornerRadius))
    }
}

// MARK: - Scale helper

/// Přepočítává metrické hodnoty na pixely pro danou velikost obrázku a konfiguraci.
private struct Scale {
    let size: CGSize
    let config: RinkConfiguration

    /// Poměr bodů/metr ve směru X
    var sx: CGFloat { size.width  / config.width  }
    /// Poměr bodů/metr ve směru Y
    var sy: CGFloat { size.height / config.height }

    /// Převod metrické hodnoty X (délka) na body
    func x(_ m: CGFloat) -> CGFloat { m * sx }
    /// Převod metrické hodnoty Y (šířka) na body
    func y(_ m: CGFloat) -> CGFloat { m * sy }

    /// Převod 2D bodu v metrech na pixel-souřadnice
    func pt(_ xm: CGFloat, _ ym: CGFloat) -> CGPoint {
        CGPoint(x: x(xm), y: y(ym))
    }

    /// Izotropní převod pro poloměry kruhů a rohů (průměr obou škálování)
    func r(_ m: CGFloat) -> CGFloat { m * (sx + sy) / 2 }

    /// Škálování tloušťky čar – používá menší z obou škálování, aby čáry nebyly příliš tlusté
    func lw(_ m: CGFloat) -> CGFloat { max(0.5, m * min(sx, sy)) }
}
