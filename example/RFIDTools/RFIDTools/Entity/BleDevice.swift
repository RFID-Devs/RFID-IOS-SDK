//
//  BleDevice.swift
//  RFIDTools
//
//  Created by zsg on 2024/4/28.
//

import Foundation
import CoreBluetooth

struct BleDevice: Identifiable {
    var id: UUID

    var peripheral: CBPeripheral
    var rssi: Int

    init(id: UUID = UUID(), peripheral: CBPeripheral, rssi: Int) {
        self.id = peripheral.identifier
        self.peripheral = peripheral
        self.rssi = rssi
    }
}
