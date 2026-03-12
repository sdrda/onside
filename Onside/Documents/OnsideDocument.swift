//
//  OnsideDocument.swift
//  Onside
//
//  Created by Šimon Drda on 12.03.2026.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var onside: UTType {
        UTType(exportedAs: "com.sdrda.onside")
    }
}

struct OnsideDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.onside] }

    var tracks: [SerializedTrack]

    init(tracks: [SerializedTrack]) {
        self.tracks = tracks
    }

    init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents ?? Data()
        tracks = try JSONDecoder().decode([SerializedTrack].self, from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(tracks)
        return FileWrapper(regularFileWithContents: data)
    }
}
