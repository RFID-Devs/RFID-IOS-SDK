//
//  BarcodeViewModel.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/10.
//

import Combine
import RFIDManager
import SwiftUI

class BarcodeViewModel: ObservableObject {
    @Published var barcodeFlag: Bool = false
    @Published var parameterKey: String = ""
    @Published var parameterValue: String = ""
    @Published var barcodeTypeController = UserDrivenValue(false)
    @Published var continuous: Bool = false
    @Published var barcodeList: [RFIDBarcodeInfo] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Page changes listening
        AppState.shared
            .$selectedPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPage in
                if AppState.shared.selectedPage != .Barcode, self?.barcodeFlag == true {
                    self?.stopBarcode()
                }
                if AppState.shared.selectedPage == .Barcode {
                    self?.getBarcodeType(false)
                }
            }
            .store(in: &cancellables)

        // Bluetooth connection status listening
        AppState.shared
            .$connectState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if state == .disconnected {
                    self?.barcodeFlag = false
                }
            }
            .store(in: &cancellables)

        // Device keyEvent listening
        RFIDBleManager.shared
            .keyEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keyEvent in
                self?.keyEventHandler(keyEvent)
            }
            .store(in: &cancellables)
        RFIDUsbManager.shared
            .keyEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keyEvent in
                self?.keyEventHandler(keyEvent)
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    func keyEventHandler(_ keyEvent: RFIDKeyEvent) {
        if AppState.shared.selectedPage != .Barcode {
            return
        }

        if keyEvent.isKeyDown {
            startBarcode()
        } else if keyEvent.isKeyUp {
            if keyEvent.keyCode == 1 {
                barcodeToggle()
            } else {
                stopBarcode()
            }
        }
    }

    func setBarcodeType(_ barcodeType: Bool) {
        let res = RFIDManager.getInstance().setBarcodeType(barcodeType, saveFlag: false)
        // print("setBarcodeType \(res.description)")
        toast.show(res.message ?? "Failure")
    }

    func getBarcodeType(_ showToast: Bool = true) {
        DispatchQueue.global().async {
            let res = RFIDManager.getInstance().getBarcodeType()
            DispatchQueue.main.async {
                if showToast {
                    toast.show(res.message ?? "Failure")
                }
                if res.code == .success, let barcodeType = res.data as? Bool {
                    self.barcodeTypeController.setValue(barcodeType)
                }
            }
        }
    }

    func setBarcodeParameter() {
        let res = RFIDManager.getInstance().setBarcodeParameter(key: parameterKey, value: parameterValue, saveFlag: false)
        toast.show(res.message ?? "Failure")
    }

    func getBarcodeParameter() {
        let res = RFIDManager.getInstance().getBarcodeParameter(parameterKey)
        toast.show(res.message ?? "Failure")
        if res.code == .success, let data = res.data as? Data {
            parameterValue = data.hexString
        }
    }

    func barcodeToggle() {
        if !barcodeFlag {
            startBarcode()
        } else {
            stopBarcode()
        }
    }

    func startBarcode() {
//        if barcodeFlag {
//            return
//        }
        let res = RFIDManager.getInstance().startBarcode(barcodeBlock: { barcodeInfo in
            print("barcodeBlock barcode=\(barcodeInfo.description)")
            if barcodeInfo.result { // data are valid
                AudioPlayer.shared.playAudio()
                self.barcodeList.append(barcodeInfo)
            } else {
                toast.show("Scan Timeout")
            }
            if self.continuous, self.barcodeFlag { // continuous scan
                self.startBarcode()
            } else {
                self.barcodeFlag = false
            }
        })
        if res.code == .success {
            barcodeFlag = true
        } else {
            barcodeFlag = false
            toast.show(res.message ?? "Failure")
        }
    }

    func stopBarcode() {
        if !barcodeFlag {
            return
        }
        let res = RFIDManager.getInstance().stopBarcode()
        if res.code == .success {
            barcodeFlag = false
        } else {
            toast.show(res.message ?? "Failure")
        }
    }
}
