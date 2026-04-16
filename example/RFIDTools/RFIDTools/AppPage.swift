//
//  AppPage.swift
//  RFIDTools
//
//  Created by zsg on 2025/5/20.
//

enum AppPage: String, CaseIterable, Hashable, Identifiable {
    var id: String { rawValue }

    case Inventory
    case Barcode
    case SettingsUHF = "UHF Settings"
    case SettingsMainboard = "Mainboard Settings"
    case SettingsBluetooth = "BT Settings"
    case Radar
    case Location
    case ReadWrite = "Read-Write"
    case LockKill = "Lock-Kill"
    case Upgrade
}
