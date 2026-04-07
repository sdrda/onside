//
//  AddPlayerForm.swift
//  Onside
//
//  Created by Šimon Drda on 05.04.2026.
//

import SwiftUI
import SwiftData
import PhotosUI

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

struct AddPlayerForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var player: Player?
    
    @State var name: String = String()
    @State var sensorId: String = String()
    @State var selectedNumber: Int = 1
    @State var selectedItem: PhotosPickerItem? = nil
    @State var profileImage: Image? = nil
    @State var profileImageData: Data? = nil
    
    var isFormValid: Bool {
        PlayerValidator.validateSensorId(sensorId) == nil &&
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
                                guard let data = try? await newItem.loadTransferable(type: Data.self),
                                      let uiImage = UIImage(data: data) else { return }

                                // Ořízneme obrázek na čtverec
                                let cropped = uiImage.croppedToSquare()
                                
                                // Provedeme kompresy
                                profileImageData = cropped?.jpegData(compressionQuality: 0.8)
                                
                                // Uložíme profilový obrázek
                                profileImage = Image(uiImage: cropped ?? uiImage)
                            }
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                
                Section("Informace") {
                    TextField("Senzor", text: $sensorId)
                    if let error = PlayerValidator.validateSensorId(sensorId), !sensorId.isEmpty {
                        Text(error)
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Zrušit") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(player == nil ? "Přidat hráče" : "Upravit hráče")
                }
                ToolbarItem(placement: .topBarTrailing) {
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
                sensorId = player.sensorId
                selectedNumber = player.jerseyNumber
            }
        }
    }
    
    private func save() {
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
