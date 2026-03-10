//
//  ContentView.swift
//  Onside
//
//  Created by Šimon Drda on 06.02.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = DataViewModel()
    
    var body: some View {
        RealityRinkView(viewModel: viewModel)
            .onAppear {
                viewModel.start()
            }
            .onDisappear {
                viewModel.stop()
            }
    }
}

#Preview {
    ContentView()
}
