//
//  GroupListView.swift
//  Onside
//
//  Created by Šimon Drda on 06.04.2026.
//

import SwiftUI
import SwiftData

struct GroupListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlayerGroup.name) private var groups: [PlayerGroup]

    @State private var showAddSheet = false
    @State private var groupToEdit: PlayerGroup? = nil

    var body: some View {
        NavigationStack {
            Group {
                if groups.isEmpty {
                    ContentUnavailableView(
                        "Žádné skupiny",
                        systemImage: "person.3.fill",
                        description: Text("Přidej první skupinu pomocí tlačítka +")
                    )
                } else {
                    List {
                        ForEach(groups) { group in
                            GroupRowView(group: group)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    groupToEdit = group
                                }
                        }
                        .onDelete(perform: deleteGroups)
                    }
                }
            }
            .navigationTitle("Skupiny")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                #endif
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddGroupForm()
        }
        .sheet(item: $groupToEdit) { group in
            AddGroupForm(group: group)
        }
    }

    private func deleteGroups(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(groups[index])
            }
        }
    }
}

private struct GroupRowView: View {
    let group: PlayerGroup

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color(from: group.colorHex))
                .frame(width: 44, height: 44)
                .overlay {
                    Text("\(group.players?.count ?? 0)")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(group.name.isEmpty ? "Bez názvu" : group.name)
                    .font(.body)
                    .fontWeight(.medium)

                if (group.players ?? []).isEmpty {
                    Text("Žádní hráči")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text((group.players ?? []).map(\.name).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func color(from hex: String?) -> Color {
        guard let hex, !hex.isEmpty else { return .orange }
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
    
    return GroupListView()
        .modelContainer(container)
        .tint(.orange)
}
