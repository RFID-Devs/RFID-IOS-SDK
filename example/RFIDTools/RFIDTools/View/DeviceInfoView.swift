//
//  VersionView.swift
//  RFIDTools
//
//  Created by zsg on 2025/3/27.
//

import RFIDManager
import SwiftUI

struct DeviceInfoView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var globalOverlay: GlobalOverlay

    @State var appVersion = ""
    @State var mainBoard = ""
    @State var bluetoothHardware = "-"
    @State var bluetoothFirmware = "-"
    @State var bluetoothSoftware = "-"
    @State var battery = ""

    @State var uhfHardware = ""
    @State var uhfFirmware = ""
    @State var temperature = ""

    @State var isLoading = false

    var body: some View {
        let bounds: CGRect = {
            #if os(macOS)
                NSApplication.shared.windows.first?.frame ?? .zero
            #else
                UIScreen.main.bounds
            #endif
        }()

        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with App Version and Refresh Button
                HStack {
                    Text("APP: V\(appVersion)")
                        .font(.headline)

                    Spacer()

                    Button(action: {
                        refreshDeviceInfo()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(isLoading ? .gray : .blue)
                            .rotationEffect(.degrees(isLoading ? 360 : 0))
                            .animation(isLoading ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isLoading)
                    }
                    .disabled(isLoading)
                }
                .padding(EdgeInsets(top: 16, leading: 4, bottom: 10, trailing: 4))

                if isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading device information...")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    // Mainboard Information
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "cpu")
                                .foregroundColor(.orange)
                                .frame(width: 28, height: 28)
                            Text("Mainboard")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        DeviceInfoRow(label: "Firmware", value: mainBoard)
                        DeviceInfoRow(label: "Battery", value: battery)
                    }

                    Divider()

                    // UHF Information
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .foregroundColor(.green)
                                .frame(width: 28, height: 28)
                            Text("UHF")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        DeviceInfoRow(label: "Firmware", value: uhfFirmware)
                        DeviceInfoRow(label: "Hardware", value: uhfHardware)
                        DeviceInfoRow(label: "Temperature", value: temperature)
                    }

                    Divider()

                    // Bluetooth Information
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image("bluetooth")
                                .resizable()
                                .frame(width: 28, height: 28)
                            Text("Bluetooth")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        DeviceInfoRow(label: "Firmware", value: bluetoothFirmware)
                        DeviceInfoRow(label: "Hardware", value: bluetoothHardware)
                        DeviceInfoRow(label: "Software", value: bluetoothSoftware)
                    }

                    Divider()
                }

                Spacer()
            }
            .padding(14)
        }
        #if os(iOS)
        .frame(maxWidth: bounds.width * 0.8, maxHeight: bounds.height * 0.7)
        #else
        .frame(maxWidth: bounds.width * 0.5, maxHeight: bounds.height * 0.8)
        #endif
        .background(colorScheme == .dark ? Color(hex: 0x202020) : Color.white)
        .cornerRadius(10, antialiased: true)
        .onAppear {
            getAppVersion()
            refreshDeviceInfo()
        }
    }

    func getAppVersion() {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else {
            return
        }

        appVersion = "\(version)_\(build)"
    }

    func refreshDeviceInfo() {
        isLoading = true
        mainBoard = ""
        battery = ""
        uhfHardware = ""
        uhfFirmware = ""
        temperature = ""
        bluetoothFirmware = "-"
        bluetoothHardware = "-"
        bluetoothSoftware = "-"
        DispatchQueue.global().async {
            getMainboardVersion()
            getDeviceBattery()

            getUHFHardwareVersion()
            getUHFFirmwareVersion()
            getTemperature()

            getBluetoothVersion()

            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }

    func getMainboardVersion() {
        let res = RFIDManager.getInstance().getMainboardVersion()
        if res.code == .success {
            DispatchQueue.main.async {
                mainBoard = res.data as? String ?? ""
            }
        }
    }

    func getBluetoothVersion() {
        let res = RFIDManager.getInstance().getBluetoothVersion()
        if res.code == .success {
            let version = res.data as! RFIDBleVersion
            DispatchQueue.main.async {
                bluetoothFirmware = version.firmware
                bluetoothHardware = version.hardware
                bluetoothSoftware = version.software
            }
        }
    }

    func getUHFHardwareVersion() {
        let res = RFIDManager.getInstance().getUHFHardwareVersion()
        if res.code == .success {
            DispatchQueue.main.async {
                uhfHardware = res.data as! String
            }
        } 
    }

    func getUHFFirmwareVersion() {
        let res = RFIDManager.getInstance().getUHFFirmwareVersion()
        if res.code == .success {
            DispatchQueue.main.async {
                uhfFirmware = res.data as! String
            }
        } 
    }

    func getDeviceBattery() {
        let res = RFIDManager.getInstance().getBattery()
        if res.code == .success {
            DispatchQueue.main.async {
                battery = "\(res.data as? Int ?? -1) %"
            }
        } 
    }

    func getTemperature() {
        let res = RFIDManager.getInstance().getUHFTemperature()
        if res.code == .success {
            DispatchQueue.main.async {
                temperature = "\(res.data as? Int ?? -1) ℃"
            }
        } 
    }
}

// MARK: - DeviceInfoRow

// Helper view for displaying information rows
struct DeviceInfoRow: View {
    @EnvironmentObject private var appState: AppState

    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label.localizedString(appState.localication))
                .fontWeight(.medium)
                .frame(minWidth: 100, alignment: .leading)
            Text(value)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}

#Preview {
    DeviceInfoView()
}
