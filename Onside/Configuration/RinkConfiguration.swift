//
//  RinkConfiguration.swift
//  Onside
//
//  Created by Šimon Drda on 06.03.2026.
//

import CoreGraphics

protocol RinkConfiguration: Sendable {

    // MARK: - Rozměry kluziště (v metrech)

    var width: CGFloat { get }
    var height: CGFloat { get }
    var cornerRadius: CGFloat { get }

    // MARK: - Šířky čar (v metrech)

    var boardLineWidth: CGFloat { get }
    var goalLineWidth: CGFloat { get }
    var blueLineWidth: CGFloat { get }
    var centerLineWidth: CGFloat { get }
    var circleLineWidth: CGFloat { get }

    // MARK: - Polohy čar

    var goalLineDistanceFromEnd: CGFloat { get }
    var blueLineDistanceFromEnd: CGFloat { get }

    // MARK: - Středový kruh

    var centerCircleRadius: CGFloat { get }
    var centerCircleLineWidth: CGFloat { get }
    var centerDotRadius: CGFloat { get }

    // MARK: - Kruhy vhazování v pásmu

    var faceoffCircleRadius: CGFloat { get }
    var zoneFaceoffDistanceFromGoalLine: CGFloat { get }
    var faceoffLateralOffset: CGFloat { get }

    // MARK: - Body vhazování v neutrální zóně

    var neutralFaceoffDistanceFromBlueLine: CGFloat { get }

    // MARK: - Tečky vhazování

    var faceoffDotRadius: CGFloat { get }

    // MARK: - Rysky na kruzích vhazování

    var hashMarkLength: CGFloat { get }
    var hashMarkWidth: CGFloat { get }
    var hashMarkGap: CGFloat { get }

    // MARK: - Brankový prostor (crease)

    var creaseRadius: CGFloat { get }
    var creaseLineWidth: CGFloat { get }

    // MARK: - Rozhodcovský půlkruh

    var refereeCreaseRadius: CGFloat { get }
    var refereeCreaseLineWidth: CGFloat { get }

    // MARK: - Barvy

    var iceColor: CGColor { get }
    var boardColor: CGColor { get }
    var goalLineColor: CGColor { get }
    var blueLineColor: CGColor { get }
    var centerLineColor: CGColor { get }
    var circleColor: CGColor { get }
    var dotColor: CGColor { get }
    var creaseFillColor: CGColor { get }
    var creaseLineColor: CGColor { get }
    var goalColor: CGColor { get }
    var refereeCreaseColor: CGColor { get }
}

// MARK: - Výchozí konfigurace (IIHF standard)

struct IIHFRinkConfiguration: RinkConfiguration {

    var width: CGFloat = 60.0
    var height: CGFloat = 30.0
    var cornerRadius: CGFloat = 8.5

    var boardLineWidth: CGFloat = 0.12
    var goalLineWidth: CGFloat = 0.05
    var blueLineWidth: CGFloat = 0.30
    var centerLineWidth: CGFloat = 0.30
    var circleLineWidth: CGFloat = 0.05

    var goalLineDistanceFromEnd: CGFloat = 4.0
    var blueLineDistanceFromEnd: CGFloat = 17.25

    var centerCircleRadius: CGFloat = 4.5
    var centerCircleLineWidth: CGFloat = 0.05
    var centerDotRadius: CGFloat = 0.15

    var faceoffCircleRadius: CGFloat = 4.5
    var zoneFaceoffDistanceFromGoalLine: CGFloat = 6.0
    var faceoffLateralOffset: CGFloat = 7.0

    var neutralFaceoffDistanceFromBlueLine: CGFloat = 1.5

    var faceoffDotRadius: CGFloat = 0.15

    var hashMarkLength: CGFloat = 0.60
    var hashMarkWidth: CGFloat = 0.05
    var hashMarkGap: CGFloat = 0.90

    var creaseRadius: CGFloat = 1.83
    var creaseLineWidth: CGFloat = 0.05

    var refereeCreaseRadius: CGFloat = 3.0
    var refereeCreaseLineWidth: CGFloat = 0.05

    var iceColor: CGColor         = CGColor(red: 0.93, green: 0.96, blue: 1.00, alpha: 1.0)
    var boardColor: CGColor       = CGColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0)
    var goalLineColor: CGColor    = CGColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    var blueLineColor: CGColor    = CGColor(red: 0.05, green: 0.20, blue: 0.75, alpha: 1.0)
    var centerLineColor: CGColor  = CGColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    var circleColor: CGColor      = CGColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    var dotColor: CGColor         = CGColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    var creaseFillColor: CGColor  = CGColor(red: 0.55, green: 0.78, blue: 0.98, alpha: 0.55)
    var creaseLineColor: CGColor  = CGColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    var goalColor: CGColor        = CGColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    var refereeCreaseColor: CGColor = CGColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)

    static let standard = IIHFRinkConfiguration()
}
