//
//  RinkView.swift
//  Onside
//
//  Created by Šimon Drda on 16.03.2026.
//

import SwiftUI

struct RinkView: View {
    @State var rink: RinkViewModel

    var body: some View {
        VStack {
            Text("Players: \(rink.playerCount)")
            RealityRinkView(rinkViewModel: rink)
        }
    }
}
