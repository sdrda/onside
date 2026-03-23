//
//  RendererTests.swift
//  OnsideTests
//

import Testing
import Foundation
import CoreGraphics
@testable import Onside

struct RendererTests {

    private let config = IIHFRinkConfiguration.standard

    // MARK: - RinkRenderer

    @Test func rinkRendererProducesImage() {
        let renderer = RinkRenderer(config: config)
        let image = renderer.render(size: CGSize(width: 1024, height: 512))

        #expect(image != nil)
        #expect(image?.width ?? 0 > 0)
        #expect(image?.height ?? 0 > 0)
    }

    // MARK: - HeatmapRenderer

    @Test func heatmapRendererReturnsImageWithPoints() {
        let renderer = HeatmapRenderer(config: config)
        let points: [(x: CGFloat, y: CGFloat)] = [
            (x: 0, y: 0),
            (x: 5, y: 3),
            (x: -10, y: -5)
        ]
        let image = renderer.render(points: points)

        #expect(image != nil)
        #expect(image?.width ?? 0 > 0)
    }

    @Test func heatmapRendererReturnsImageWithEmptyPoints() {
        let renderer = HeatmapRenderer(config: config)
        // Prázdné body → vrátí jen led bez heatmapy
        let image = renderer.render(points: [])

        #expect(image != nil)
    }

    @Test func heatmapRendererHandlesOutOfBoundsPoints() {
        let renderer = HeatmapRenderer(config: config)
        let points: [(x: CGFloat, y: CGFloat)] = [
            (x: 999, y: 999),
            (x: -999, y: -999)
        ]
        // Neměl by crashnout
        let image = renderer.render(points: points)
        #expect(image != nil)
    }

    // MARK: - MovementRenderer

    @Test func movementRendererReturnsImageWithPoints() {
        let renderer = MovementRenderer(config: config)
        let points: [(x: CGFloat, y: CGFloat)] = [
            (x: -20, y: 0),
            (x: -10, y: 5),
            (x: 0, y: 0),
            (x: 10, y: -5),
            (x: 20, y: 0)
        ]
        let image = renderer.render(points: points)

        #expect(image != nil)
        #expect(image?.width ?? 0 > 0)
    }

    @Test func movementRendererHandlesSinglePoint() {
        let renderer = MovementRenderer(config: config)
        let points: [(x: CGFloat, y: CGFloat)] = [(x: 0, y: 0)]
        // Jeden bod → vrátí led bez čáry (guard points.count >= 2)
        let image = renderer.render(points: points)
        #expect(image != nil)
    }

    @Test func movementRendererHandlesEmptyPoints() {
        let renderer = MovementRenderer(config: config)
        let image = renderer.render(points: [])
        #expect(image != nil)
    }
}
