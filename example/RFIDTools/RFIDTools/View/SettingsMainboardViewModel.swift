//
//  SettingsMainboardViewModel.swift
//  RFIDTools
//

import RFIDManager
import SwiftUI
import Combine

class SettingsMainboardViewModel: ObservableObject {
    @Published var workMode: Int = 0
    @Published var keyMode: Int = 0
    @Published var idle: String = ""
    @Published var waitConnectTimeout: String = ""
    @Published var buzzerController = UserDrivenValue(true)
    @Published var rssiController = UserDrivenValue(true)

    
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Page changes listening
        AppState.shared
            .$selectedPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPage in
                if AppState.shared.selectedPage == .SettingsMainboard {
                    self?.getAllSettings()
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    // MARK: - Work Mode
    
    func setWorkMode() {
        let key = Data([1])
        let value = Data([UInt8(workMode)])
        let res = RFIDManager.getInstance().setMainBoardParameter(key: key, value: value)
        toast.show(res.code == .success ? "Set Success" : "Set Failure")
    }

    func getWorkMode(_ showToast: Bool = true) {
        let key = Data([1])
        let res = RFIDManager.getInstance().getMainBoardParameter(key: key)
        DispatchQueue.main.async {
            if res.code == .success, let data = res.data as? Data, data.count > 0 {
                self.workMode = Int(data[0])
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    // MARK: - Key Mode
    
    func setKeyMode() {
        let res = RFIDManager.getInstance().setKeyMode(keyMode)
        toast.show(res.code == .success ? "Set Success" : "Set Failure")
    }

    func getKeyMode(_ showToast: Bool = true) {
        let res = RFIDManager.getInstance().getKeyMode()
        DispatchQueue.main.async {
            if res.code == .success, let keymode = res.data as? Int {
                self.keyMode = keymode == 0 ? 0 : 1 // make sure only 0 and 1
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    // MARK: - Idle Timeout
    
    func setIdle() {
        guard let idleValue = Int(idle) else {
            toast.show("Idle must be between 3-65535 minutes")
            return
        }
        if idleValue < 3 || idleValue > 65535 {
            toast.show("Idle must be between 3-65535 minutes")
            return
        }
        let key = Data([13])
        let value = Data([UInt8(idleValue >> 8), UInt8(idleValue & 0xFF)])
        let res = RFIDManager.getInstance().setMainBoardParameter(key: key, value: value)
        toast.show(res.code == .success ? "Set Success" : "Set Failure")
    }

    func getIdle(_ showToast: Bool = true) {
        let key = Data([13])
        let res = RFIDManager.getInstance().getMainBoardParameter(key: key)
        DispatchQueue.main.async {
            if res.code == .success, let data = res.data as? Data, data.count >= 2 {
                let idleValue = (Int(data[0]) << 8) | Int(data[1])
                self.idle = "\(idleValue)"
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    // MARK: - Wait Connect Timeout
    
    func setWaitConnectTimeout() {
        guard let timeoutValue = Int(waitConnectTimeout) else {
            toast.show("Wait Connect Timeout must be between 1-65535 minutes")
            return
        }
        if timeoutValue < 1 || timeoutValue > 65535 {
            toast.show("Wait Connect Timeout must be between 1-65535 minutes")
            return
        }
        let key = Data([18])
        let value = Data([UInt8(timeoutValue >> 8), UInt8(timeoutValue & 0xFF)])
        let res = RFIDManager.getInstance().setMainBoardParameter(key: key, value: value)
        toast.show(res.code == .success ? "Set Success" : "Set Failure")
    }

    func getWaitConnectTimeout(_ showToast: Bool = true) {
        let key = Data([18])
        let res = RFIDManager.getInstance().getMainBoardParameter(key: key)
        DispatchQueue.main.async {
            if res.code == .success, let data = res.data as? Data, data.count >= 2 {
                let timeoutValue = (Int(data[0]) << 8) | Int(data[1])
                self.waitConnectTimeout = "\(timeoutValue)"
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    // MARK: - Buzzer
    
    func setBuzzer(_ flag: Bool, _ showToast: Bool = true) {
        let res = RFIDManager.getInstance().setBuzzer(flag)
        if showToast { toast.show(res.code == .success ? "Set Success" : "Set Failure") }
    }

    func getBuzzer(_ showToast: Bool = true) {
        let res = RFIDManager.getInstance().getBuzzer()
        DispatchQueue.main.async {
            if res.code == .success, let flag = res.data as? Bool {
                self.buzzerController.setValue(flag)
                // print("get getBuzzer = \(buzzer)")
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    // MARK: - Rssi
    
    func setRssi(_ flag: Bool, _ showToast: Bool = true) {
        // modify the real mainboard rssi parameter, please use：RFIDManager.getInstance().setMainBoardParameter(key: Data([24]), value: Data([1]))
        let res = RFIDManager.getInstance().setRssi(flag)
        if showToast { toast.show(res.code == .success ? "Set Success" : "Set Failure") }
    }

    func getRssi(_ showToast: Bool = true) {
        let res = RFIDManager.getInstance().getRssi()
        DispatchQueue.main.async {
            if res.code == .success, let flag = res.data as? Bool {
                self.rssiController.setValue(flag)
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }
    
    // MARK: - Reset Mainboard
    
    func resetMainboard() {
        let res = RFIDManager.getInstance().resetMainboard()
        toast.show(res.code == .success ? "Reset Success" : "Reset Failure")
        if res.code == .success {
            getAllSettings()
        }
    }
    
    // MARK: - Get All Settings
    
    func getAllSettings() {
        DispatchQueue.global().async {
            self.getWorkMode(false)
            self.getKeyMode(false)
            self.getIdle(false)
            self.getWaitConnectTimeout(false)
            self.getBuzzer(false)
            self.getRssi(false)
        }
    }
}
