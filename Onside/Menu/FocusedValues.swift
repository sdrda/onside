//
//  FocusedValues.swift
//  Onside
//
//  Created by Šimon Drda on 10.04.2026.
//

import SwiftUI

extension FocusedValues {
    var isDrawingBinding: Binding<Bool>? {
        get { self[IsDrawingKey.self] }
        set { self[IsDrawingKey.self] = newValue }
    }
    
    var selectedTab: Binding<AppTab>? {
            get { self[SelectedTabKey.self] }
            set { self[SelectedTabKey.self] = newValue }
    }
}
