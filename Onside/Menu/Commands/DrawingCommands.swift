//
//  DrawingCommands.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

import SwiftUI

struct DrawingCommands: Commands {
    @FocusedBinding(\.isDrawingBinding) var isDrawing: Bool?
    
    var body: some Commands {
        CommandMenu("Kreslení") {
            Button(isDrawing == true ? "Vypnout kreslení" : "Zapnout kreslení") {
                isDrawing?.toggle()
            }
            .keyboardShortcut("d", modifiers: .command)
            .disabled(isDrawing == nil)
        }
    }
}
