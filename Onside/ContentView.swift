//
//  ContentView.swift
//  Onside
//
//  Created by Šimon Drda on 06.02.2026.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var vm = DataViewModel()

    var body: some View {
        VStack {
            Text("UDP Packets")
            Text(vm.packets.count.description)
            List(vm.packets, id: \.timestamp) { packet in
                Text(packet.rawBytes.map { String(format: "%02X", $0) }.joined(separator: " "))
                    .font(.system(.caption, design: .monospaced))
            }
            .onAppear { vm.start() }
            .onDisappear { vm.stop() }
        }
    }
}

#Preview {
    ContentView()
}
