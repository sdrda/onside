//
//  AddGroupForm.swift
//  Onside
//
//  Created by Šimon Drda on 06.04.2026.
//

import SwiftUI
import SwiftData

struct AddGroupForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Player.name) private var allPlayers: [Player]

    var group: PlayerGroup?

    @State private var name: String = ""
    @State private var selectedColor: Color = .orange
    @State private var selectedPlayerIDs: Set<PersistentIdentifier> = []

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Název") {
                    TextField("Název skupiny", text: $name)
                }

                Section("Barva") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(Self.colorOptions, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 36, height: 36)
                                .overlay {
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Hráči") {
                    if allPlayers.isEmpty {
                        Text("Nejdříve přidej hráče")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(allPlayers) { player in
                            HStack {
                                Image(systemName: selectedPlayerIDs.contains(player.persistentModelID) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedPlayerIDs.contains(player.persistentModelID) ? .orange : .secondary)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(player.name.isEmpty ? "Bez jména" : player.name)
                                        .font(.body)
                                    Text("#\(player.jerseyNumber) · Senzor: \(player.sensorId)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                togglePlayer(player)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(group == nil ? "Nová skupina" : "Upravit skupinu")
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
            if let group {
                name = group.name
                selectedPlayerIDs = Set((group.players ?? []).map(\.persistentModelID))
                if let hex = group.colorHex {
                    selectedColor = Self.color(from: hex)
                }
            }
        }
    }

    private func togglePlayer(_ player: Player) {
        let id = player.persistentModelID
        if selectedPlayerIDs.contains(id) {
            selectedPlayerIDs.remove(id)
        } else {
            selectedPlayerIDs.insert(id)
        }
    }

    private func save() {
        let hex = Self.hexString(from: selectedColor)
        let selected = allPlayers.filter { selectedPlayerIDs.contains($0.persistentModelID) }

        if let group {
            group.name = name
            group.colorHex = hex
            group.players = selected
        } else {
            let newGroup = PlayerGroup(name: name, colorHex: hex)
            newGroup.players = selected
            modelContext.insert(newGroup)
        }

        try? modelContext.save()
    }

    static let colorOptions: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal,
        .cyan, .blue, .indigo, .purple, .pink, .brown
    ]

    static func hexString(from color: Color) -> String {
        let resolved = color.resolve(in: EnvironmentValues())
        let r = Int(resolved.red * 255)
        let g = Int(resolved.green * 255)
        let b = Int(resolved.blue * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    static func color(from hex: String) -> Color {
        var rgb: UInt64 = 0
        Scanner(string: hex.replacingOccurrences(of: "#", with: "")).scanHexInt64(&rgb)
        return Color(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Player.self, PlayerGroup.self, configurations: config)
    
    return AddGroupForm()
        .modelContainer(container)
        .tint(.orange)
}
