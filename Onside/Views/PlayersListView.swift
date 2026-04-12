//
//  PlayerListView.swift
//  Onside
//
//  Created by Šimon Drda on 05.04.2026.
//

import SwiftUI
import SwiftData

struct PlayerListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Player.name) private var players: [Player]

    @State private var showAddSheet = false
    @State private var playerToEdit: Player? = nil
    
    @State private var searchText: String = ""
    
    var filteredPlayers: [Player] {
        if searchText.isEmpty {
            return players
        } else {
            return players.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if players.isEmpty {
                    ContentUnavailableView(
                        "Žádní hráči",
                        systemImage: "person.3.fill",
                        description: Text("Přidej prvního hráče pomocí tlačítka +")
                    )
                } else {
                    List {
                        ForEach(filteredPlayers) { player in
                            PlayerRowView(player: player)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    playerToEdit = player
                                }
                        }
                        .onDelete(perform: deletePlayers)
                    }
                    .searchable(text: $searchText)
                }
            }
            .navigationTitle("Hráči")
            
            
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                #if os(iOS)
                if !players.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                }
                #endif
            }
        }
        // Přidat nového hráče
        .sheet(isPresented: $showAddSheet) {
            AddPlayerForm()
        }
        // Editovat existujícího hráče
        .sheet(item: $playerToEdit) { player in
            AddPlayerForm(player: player)
        }
    }

    private func deletePlayers(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(players[index])
            }
        }
    }
}

// MARK: - Player Row

private struct PlayerRowView: View {
    let player: Player

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name.isEmpty ? "Bez jména" : player.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text("Senzor: \(player.sensorId)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Číslo dresu
            Text("#\(player.jerseyNumber)")
                .font(.headline)
                .foregroundStyle(.orange)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PlayerListView()
        .modelContainer(for: Player.self)
        .tint(.orange)
}
