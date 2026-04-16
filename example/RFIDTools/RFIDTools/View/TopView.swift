//
//  TopView.swift
//  RFIDTools
//
//  Created by zsg on 2024/4/26.
//

import CoreBluetooth
import Foundation
import RFIDManager
import SwiftUI

struct TopView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var globalOverlay: GlobalOverlay

    var peripheral: CBPeripheral?

    init(peripheral: CBPeripheral?) {
        self.peripheral = peripheral
    }

    var body: some View {
        HStack {
            Button(action: handleConnectionToggle) {
                Text(appState.connectState == .connected ? "Disconnect" : "Connect")
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                    .frame(minWidth: 110)
                    .background(colorScheme == .dark ? Color(hex: 0x202020) : Color.white)
            }
            // .disabled(appState.connectState == .connecting || appState.connectState == .disconnecting)
            .buttonStyle(.plain)
            .cornerRadius(2)
            .padding(EdgeInsets(top: 12, leading: 6, bottom: 14, trailing: 2))

            Text(getTextbyState(appState.connectState).localizedString(appState.localication))
                .foregroundColor(.white)
            Spacer()


            Button(action: {
                withAnimation {
                    globalOverlay.showCustomView(dismissable: true, content: { MoreView() })
                }
            }, label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(Color.white)
                    .font(.title) 
                    .frame(width: 40.0, height: 40)
                    .padding(.trailing, 10.0)
                    .contentShape(Rectangle())
            })
            .buttonStyle(.plain)
        }
        .background(Color.blue.opacity(0.5).ignoresSafeArea(.all, edges: .top))
    }

    func handleConnectionToggle() {
        if appState.connectState == .connected {
            if appState.connectionType == .Bluetooth {
                if let p = peripheral {
                    RFIDBleManager.shared.disconnectPeripheral(p)
                }
            } else {
                let res = RFIDUsbManager.shared.disconnect()
                if res.code == .failure {
                    toast.show(res.message ?? "Failure")
                }
            }
        } else {
            if appState.connectionType == .Bluetooth {
                withAnimation {
                    globalOverlay.showCustomView(dismissable: true, content: { BleConnectView() })
                }
            } else {
                let res = RFIDUsbManager.shared.connect()
                if res.code == .failure {
                    toast.show(res.message ?? "Failure")
                }
            }
        }
    }

    func getTextbyState(_ state: RFIDConnectState) -> String {
        switch state {
        case .connected:
            if appState.connectionType == .Bluetooth {
                return peripheral?.name ?? ""
            } else {
                return "USB Connected"
            }
        case .disconnected:
            if appState.connectionType == .Bluetooth {
                return "Ble Disconnected"
            } else {
                return "USB Disconnected"
            }
        case .connecting:
            return "Connecting"
        case .disconnecting:
            return "Disconnecting"
        default:
            return "Unknown"
        }
    }
}

#Preview {
    TopView(peripheral: nil)
        .environmentObject(AppState.shared)
}
