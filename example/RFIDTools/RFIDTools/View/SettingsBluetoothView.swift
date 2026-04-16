//
//  SettingsBluetoothView.swift
//  RFIDTools
//

import Foundation
import RFIDManager
import SwiftUI

struct SettingsBluetoothView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel = SettingsBluetoothViewModel()
    @State private var showResetBluetoothAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Scrollable Content

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Warning Banner
                        
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("BT Settings Warning")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(6)
                    .padding(.vertical, 6)
                        
                    // MARK: Bluetooth Name
                    
                    VStack {
                        HStack {
                            Text("Bluetooth Name").frame(minWidth: 180, alignment: .leading)
                            TextField("Enter bluetooth name", text: $viewModel.bluetoothName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }.padding(.vertical, 5)
                    Divider()
                        
                    // MARK: Bluetooth MAC Address
                        
                    VStack {
                        HStack {
                            Text("MAC Address")
                                .frame(minWidth: 180, alignment: .leading)
                            TextField("00:00:00:00:00:00", text: $viewModel.bluetoothMac)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }.padding(.vertical, 5)
                    Divider()
                    
                    // MARK: Baud Rate
                    
                    VStack {
                        HStack {
                            Text("Baud Rate").frame(minWidth: 180, alignment: .leading)
                            Spacer()
                            Picker("", selection: $viewModel.baudRate) {
                                ForEach(viewModel.baudRateList, id: \.self) { rate in
                                    Text("\(rate)").tag(rate)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                        }
                    }.padding(.vertical, 5)
                    Divider()
                    
                    // MARK: Pairing PinKey
                    
                    VStack {
                        HStack {
                            Text("Pairing PinKey").frame(minWidth: 180, alignment: .leading)
                            TextField("Enter 6 digits", text: $viewModel.pinKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .numbersOnly($viewModel.pinKey)
                                .onChange(of: viewModel.pinKey) { newValue in
                                    if newValue.count > 6 {
                                        viewModel.pinKey = String(newValue.prefix(6))
                                    }
                                }
                        }
                    }.padding(.vertical, 5)
                    Divider()
                    
                    // MARK: Keyboard Layout
                    
                    VStack {
                        HStack {
                            Text("Keyboard Layout").frame(minWidth: 180, alignment: .leading)
                            Spacer()
                            Picker("", selection: $viewModel.keyboardLayout) {
                                ForEach(viewModel.keyboardLayoutList, id: \.value) { item in
                                    Text(item.text).tag(item.value)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                        }
                    }.padding(.vertical, 5)
                    Divider()
                    
                    // MARK: HID Key Interval
                    
                    VStack {
                        HStack {
                            Text("HID Key Interval(ms)").frame(minWidth: 220, alignment: .leading)
                            TextField("0-100", text: $viewModel.hidKeyInterval)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .numbersOnly($viewModel.hidKeyInterval)
                        }
                    }.padding(.vertical, 5)
                    Divider()
                    
                    // MARK: Connection Ready Time
                    
                    VStack {
                        HStack {
                            Text("Connection Ready Time(ms)").frame(minWidth: 220, alignment: .leading)
                            TextField("0-5000", text: $viewModel.connectionReadyTime)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .numbersOnly($viewModel.connectionReadyTime)
                        }
                    }.padding(.vertical, 5)
                    Divider()
                    
                    // MARK: Min Connection Time
                    
                    VStack {
                        HStack {
                            Text("Min Connection Time(ms)").frame(minWidth: 220, alignment: .leading)
                            TextField("8-20", text: $viewModel.minConnectionTime)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .numbersOnly($viewModel.minConnectionTime)
                        }
                    }.padding(.vertical, 5)
                    Divider()
                    
                    // MARK: Max Connection Time
                    
                    VStack {
                        HStack {
                            Text("Max Connection Time(ms)").frame(minWidth: 220, alignment: .leading)
                            TextField("24-40", text: $viewModel.maxConnectionTime)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .numbersOnly($viewModel.maxConnectionTime)
                        }
                    }.padding(.vertical, 5)
                    Divider()
                    
                    // MARK: Min Send Time
                    
                    VStack {
                        HStack {
                            Text("Min Send Time(ms)").frame(minWidth: 220, alignment: .leading)
                            TextField("0-255", text: $viewModel.minSendTime)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .numbersOnly($viewModel.minSendTime)
                        }
                    }.padding(.vertical, 5)
                    Divider()
                    
                    // MARK: Bind Attribute
                    
                    HStack {
                        Text("Bind Attribute")
                        Spacer()
                        Toggle("", isOn: $viewModel.bindAttribute)
                            .labelsHidden()
                    }
                    .padding(.vertical, 5)
                    Divider()
                    
                    // MARK: HID Keyboard Service
                    
                    HStack {
                        Text("HID Keyboard Service")
                        Spacer()
                        Toggle("", isOn: $viewModel.keyboardService)
                            .labelsHidden()
                    }
                    .padding(.vertical, 5)
                    Divider()
                    
                    // MARK: Serial Service
                    
                    HStack {
                        Text("Serial Service")
                        Spacer()
                        Toggle("", isOn: $viewModel.serialService)
                            .labelsHidden()
                            .disabled(viewModel.serialService)
                    }
                    .padding(.vertical, 5)
                    Divider()
                    
                    // MARK: Hardware Version
                    
                    HStack {
                        Text("Hardware Version").frame(minWidth: 220, alignment: .leading)
                        Spacer()
                        Text(viewModel.hardwareVersion.isEmpty ? "--" : viewModel.hardwareVersion)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                    
                    // MARK: Firmware Version
                    
                    HStack {
                        Text("Firmware Version").frame(minWidth: 220, alignment: .leading)
                        Spacer()
                        Text(viewModel.firmwareVersion.isEmpty ? "--" : viewModel.firmwareVersion)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                    
                    // MARK: Software Version
                    
                    HStack {
                        Text("Software Version").frame(minWidth: 220, alignment: .leading)
                        Spacer()
                        Text(viewModel.softwareVersion.isEmpty ? "--" : viewModel.softwareVersion)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                    
                    // MARK: Manufacturer Name
                    
                    HStack {
                        Text("Manufacturer Name").frame(minWidth: 220, alignment: .leading)
                        Spacer()
                        Text(viewModel.manufacturerName.isEmpty ? "--" : viewModel.manufacturerName)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                    Divider()
                    
                    // MARK: Remove BT Bonds & Reset Bluetooth
                    
                    HStack(spacing: 15) {
                        Button("Remove BT Bonds") { viewModel.removeBondedDevices() }
                            .outlinedStyle(color: colorScheme == .dark ? .white : .black)
                        Button("Reset Bluetooth") { 
                            showResetBluetoothAlert = true
                        }
                        .outlinedStyle(color: .red)
                        .alert(isPresented: $showResetBluetoothAlert) {
                            Alert(
                                title: Text("Reset Bluetooth Confirm".localizedString(appState.localication)),
                                primaryButton: .destructive(Text("Confirm".localizedString(appState.localication))) {
                                    viewModel.resetBluetooth()
                                },
                                secondaryButton: .cancel(Text("Cancel".localizedString(appState.localication)))
                            )
                        }
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 60) // Leave space for bottom buttons
            }
                
            // MARK: - Fixed Bottom Buttons

            Divider()
            HStack(spacing: 20) {
                Button("Set") { viewModel.setBluetoothParameter() }
                    .outlinedStyle()
                Button("Get") { viewModel.getBluetoothParameter() }
                    .outlinedStyle()
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 1)
            .background(Color.clear)
        }
    }
}

#Preview {
    VStack {
        SettingsBluetoothView()
            .environmentObject(AppState.shared)
    }
}
