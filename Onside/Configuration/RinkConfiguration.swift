//
//  RinkConfiguration.swift
//  Onside
//
//  Created by Šimon Drda on 06.03.2026.
//

import CoreGraphics

struct RinkConfiguration {

    // MARK: - Rozmery kluziště (v metrech)

    var width: CGFloat = 60.0
    var height: CGFloat = 30.0
    var cornerRadius: CGFloat = 8.5

    // MARK: - Šířky čar (v metrech)

    var boardLineWidth: CGFloat = 0.12
    var goalLineWidth: CGFloat = 0.05
    var blueLineWidth: CGFloat = 0.30
    var centerLineWidth: CGFloat = 0.30
    var circleLineWidth: CGFloat = 0.05

    // MARK: - Polohy čar

    var goalLineDistanceFromEnd: CGFloat = 4.0
    var blueLineDistanceFromEnd: CGFloat = 17.25

    // MARK: - Středový kruh

    var centerCircleRadius: CGFloat = 4.5
    var centerCircleLineWidth: CGFloat = 0.05
    var centerDotRadius: CGFloat = 0.15

    // MARK: - Kruhy vhazování v pásmu

    var faceoffCircleRadius: CGFloat = 4.5
    var zoneFaceoffDistanceFromGoalLine: CGFloat = 6.0
    var faceoffLateralOffset: CGFloat = 7.0

    // MARK: - Body vhazování v neutrální zóně

    var neutralFaceoffDistanceFromBlueLine: CGFloat = 1.5

    // MARK: - Tečky vhazování

    var faceoffDotRadius: CGFloat = 0.15

    // MARK: - Rysky na kruzích vhazování

    var hashMarkLength: CGFloat = 0.60
    var hashMarkWidth: CGFloat = 0.05
    var hashMarkGap: CGFloat = 0.90

    // MARK: - Brankový prostor (crease)

    var creaseRadius: CGFloat = 1.83
    var creaseLineWidth: CGFloat = 0.05

    // MARK: - Rozhodcovský půlkruh

    var refereeCreaseRadius: CGFloat = 3.0
    var refereeCreaseLineWidth: CGFloat = 0.05

    // MARK: - Barvy

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

    // MARK: - Výchozí konfigurace (IIHF standard)

    static let standard = RinkConfiguration()
}
