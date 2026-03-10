//
//  RinkConfiguration.swift
//  Onside
//
//  Created by Šimon Drda on 06.03.2026.
//

import UIKit

struct RinkConfiguration {

    // MARK: - Rozmery kluziště (v metrech)

    /// Délka kluziště (osa X)
    var width: CGFloat = 60.0
    /// Šířka kluziště (osa Y)
    var height: CGFloat = 30.0
    /// Poloměr zaoblení rohů
    var cornerRadius: CGFloat = 8.5

    // MARK: - Šířky čar (v metrech)

    /// Šířka mantinelu (obrys kluziště)
    var boardLineWidth: CGFloat = 0.12
    /// Šířka brankové čáry
    var goalLineWidth: CGFloat = 0.05
    /// Šířka modré čáry
    var blueLineWidth: CGFloat = 0.30
    /// Šířka středové červené čáry
    var centerLineWidth: CGFloat = 0.30
    /// Šířka čáry kruhů vhazování a středového kruhu
    var circleLineWidth: CGFloat = 0.05

    // MARK: - Polohy čar (vzdálenost od mantinelu)

    /// Vzdálenost brankové čáry od mantinelu
    var goalLineDistanceFromEnd: CGFloat = 4.0
    /// Vzdálenost modré čáry od mantinelu
    var blueLineDistanceFromEnd: CGFloat = 17.25

    // MARK: - Středový kruh

    /// Poloměr středového kruhu
    var centerCircleRadius: CGFloat = 4.5
    /// Šířka čáry středového kruhu
    var centerCircleLineWidth: CGFloat = 0.05
    /// Poloměr středového bodu vhazování
    var centerDotRadius: CGFloat = 0.15

    // MARK: - Kruhy vhazování v pásmu (4 kruhy)

    /// Poloměr kruhů vhazování v pásmu
    var faceoffCircleRadius: CGFloat = 4.5
    /// Vzdálenost středu bodu vhazování od brankové čáry
    var zoneFaceoffDistanceFromGoalLine: CGFloat = 6.0
    /// Boční vzdálenost středu bodu vhazování od středové osy
    var faceoffLateralOffset: CGFloat = 7.0

    // MARK: - Body vhazování v neutrální zóně (4 body, bez kruhů)

    /// Vzdálenost bodů vhazování v neutrální zóně od modré čáry (dovnitř)
    var neutralFaceoffDistanceFromBlueLine: CGFloat = 1.5

    // MARK: - Body vhazování – tečka (platí pro všechna umístění)

    /// Poloměr bodu (tečky) vhazování
    var faceoffDotRadius: CGFloat = 0.15

    // MARK: - Rysky na kruzích vhazování

    /// Délka každé ryskovací čáry
    var hashMarkLength: CGFloat = 0.60
    /// Tloušťka ryskovací čáry
    var hashMarkWidth: CGFloat = 0.05
    /// Svislá mezera mezi horní a dolní ryskou na každé straně kruhu
    var hashMarkGap: CGFloat = 0.90

    // MARK: - Brankový prostor (crease)

    /// Poloměr oblouku brankového prostoru
    var creaseRadius: CGFloat = 1.83
    /// Tloušťka obrysu brankového prostoru
    var creaseLineWidth: CGFloat = 0.05

    // MARK: - Rozhodcovský půlkruh

    /// Poloměr rozhodcovského půlkruhu (u mantinelu na středové čáře)
    var refereeCreaseRadius: CGFloat = 3.0
    /// Tloušťka čáry rozhodcovského půlkruhu
    var refereeCreaseLineWidth: CGFloat = 0.05

    // MARK: - Barvy

    /// Barva ledu
    var iceColor: UIColor = UIColor(red: 0.93, green: 0.96, blue: 1.00, alpha: 1.0)
    /// Barva mantinelu
    var boardColor: UIColor = .black
    /// Barva brankové čáry
    var goalLineColor: UIColor = UIColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    /// Barva modré čáry
    var blueLineColor: UIColor = UIColor(red: 0.05, green: 0.20, blue: 0.75, alpha: 1.0)
    /// Barva středové červené čáry
    var centerLineColor: UIColor = UIColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    /// Barva kruhů vhazování a středového kruhu
    var circleColor: UIColor = UIColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    /// Barva bodů vhazování a středového bodu
    var dotColor: UIColor = UIColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    /// Výplňová barva brankového prostoru
    var creaseFillColor: UIColor = UIColor(red: 0.55, green: 0.78, blue: 0.98, alpha: 0.55)
    /// Barva obrysu brankového prostoru
    var creaseLineColor: UIColor = UIColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    /// Barva obrysu branky
    var goalColor: UIColor = UIColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)
    /// Barva rozhodcovského půlkruhu
    var refereeCreaseColor: UIColor = UIColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0)

    // MARK: - Výchozí konfigurace (IIHF standard)

    static let standard = RinkConfiguration()
}
