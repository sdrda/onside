//
//  RinkView.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI

struct RinkView: View {
    @Environment(\.container) private var container
    @State var rink: RinkViewModel
    let config: any RinkConfiguration

    var body: some View {
        ZStack {
            RealityRinkView(rinkViewModel: rink, config: config)

            VStack {
                Spacer()

                HStack(alignment: .bottom) {
                    RecordButton(isRecording: rink.isRecording) {
                        rink.toggleRecording()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Hřiště živě")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: AnalyticsView(viewModel: container.makeAnalyticsViewModel())) {
                    Label("Analýza", systemImage: "chart.bar.xaxis")
                }
            }
        }
    }
}
