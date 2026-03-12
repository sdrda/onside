//
//  Recorder.swift
//  Onside
//
//  Created by Šimon Drda on 12.03.2026.
//

actor Recorder {
    var isRecording: Bool = false
    var playerPositions: [PlayerPosition] = []
    
    init() {
    }
    
    func startRecording() async throws {
        print("Recording...")
        isRecording = true
    }
    
    func stopRecording() async throws {
        print("Stopped recording...")
        isRecording = false
    }
    
    func recordPosition(_ position: PlayerPosition) {
        playerPositions.append(position)
    }
    
    func dumpAll() {
        playerPositions.removeAll()
    }
    
    public func getPositionCount() -> Int {
        return playerPositions.count
    }
}
