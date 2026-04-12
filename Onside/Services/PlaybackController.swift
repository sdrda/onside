//
//  PlaybackController.swift
//  Onside
//

import SwiftUI

@Observable
@MainActor
final class PlaybackController {
    private(set) var isActive: Bool = false
    private(set) var isPlaying: Bool = false
    var progress: Double = 0.0
    private(set) var timeRange: ClosedRange<Date>?
    
    /// Aktuální čas přehrávání (odvozeno z progressu a rozsahu)
    var currentTimestamp: Date? {
        guard let range = timeRange else { return nil }
        let duration = range.upperBound.timeIntervalSince(range.lowerBound)
        return range.lowerBound.addingTimeInterval(duration * progress)
    }
    
    /// Celková délka záznamu v sekundách
    var duration: TimeInterval? {
        guard let range = timeRange else { return nil }
        return range.upperBound.timeIntervalSince(range.lowerBound)
    }
    
    /// Aktuální čas přehrávání v sekundách
    var currentTime: TimeInterval? {
        guard let d = duration else { return nil }
        return d * progress
    }
    
    @ObservationIgnored
    private let sessionStorage: any PositionStore
    @ObservationIgnored
    private var playbackTask: Task<Void, Never>?
    
    /// Callback volaný při každé změně pozice (seek / tick) - pro update RealityKit
    var onPositionsChanged: (([UInt8: PlayerPosition]) -> Void)?
    
    init(sessionStorage: any PositionStore) {
        self.sessionStorage = sessionStorage
    }
    
    /// Načte časový rozsah ze storage (volat po zastavení nahrávání)
    func loadTimeRange() async {
        timeRange = await sessionStorage.timeRange()
    }
    
    /// Zapne režim přehrávání
    func enter() {
        guard timeRange != nil else { return }
        isActive = true
        progress = 0.0
        seek(to: 0.0)
    }
    
    /// Ukončí režim přehrávání
    func stop() {
        isActive = false
        isPlaying = false
        playbackTask?.cancel()
        playbackTask = nil
        progress = 0.0
    }
    
    /// Spustí / pozastaví automatické přehrávání
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    /// Posune přehrávání na daný progress (0.0–1.0)
    func seek(to newProgress: Double) {
        progress = min(max(newProgress, 0.0), 1.0)
        Task {
            guard let timestamp = currentTimestamp else { return }
            let positions = await sessionStorage.positions(at: timestamp)
            onPositionsChanged?(positions)
        }
    }
    
    // MARK: - Private
    
    private func play() {
        guard isActive, timeRange != nil else { return }
        if progress >= 1.0 {
            progress = 0.0
        }
        isPlaying = true
        playbackTask?.cancel()
        playbackTask = Task { [weak self] in
            guard let self else { return }
            let interval: TimeInterval = 1.0 / 15.0 // 15 Hz – odpovídá frekvenci dat
            while !Task.isCancelled && isPlaying && progress < 1.0 {
                guard let range = timeRange else { break }
                let totalDuration = range.upperBound.timeIntervalSince(range.lowerBound)
                let step = interval / totalDuration
                progress = min(progress + step, 1.0)
                seek(to: progress)
                try? await Task.sleep(for: .milliseconds(Int(interval * 1000)))
            }
            if progress >= 1.0 {
                isPlaying = false
            }
        }
    }
    
    private func pause() {
        isPlaying = false
        playbackTask?.cancel()
        playbackTask = nil
    }
}
