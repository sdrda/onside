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

    static func validateSensorId(_ id: String) -> String? {
        if id.isEmpty {
            return "Zadej ID senzoru"
        }
        if id.count < 5 {
            return "ID musí mít alespoň 5 znaků"
        }
        return nil
    }
}
