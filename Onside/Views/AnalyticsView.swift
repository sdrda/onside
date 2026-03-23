//
//  AnalyticsView.swift
//  Onside
//
//  Created by Šimon Drda on 21.03.2026.
//

import SwiftUI

struct AnalyticsView: View {
    @State var viewModel: AnalyticsViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isGeneratingImage || viewModel.analyticsImage != nil {
                ZStack {
                    if let cgImage = viewModel.analyticsImage {
                        Image(decorative: cgImage, scale: 1.0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }

                    if viewModel.isGeneratingImage {
                        ProgressView()
                            .controlSize(.large)
                    }
                }
                .frame(maxHeight: 300)
                .padding()
            }

            List(viewModel.players, id: \.self) { playerID in
                HStack {
                    Text("Hráč #\(playerID)")
                        .font(.headline)

                    Spacer()

                    Button("Pohyb") {
                        viewModel.showMovement(for: playerID)
                    }

                    Button("Heatmapa") {
                        viewModel.generateHeatmap(for: playerID)
                    }
                }
            }
        }
        .navigationTitle("Analýza")
    }
}

