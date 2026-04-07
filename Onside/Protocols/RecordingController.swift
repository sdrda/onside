//
//  RecordingController.swift
//  Onside
//

import Foundation

protocol RecordingController: Actor {
    func startRecording()
    func stopRecording()
    func isRecording() -> Bool
}
