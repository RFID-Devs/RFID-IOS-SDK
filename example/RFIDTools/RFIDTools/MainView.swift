//
//  MainView.swift
//  RFIDTools
//
//  Created by zsg on 2024/4/26.
//

import CoreBluetooth
import Foundation
import RFIDManager
import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var globalOverlay: GlobalOverlay
    @Environment(\.colorScheme) var colorScheme

    @State var peripheral: CBPeripheral? = nil

    private var tabs: [TabItem<AppPage>] {
        appState.tabConfig
            .selectedPages
            .filter { page in
                if DevicePlatform.isMac && page == .Radar {
                    return false
                }
                if appState.connectionType == .USB && page == .SettingsBluetooth {
                    return false
                }
                return true
            } 
            .map { TabItem(id: $0, title: $0.rawValue) }
    }

    @State private var showPageManager = false

    var body: some View {
        VStack {
            VStack {
                TopView(peripheral: peripheral)

                TabLayout(
                    tabs: tabs,
                    selection: $appState.selectedPage,
                    orientation: DevicePlatform.isIPhone ? .portrait : .landscape,
                    onConfig: { showPageManager = true }
                ) { page in
                    switch page {
                    case .Inventory: InventoryView()
                    case .Barcode: BarcodeView()
                    case .SettingsUHF: SettingsUhfView()
                    case .SettingsMainboard: SettingsMainboardView()
                    case .SettingsBluetooth: SettingsBluetoothView()
                    case .ReadWrite: ReadWriteView()
                    case .Radar: RadarView()
                    case .Location: LocationView()
                    case .LockKill: LockKillView()
                    case .Upgrade: UpgradeView()
                    }
                }
                Spacer()
            }
            .sheet(isPresented: $showPageManager) {
                PageManagerView(tabConfig: appState.tabConfig)
                    .environmentObject(appState)
                #if os(macOS)
                    .frame(minWidth: 500, minHeight: 500)
                #endif
            }
        }
        .onAppear {
            LogUtil.shared.showLog = true

            RFIDBleManager.shared.setConnectStateUpdateBlock { peripheral, state in
                print("---------- peripheral=\(peripheral), state=\(state)")
                self.peripheral = peripheral
                if state == .disconnected {
                    toast.show("\(peripheral.name ?? "") \("disconnected".localizedString(appState.localication))")
                    appState.connectState = .disconnected
                    globalOverlay.hide()
                } else if state == .connected {
                    //toast.show("\(peripheral.name ?? "") \("Connect Success".localizedString(appState.localication))")
                    appState.connectState = .connected
                    self.initialize()
                } else if state == .connecting {
                    appState.connectState = .connecting
                } else {
                    appState.connectState = .disconnecting
                }
            }

            // usb only effective on macos
            RFIDUsbManager.shared.setConnectStateUpdateBlock { state in
                appState.connectState = state
                if state == .connected {
                    appState.connectState = .connected
                    self.initialize()
                }
            }
        }
    }

    func initialize() {
        globalOverlay.showCustomView(dismissable: false) {
            ProgressView("Initializing")
                .progressViewStyle(CircularProgressViewStyle())
                .frame(width: 150)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .shadow(radius: 10)
                )
        }
        DispatchQueue.global().async {
            _ = RFIDManager.getInstance().initialize()
            DispatchQueue.main.async {
                globalOverlay.hide()
                toast.show("Success")
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppState.shared)
        .environmentObject(GlobalOverlay())
}
