//
//  PlayerValidator.swift
//  Onside
//
//  Created by Šimon Drda on 05.04.2026.
//

struct PlayerValidator {

    static func validateName(_ name: String) -> String? {
        if name.isEmpty {
            return "Zadej jméno"
        }
        return nil
    }

    static func validateSensorId(_ id: UInt8?) -> String? {
        if id == nil {
            return "Zadej ID senzoru"
        }
        return nil
    }
}
