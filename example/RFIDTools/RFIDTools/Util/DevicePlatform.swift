//
//  DevicePlatform.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/11.
//

#if canImport(UIKit)
    import UIKit
#endif

// MARK: - DevicePlatform

enum DevicePlatform {
    case mac
    case iPhone
    case iPad
}

extension DevicePlatform {
    static var current: DevicePlatform {
        #if os(iOS)
            switch UIDevice.current.userInterfaceIdiom {
            case .pad: return .iPad
            case .phone: return .iPhone
            case .mac: return .mac
            default: return .iPhone
            }
        #else
            return .mac
        #endif
    }

    static var isIPhone: Bool {
        current == .iPhone
    }

    static var isIPad: Bool {
        current == .iPad
    }

    static var isMac: Bool {
        current == .mac
    }
}
