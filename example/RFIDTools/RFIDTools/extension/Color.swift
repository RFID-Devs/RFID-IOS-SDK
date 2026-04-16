//
//  ColorUtil.swift
//  RFIDBleSDK
//
//  Created by zsg on 2024/4/26.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: alpha
        )
    }

    static var radarLight = Color(hex: 0xB9FAB6)
    static var radarDark = Color(hex: 0x056707)
}
