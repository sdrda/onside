//
//  RinkViewToolbar.swift
//  Onside
//
//  Created by Šimon Drda on 11.04.2026.
//

import SwiftUI

struct RinkViewToolbar: ToolbarContent {
    @Binding var isDrawing: Bool
    @Binding var inspectorPresented: Bool
    var viewModel: RinkViewModel
    
    @State private var isGroupPopoverPresented = false
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                isDrawing.toggle()
            } label: {
                Label(
                    isDrawing ? "Nekreslit" : "Kreslit",
                    systemImage: isDrawing ? "pencil.slash" : "pencil"
                )
                .contentTransition(.symbolEffect(.replace))
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                isGroupPopoverPresented.toggle()
            } label: {
                Label("Skupiny", systemImage: "person.3")
            }
            .popover(isPresented: $isGroupPopoverPresented) {
                VStack(alignment: .leading, spacing: 16) {
                    let groups = viewModel.fetchGroups()
                    if groups.isEmpty {
                        Text("Žádné skupiny")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(groups, id: \.persistentModelID) { group in
                            Button {
                                viewModel.toggleGroup(group)
                            } label: {
                                HStack {
                                    Text(group.name)
                                        .foregroundColor(.primary)
                                    Spacer(minLength: 20)
                                    Image(systemName: viewModel.isGroupActive(group) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(viewModel.isGroupActive(group) ? .blue : .gray)
                                }
                            }
                        }
                    }
                }
                .padding()
                .presentationCompactAdaptation(.popover)
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    inspectorPresented.toggle()
                }
            } label: {
                Label(
                    inspectorPresented ? "Zavřít" : "Detail hráčů",
                    systemImage: inspectorPresented ? "xmark.circle.fill" : "person.circle"
                )
                .symbolVariant(.fill)
                .contentTransition(.symbolEffect(.replace))
            }
        }
    }
}
