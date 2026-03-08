//
//  ConnectedPlayersView.swift
//  Onside
//
//  Created by Šimon Drda on 08.03.2026.
//

import SwiftUI
import SwiftData

struct ConnectedPlayersView: View {
    @Query var players: [ConnectedPlayerModel]
    @Environment(\.modelContext) private var context
    @State private var showAddSheet = false

    var body: some View {
        List {
            if players.isEmpty {
                ContentUnavailableView(
                    "No Connected Players",
                    systemImage: "person.2.slash",
                    description: Text("Players will appear here once connected.")
                )
            } else {
                ForEach(players) { player in
                    VStack(alignment: .leading) {
                        Text(player.name)
                            .font(.headline)
                        Text("Sensor ID: \(player.sensorId)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { context.delete(players[$0]) }
                }
            }
        }
        .navigationTitle("Connected Players")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddPlayerSheet()
        }
    }
}

struct AddPlayerSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var sensorIdText = ""

    var sensorId: Int? { Int(sensorIdText) }
    var isValid: Bool { !name.isEmpty && sensorId != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Player Info") {
                    TextField("Name", text: $name)
                    TextField("Sensor ID", text: $sensorIdText)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let id = sensorId {
                            context.insert(ConnectedPlayerModel(sensorId: id, name: name))
                        }
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
