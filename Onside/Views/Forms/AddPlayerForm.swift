//
//  AddPlayerForm.swift
//  Onside
//
//  Created by Šimon Drda on 05.04.2026.
//

import SwiftUI
import SwiftData
import PhotosUI

#if os(iOS)
import UIKit

extension UIImage {
    func croppedToSquare() -> UIImage? {
        let side = min(size.width, size.height)
        let origin = CGPoint(
            x: (size.width - side) / 2,
            y: (size.height - side) / 2
        )
        let cropRect = CGRect(origin: origin, size: CGSize(width: side, height: side))
        
        guard let cgImage = cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}
#elseif os(macOS)
import AppKit

extension NSImage {
    func croppedToSquare() -> NSImage? {
        let side = min(size.width, size.height)
        let rect = NSRect(x: (size.width - side) / 2, y: (size.height - side) / 2, width: side, height: side)
        let img = NSImage(size: NSSize(width: side, height: side))
        img.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: img.size), from: rect, operation: .copy, fraction: 1.0)
        img.unlockFocus()
        return img
    }
    
    // NSImage nemá v základu jpegData(), musíme to přidat
    func jpegData(compressionQuality: CGFloat) -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
}
#endif

struct AddPlayerForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var player: Player?
    
    @State var name: String = String()
    @State var sensorIdText: String = ""
    @State var selectedNumber: Int = 1
    @State var selectedItem: PhotosPickerItem? = nil
    @State var profileImage: Image? = nil
    @State var profileImageData: Data? = nil
    
    private var parsedSensorId: UInt8? {
        UInt8(sensorIdText)
    }
    
    var isFormValid: Bool {
        parsedSensorId != nil &&
        PlayerValidator.validateName(name) == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section() {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(.separator, lineWidth: 0.5))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            guard let newItem else { return }
                            Task {
                                guard let data = try? await newItem.loadTransferable(type: Data.self) else { return }
                                
                                #if os(iOS)
                                guard let uiImage = UIImage(data: data) else { return }
                                let cropped = uiImage.croppedToSquare()
                                profileImageData = cropped?.jpegData(compressionQuality: 0.8)
                                profileImage = Image(uiImage: cropped ?? uiImage)
                                
                                #elseif os(macOS)
                                guard let nsImage = NSImage(data: data) else { return }
                                let cropped = nsImage.croppedToSquare()
                                profileImageData = cropped?.jpegData(compressionQuality: 0.8)
                                profileImage = Image(nsImage: cropped ?? nsImage)
                                #endif
                            }
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                
                Section("Informace") {
                    TextField("Senzor (0–255)", text: $sensorIdText)
                        #if os(iOS)
                        .keyboardType(.numberPad) // Na macOS neexistuje
                        #endif
                        
                    if !sensorIdText.isEmpty && parsedSensorId == nil {
                        Text("Zadej číslo 0–255")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    TextField("Jméno", text: $name)
                    if let error = PlayerValidator.validateName(name), !name.isEmpty {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Picker("Číslo", selection: $selectedNumber) {
                        ForEach(1...99, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                }
            }
            .toolbar {
                // Rovnou nahrazeno za sémantické placementy, jak jsme řešili minule
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(player == nil ? "Přidat hráče" : "Upravit hráče")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Uložit") {
                        withAnimation {
                            save()
                            dismiss()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .onAppear {
            if let player {
                name = player.name
                sensorIdText = String(player.sensorId)
                selectedNumber = player.jerseyNumber
            }
        }
    }
    
    private func save() {
        guard let sensorId = parsedSensorId else { return }
        let photoUrl = savePhoto()

        if let player {
            player.sensorId = sensorId
            player.name = name
            player.jerseyNumber = selectedNumber
            if let photoUrl {
                player.photoUrl = photoUrl
            }
        } else {
            let newPlayer = Player(
                sensorId: sensorId,
                name: name,
                jerseyNumber: selectedNumber,
                photoUrl: photoUrl
            )
            modelContext.insert(newPlayer)
        }

        try? modelContext.save()
    }

    private func savePhoto() -> URL? {
        guard let profileImageData else { return nil }

        let fileName = UUID().uuidString + ".jpg"
        let url = URL.documentsDirectory.appending(path: fileName)

        do {
            try profileImageData.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}

#Preview {
    AddPlayerForm()
        .modelContainer(for: [
            Player.self,
            PlayerGroup.self
        ])
        .tint(Color(.orange))
}
