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

// Samotný dokument pro export/import
struct OnsideDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.onside] }
    
    var session: SessionData
    
    // Inicializátor, když vytváříme nový soubor pro uložení
    init(session: SessionData) {
        self.session = session
    }
    
    // Inicializátor pro načtení z existujícího souboru (import)
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.session = try JSONDecoder().decode(SessionData.self, from: data)
    }
    
    // Jednoduchá metoda, která zabalí tvoji strukturu do JSONu pro uložení
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        // encoder.outputFormatting = .prettyPrinted // Odkomentuj, pokud chceš JSON čitelný pro lidi
        let data = try encoder.encode(session)
        return FileWrapper(regularFileWithContents: data)
    }
}
