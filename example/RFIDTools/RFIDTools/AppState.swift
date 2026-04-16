//
//  AppState.swift
//  RFIDTools
//
//  Created by zsg on 2024/4/28.
//

import Combine
import CoreBluetooth
import Foundation
import RFIDManager
#if os(iOS)
    import UIKit
#endif

// MARK: - AppState

final class AppState: ObservableObject {
    static let shared = AppState()

    static let KEY_LOCALE_IDENTIFIER = "locale_identifier"
    static let KEY_CONNECTION_TYPE = "connection_type"

    @Published var orientation: Orientation = .portrait
    @Published var localication: Localication = .en

    /// Peripheral connection type
    @Published var connectionType: RFIDConnectionType = .USB
    /// BLE/USB connection state
    @Published var connectState: RFIDConnectState = .disconnected

    @Published var selectedPage: AppPage = .Inventory
    @Published var tabConfig = TabConfigManager() {
        didSet {
            objectWillChange.send()
            bindTabConfig()
        }
    }

    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Get the locale of the system
        var id = Locale.current.identifier
        if let identifier = UserDefaults.standard.string(forKey: AppState.KEY_LOCALE_IDENTIFIER) {
            id = identifier
            print("identifier=\(identifier)")
        }
        localication = id.hasPrefix("zh") ? .zh_Hans : .en

        // Get the  connection type
        let connectType = UserDefaults.standard.integer(forKey: AppState.KEY_CONNECTION_TYPE)
        if DevicePlatform.isMac, let type = RFIDConnectionType(rawValue: connectType) {
            connectionType = type
        } else {
            connectionType = .Bluetooth
        }

        // macOS or iPad let orientation = .landscape
        if !DevicePlatform.isIPhone {
            orientation = .landscape
        }

        bindTabConfig()
        selectedPage = tabConfig.selectedPages[0]
    }

    private func bindTabConfig() {
        // 监听 tabConfig 内部变化，并转发到 AppState
        tabConfig.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
