//
//  OnsideDocument.swift
//  Onside
//
//  Created by Šimon Drda on 12.03.2026.
//

import SwiftUI
import UniformTypeIdentifiers
import UniformTypeIdentifiers

extension UTType {
    static var onside: UTType {
        UTType(exportedAs: "com.sdrda.onside")
    }
}

struct OnsideDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.onside] }
    
    var positions: [PlayerPosition]
    
    init(positions: [PlayerPosition]) {
        self.positions = positions
    }
    
    init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents ?? Data()
        positions = try JSONDecoder().decode([PlayerPosition].self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(positions)
        return FileWrapper(regularFileWithContents: data)
    }
}
