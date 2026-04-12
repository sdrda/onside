//
//  AddPlayerForm.swift
//  Onside
//
//  Created by Šimon Drda on 05.04.2026.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddPlayerForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var player: Player?
    
    @State var name: String = String()
    @State var sensorIdText: String = ""
    @State var selectedNumber: Int = 1
    
    private var parsedSensorId: UInt8? {
        UInt8(sensorIdText)
    }
    
    var isFormValid: Bool {
        parsedSensorId != nil &&
        PlayerValidator.validateName(name) == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Informace") {
                    TextField("Senzor (0–255)", text: $sensorIdText)
                        #if os(iOS)
                        .keyboardType(.numberPad) // Na macOS neexistuje
                        #endif
                        
                    if !sensorIdText.isEmpty && parsedSensorId == nil {
                        Text("Zadej číslo 0–255")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    TextField("Jméno", text: $name)
                    if let error = PlayerValidator.validateName(name), !name.isEmpty {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Picker("Číslo", selection: $selectedNumber) {
                        ForEach(1...99, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                }
            }
            .toolbar {
                // Rovnou nahrazeno za sémantické placementy, jak jsme řešili minule
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(player == nil ? "Přidat hráče" : "Upravit hráče")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Uložit") {
                        withAnimation {
                            save()
                            dismiss()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .onAppear {
            if let player {
                name = player.name
                sensorIdText = String(player.sensorId)
                selectedNumber = player.jerseyNumber
            }
        }
    }
    
    private func save() {
        guard let sensorId = parsedSensorId else { return }

        if let player {
            player.sensorId = Int(sensorId)
            player.name = name
            player.jerseyNumber = selectedNumber
        } else {
            let newPlayer = Player(
                sensorId: Int(sensorId),
                name: name,
                jerseyNumber: selectedNumber
            )
            modelContext.insert(newPlayer)
        }

        try? modelContext.save()
    }
}

#Preview {
    AddPlayerForm()
        .modelContainer(for: [
            Player.self,
            PlayerGroup.self
        ])
        .tint(Color(.orange))
}
