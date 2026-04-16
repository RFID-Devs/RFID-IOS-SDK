//
//  BleConnectView.swift
//  RFIDTools
//
//  Created by zsg on 2024/4/28.
//

import CoreBluetooth
import Foundation
import RFIDManager
import SwiftUI

struct BleConnectView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var globalOverlay: GlobalOverlay

    @State var devices: [BleDevice] = []

    var body: some View {
        let bounds: CGRect = {
            #if os(macOS)
                NSApplication.shared.windows.first?.frame ?? .zero
            #else
                UIScreen.main.bounds
            #endif
        }()
        VStack {
            Spacer()
            Text("Select Device")
            List {
                ForEach(devices) { devce in
                    Button(action: {
                        RFIDBleManager.shared.connectPeripheral(
                            peripheral: devce.peripheral,
                            didFailToConnectBlock: { peripheral, error in
                                toast.show("\(peripheral.name ?? "") " 
                                    + "Connect Fail".localizedString(appState.localication)
                                    + "\n" + (error?.localizedDescription ?? "")
                                )
                            }
                        )
                        globalOverlay.hide()
                    }, label: {
                        HStack {
                            Text(devce.peripheral.name ?? "")
                            Spacer()
                            Text("\(devce.rssi)")
                        }
                    })
                }
            }
        }
        .frame(maxWidth: bounds.width * 0.8, maxHeight: bounds.height * 0.7)
        .background(colorScheme == .dark ? Color.gray : Color.white)
        .cornerRadius(10, antialiased: true)
        .onAppear {
            // Get the Bluetooth devices that are already connected to the ios system.
            let connectedList = RFIDBleManager.shared.retrieveConnectedPeripherals()
            for peripheral in connectedList {
                let device = BleDevice(id: peripheral.identifier, peripheral: peripheral, rssi: 0)
                devices.append(device)
            }

//            // Search for nearby Bluetooth devices, Callbacks can be set individually
//            RFIDBleManager.shared.setBlePeripheralsBlock { peripheral, advertisementData, rssi in
//                let device = BleDevice(id: peripheral.identifier, peripheral: peripheral, rssi: rssi.intValue)
//                devices.append(device)
//            }

            // also can be set in scanForPeripherals function
            RFIDBleManager.shared.scanForPeripherals { peripheral, advertisementData, RSSI in
                print("scanForPeripherals: \(String(describing: peripheral.name))  \(advertisementData.description)")

                // Judging Manufacturer Information, Requires Bluetooth software version (2.08+) support
                // The prefix of advertisementData["kCBAdvDataManufacturerData"] is 4720
                if let data = advertisementData["kCBAdvDataManufacturerData"] as? Data,
                   data.count >= 2 && data[0] == 0x47 && data[1] == 0x20
                {
                    print("kCBAdvDataManufacturerData: \(data)")
                } else {
                    // return   // Filter out devices that do not meet the requirements
                }

                if !devices.contains(where: { device in device.peripheral.name == peripheral.name }) {
                    devices.append(BleDevice(id: peripheral.identifier, peripheral: peripheral, rssi: RSSI.intValue))
                }
            }
        }
        .onDisappear {
            RFIDBleManager.shared.stopForPeripherals()
        }
    }
}

#Preview {
    VStack {
//        @State var list: [BleDevice] = [
//            BleDevice(peripheral: "123", rssi: 123),
//            BleDevice(peripheral: "abc", rssi: 123),
//            BleDevice(peripheral: "00121312312112132123233123123165161521515315213510", rssi: 123)
//        ]
        BleConnectView()
    }
}
