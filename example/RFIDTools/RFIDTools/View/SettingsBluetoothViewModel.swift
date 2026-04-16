//
//  SettingsBluetoothViewModel.swift
//  RFIDTools
//

import Combine
import RFIDManager
import SwiftUI

class SettingsBluetoothViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var bluetoothName: String = ""
    @Published var baudRate: Int = 115_200
    @Published var pinKey: String = ""
    @Published var keyboardLayout: Int = 0
    @Published var bluetoothMac: String = ""
    @Published var hidKeyInterval: String = ""
    @Published var bindAttribute: Bool = true
    @Published var connectionReadyTime: String = ""
    @Published var minConnectionTime: String = ""
    @Published var maxConnectionTime: String = ""
    @Published var minSendTime: String = ""
    @Published var keyboardService: Bool = true
    @Published var serialService: Bool = true
    
    // BluetoothInfo
    @Published var hardwareVersion: String = ""
    @Published var firmwareVersion: String = ""
    @Published var softwareVersion: String = ""
    @Published var manufacturerName: String = ""
    
    let baudRateList = [115_200, 460_800, 921_600]
    
    let keyboardLayoutList = [
        (value: 0, text: "US"),
        (value: 1, text: "DEU"),
        (value: 2, text: "FRA"),
        (value: 3, text: "ESP"),
        (value: 4, text: "POR"),
        (value: 5, text: "Italy"),
        (value: 6, text: "Belgian"),
    ]
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Page changes listening
        AppState.shared
            .$selectedPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPage in
                if AppState.shared.selectedPage == .SettingsBluetooth {
                    self?.getBluetoothParameter(false)
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    // MARK: - Bluetooth Parameter Functions
    
    func setBluetoothParameter() {
        let bluetoothParameter = BluetoothParameter(
            bluetoothName: bluetoothName,
            baudRate: baudRate,
            pinKey: pinKey,
            keyboardLayout: keyboardLayout,
            bluetoothMac: bluetoothMac,
            hidKeyInterval: Int(hidKeyInterval) ?? 0,
            bindAttribute: bindAttribute,
            connectionReadyTime: Int(connectionReadyTime) ?? -1,
            minConnectionTime: Int(minConnectionTime) ?? -1,
            maxConnectionTime: Int(maxConnectionTime) ?? -1,
            minSendTime: Int(minSendTime) ?? -1,
            keyboardService: keyboardService,
            serialService: serialService,
            bluetoothInfo: BluetoothParameter.BluetoothInfo(
                hardwareVersion: hardwareVersion,
                firmwareVersion: firmwareVersion,
                softwareVersion: softwareVersion,
                manufacturerName: manufacturerName
            )
        )
        
        let res = RFIDBleManager.shared.setBluetoothParameter(bluetoothParameter)
        toast.show(res.code == .success ? "Set Success" : res.message ?? "Set Success")
    }
    
    func getBluetoothParameter(_ showToast: Bool = true) {
        DispatchQueue.global().async {
            let res = RFIDBleManager.shared.getBluetoothParameter()
            
            DispatchQueue.main.async {
                if res.code == .success, let param = res.data as? BluetoothParameter {
                    self.bluetoothName = param.bluetoothName
                    self.baudRate = param.baudRate
                    self.pinKey = param.pinKey
                    self.keyboardLayout = param.keyboardLayout
                    self.bluetoothMac = param.bluetoothMac
                    self.hidKeyInterval = String(param.hidKeyInterval)
                    self.bindAttribute = param.bindAttribute
                    self.connectionReadyTime = String(param.connectionReadyTime)
                    self.minConnectionTime = String(param.minConnectionTime)
                    self.maxConnectionTime = String(param.maxConnectionTime)
                    self.minSendTime = String(param.minSendTime)
                    self.keyboardService = param.keyboardService
                    self.serialService = param.serialService
                    
                    // ble version info
                    self.hardwareVersion = param.bluetoothInfo.hardwareVersion
                    self.firmwareVersion = param.bluetoothInfo.firmwareVersion
                    self.softwareVersion = param.bluetoothInfo.softwareVersion
                    self.manufacturerName = param.bluetoothInfo.manufacturerName
                    
                    if showToast { toast.show("Get Success") }
                } else {
                    if showToast { toast.show(res.message ?? "Failure") }
                }
            }
        }
    }
    
    func removeBondedDevices() {
        let res = RFIDBleManager.shared.removeBondedDevices()
        toast.show(res.code == .success ? "Success" : res.message ?? "Failure")
    }
    
    func resetBluetooth() {
        let res = RFIDBleManager.shared.resetBluetooth()
        toast.show(res.code == .success ? "Success" : res.message ?? "Failure")
    }
}
