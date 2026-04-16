//
//  RFIDManager.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/16.
//

import Combine
import Foundation
import RFIDManager

class RFIDManager {
    private static var lastBeepTime: Date = .init(timeIntervalSince1970: 0)
    private static let beepDebounceInterval: TimeInterval = 0.06 // 60ms

    static func getKeyEventPublisher() -> AnyPublisher<RFIDKeyEvent, Never> {
        if AppState.shared.connectionType == .Bluetooth {
            return RFIDBleManager.shared.keyEventPublisher.eraseToAnyPublisher()
        } else {
            return RFIDUsbManager.shared.keyEventPublisher.eraseToAnyPublisher()
        }
    }

    static func getInstance() -> RFIDInterface {
        if AppState.shared.connectionType == .Bluetooth {
            return RFIDBleManager.shared as RFIDInterface
        } else {
            return RFIDUsbManager.shared as RFIDInterface
        }
    }

    static func triggerBeep(duration: Int = 40) {
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastBeepTime) < beepDebounceInterval {
            return
        }
        lastBeepTime = currentTime

        getInstance().triggerBeep(duration: duration)
    }
}
