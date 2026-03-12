//
//  ContentView.swift
//  Onside
//
//  Created by Šimon Drda on 06.02.2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State var viewModel: DataViewModel
    @State var loading: Bool = false

    init() {
        self._viewModel = State(initialValue: DataViewModel())
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RealityRinkView(viewModel: viewModel)
                .onAppear { viewModel.start() }
                .onDisappear { viewModel.stop() }

            if loading {
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                ProgressView()
            }

            VStack(alignment: .trailing, spacing: 8) {
                Text("\(viewModel.recordedCount) positions")
                    .monospacedDigit()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                
                if viewModel.recordedCount > 0 && !viewModel.isRecording {
                    Button {
                        print("Ukládám")
                    } label: {
                        Text("Uložit")
                    }

                }
                Button(viewModel.isRecording ? "Stop" : "Record") {
                    viewModel.isRecording ? viewModel.stopRecording() : viewModel.startRecording()
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isRecording ? .red : .accentColor)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
