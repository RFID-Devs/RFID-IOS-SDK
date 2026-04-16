//
//  UpgradeViewModel.swift
//  RFIDTools
//
//  Created by zsg on 2025/4/25.
//

import CoreBluetooth
import Foundation
import RFIDManager

class UpgradeViewModel: ObservableObject {
    @Published var selectFileUrl: URL? = nil
    @Published var updateProgress: Int = -1
    @Published var upgradeResult = ""

    /// Timestamp used to update global overlay windows
    @Published var updateOverlay: TimeInterval = 0

    func updateOverlayUI() {
        updateOverlay = Date.timeIntervalSinceReferenceDate
    }

    func upgrade(type: RFIDUpgradeType, fileData: Data) {
        RFIDManager.getInstance().upgrade(
            type: type.rawValue, 
            fileData: fileData, 
            callback: { result in
                if result.code == .pending {
                    if let progressString = result.data as? String, let progress = Int(progressString) {
                        // Update progress pop-up window
                        self.updateProgress = progress
                    }
                } else if result.code == .success {
                    self.updateProgress = -1
                    self.upgradeResult = "Upgrade Successful"
                } else {
                    self.updateProgress = -1
                    self.upgradeResult = result.message ?? "Failure"

                    print(result.description)
                }
                self.updateOverlayUI()
            }
        )
    }

}
