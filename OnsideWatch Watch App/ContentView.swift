//
//  ContentView.swift
//  OnsideWatch Watch App
//
//  Created by Šimon Drda on 08.03.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var session = WatchSessionManager.shared

    var body: some View {
        Text("Sup")
    }
}

#Preview {
    ContentView()
}
