//
//  SettingsUhfViewModel.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/11.
//

import Combine
import RFIDManager
import SwiftUI

class SettingsUhfViewModel: ObservableObject {
    @Published var frequency: RFIDFrequency = .China2
    @Published var power = 30
    @Published var antennaStates: [Bool] = [true, false, false, false]
    @Published var showAntennaStates: Bool = false
    @Published var rfLink: RFIDRFLink = .PR_ASK_Miller8_160KHz
    @Published var inventoryBank: RFIDMemoryBank.InventoryBank = .EPC
    @Published var offset: String = "0"
    @Published var length: String = "6"
    @Published var session: RFIDGen2.QuerySession = .S0
    @Published var target: RFIDGen2.QueryTarget = .A
    @Published var fastIDController = UserDrivenValue(false)
    @Published var tagFocusController = UserDrivenValue(false)

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Page changes listening
        AppState.shared
            .$selectedPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPage in
                if AppState.shared.selectedPage == .SettingsUHF {
                    self?.getAllSettings()
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    // MARK: RFID function

    func setFrequency() {
        let res = RFIDManager.getInstance().setFrequency(frequency.rawValue)
        toast.show(res.code == .success ? "Set Success" : "Set Failure")
    }

    func getFrequency(_ showToast: Bool = true) {
        let res = RFIDManager.getInstance().getFrequency()
        DispatchQueue.main.async {
            if res.code == .success, let fre = RFIDFrequency(rawValue: res.data as! Int) {
                self.frequency = fre
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    func setPower() {
        let res = RFIDManager.getInstance().setPower(power)
        toast.show(res.code == .success ? "Set Success" : "Set Failure")
    }

    func getPower(_ showToast: Bool = true) {
        let res = RFIDManager.getInstance().getPower()
        DispatchQueue.main.async {
            if res.code == .success, let value = res.data as? Int {
                self.power = value
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    // MARK: Antenna States

    func setAntennaStates() {
        let antennaStates = [
            1: antennaStates[0], 
            2: antennaStates[1], 
            3: antennaStates[2], 
            4: antennaStates[3],
        ]
        let res = RFIDManager.getInstance().setAntennaStates(antennaStates)
        toast.show(res.code == .success ? "Set Success" : "Set Failure")
    }

    func getAntennaStates(_ showToast: Bool = true) {
        let res = RFIDManager.getInstance().getAntennaStates()
        DispatchQueue.main.async {
            if res.code == .success, let states = res.data as? [Int: Bool] {
                self.antennaStates = [
                    states[1] ?? false,
                    states[2] ?? false,
                    states[3] ?? false,
                    states[4] ?? false,
                ]
                if self.antennaStates[1] || self.antennaStates[2] || self.antennaStates[3] {
                    self.showAntennaStates = true
                }
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            } 
        }
    }

    func setRFLink() {
        let res = RFIDManager.getInstance().setRFLink(rfLink.rawValue)
        toast.show(res.code == .success ? "Set Success" : "Set Failure")
    }

    func getRFLink(_ showToast: Bool = true) {
        let res = RFIDManager.getInstance().getRFLink()
        DispatchQueue.main.async {
            if res.code == .success, let link = RFIDRFLink(rawValue: res.data as! Int) {
                self.rfLink = link
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    func setMemoryBank() {
        let res = RFIDManager.getInstance().setMemoryBank(
            RFIDMemoryBank(bank: inventoryBank.rawValue, offset: Int(offset) ?? 0, length: Int(length) ?? 0)
        )
        toast.show(res.code == .success ? "Set Success" : "Set Failure")
    }

    func getMemoryBank(_ showToast: Bool = true) {
        let res = RFIDManager.getInstance().getMemoryBank()
        DispatchQueue.main.async {
            if res.code == .success, let mode = res.data as? RFIDMemoryBank {
                self.inventoryBank = RFIDMemoryBank.InventoryBank(rawValue: mode.inventoryBank) ?? .EPC 
                if mode.inventoryBank == RFIDMemoryBank.InventoryBank.EPC_TID_USER.rawValue 
                    || mode.inventoryBank == RFIDMemoryBank.InventoryBank.EPC_RESERVED.rawValue
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.offset = String(mode.offset)
                        self.length = String(mode.length)
                    }
                }
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    func setGen2() {
        let res = RFIDManager.getInstance().getGen2()
        if res.code == .success, let gen2: RFIDGen2 = res.data as? RFIDGen2 {
            gen2.querySession = session.rawValue
            gen2.queryTarget = target.rawValue
            let res = RFIDManager.getInstance().setGen2(gen2)
            toast.show(res.code == .success ? "Set Success" : "Set Failure")
        } else {
            toast.show("Set Success")
        }
    }

    func getGen2(_ showToast: Bool = true) {
        let res = RFIDManager.getInstance().getGen2()
        DispatchQueue.main.async {
            if res.code == .success, let gen2: RFIDGen2 = res.data as? RFIDGen2 {
                self.session = RFIDGen2.QuerySession(rawValue: gen2.querySession) ?? .S0
                self.target = RFIDGen2.QueryTarget(rawValue: gen2.queryTarget) ?? .A
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    func setFastID(_ flag: Bool, _ showToast: Bool = true) {
        let res = RFIDManager.getInstance().setFastID(flag)
        if showToast { toast.show(res.code == .success ? "Set Success" : "Set Failure") }
    }

    func getFastID(_ showToast: Bool = true) {
        let res = RFIDManager.getInstance().getFastID()
        DispatchQueue.main.async {
            if res.code == .success, let flag = res.data as? Bool {
                self.fastIDController.setValue(flag)
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    func setTagFocus(_ flag: Bool, _ showToast: Bool = true) {
        let res = RFIDManager.getInstance().setTagFocus(flag)
        if showToast { toast.show(res.code == .success ? "Set Success" : "Set Failure") }
    }

    func getTagFocus(_ showToast: Bool = true) {
        let res = RFIDManager.getInstance().getTagFocus()
        DispatchQueue.main.async {
            if res.code == .success, let flag = res.data as? Bool {
                self.tagFocusController.setValue(flag)
                if showToast { toast.show("Get Success") }
            } else {
                if showToast { toast.show("Get Failure") }
            }
        }
    }

    func resetUhf() {
        let res = RFIDManager.getInstance().resetUHF()
        toast.show(res.code == .success ? "Reset Success" : "Reset Failure")
        if res.code == .success {
            getAllSettings()
        }
    }

    // MARK: - Get All Settings

    func getAllSettings() {
        DispatchQueue.global().async {  
            self.getAntennaStates(false)                  
            self.getFrequency(false)
            self.getPower(false)
            self.getRFLink(false)
            self.getGen2(false)
            self.getMemoryBank(false)
            self.getFastID(false)
            self.getTagFocus(false)
        }
    }
}
