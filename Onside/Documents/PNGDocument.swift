//
//  PNGDocument.swift
//  Onside
//
//  Created by Šimon Drda on 21.03.2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct PNGDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.png] }
    
    let data: Data
    
    init(cgImage: CGImage) {
        let mutableData = NSMutableData()
        if let dest = CGImageDestinationCreateWithData(mutableData, UTType.png.identifier as CFString, 1, nil) {
            CGImageDestinationAddImage(dest, cgImage, nil)
            CGImageDestinationFinalize(dest)
        }
        self.data = mutableData as Data
    }
    
    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
