//
//  SettingsMainboard.swift
//  RFIDTools
//

import Foundation
import RFIDManager
import SwiftUI

struct SettingsMainboardView: View {
    @EnvironmentObject private var appState: AppState

    @StateObject var viewModel = SettingsMainboardViewModel()
    @State private var showResetAlert: Bool = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            // MARK: Work Mode

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Work Mode").frame(minWidth: 150, alignment: .leading)
                    Spacer()
                    Picker("", selection: $viewModel.workMode) {
                        Text("Command Mode").tag(0)
                        Text("USB HID Continuous").tag(1)
                        Text("BT HID Single").tag(2)
                        Text("BT HID Continuous").tag(3)
                        Text("Virtual COM").tag(4)
                        Text("USB HID Single").tag(5)
                        Text("Offline Reading").tag(6)
                    }
                    .pickerStyle(MenuPickerStyle())
                    Spacer()
                }
                buttonRow(set: viewModel.setWorkMode, get: { viewModel.getWorkMode() })
            }
            .padding(.vertical, 5)
            Divider()

            // MARK: Key Mode

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Key Mode").frame(minWidth: 180, alignment: .leading)
                    Spacer()
                    Picker("", selection: $viewModel.keyMode) {
                        Text("Single Press").tag(0)
                        Text("Long Press").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.trailing, 8)
                    .frame(maxWidth: 300)
                }

                buttonRow(set: viewModel.setKeyMode, get: { viewModel.getKeyMode() })
            }
            .padding(.vertical, 5)
            Divider()

            // MARK: Idle Timeout

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Idle Timeout (minutes)").frame(minWidth: 210, alignment: .leading)
                    Spacer()
                    TextField("3-65535", text: $viewModel.idle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 300)
                        .numbersOnly($viewModel.idle)
                }


                buttonRow(set: viewModel.setIdle, get: { viewModel.getIdle() })
            }
            .padding(.vertical, 5)
            Divider()

            // MARK: Wait Connect Timeout

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Wait Connect Timeout (minutes)").frame(minWidth: 210, alignment: .leading)
                    Spacer()
                    TextField("1-65535", text: $viewModel.waitConnectTimeout)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 300)
                        .numbersOnly($viewModel.waitConnectTimeout)
                }

                buttonRow(set: viewModel.setWaitConnectTimeout, get: { viewModel.getWaitConnectTimeout() })
            }
            .padding(.vertical, 5)
            Divider()

            // MARK: Buzzer

            UserDrivenToggle(controller: viewModel.buzzerController) {
                Text("Buzzer")
            }
            .onUserChange { buzzer in
                viewModel.setBuzzer(buzzer, false)
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 10))
            Divider()                

            // MARK: Rssi

            UserDrivenToggle(controller: viewModel.rssiController) {
                Text("Rssi")
            }
            .onUserChange { rssi in
                viewModel.setRssi(rssi, false)
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 10))
            Divider()

            // MARK: Reset Mainboard

            VStack {
                Button("Reset Mainboard") {
                    showResetAlert = true
                }
                .outlinedStyle(color: .red)
                .padding(.horizontal, 4)
                .alert(isPresented: $showResetAlert) {
                    Alert(
                        title: Text("Reset Mainboard Confirm".localizedString(appState.localication)),
                        primaryButton: .destructive(Text("Confirm".localizedString(appState.localication))) {
                            viewModel.resetMainboard()
                        },
                        secondaryButton: .cancel(Text("Cancel".localizedString(appState.localication)))
                    )
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 20)

        }
        .padding(.horizontal, 10)
    }

    func buttonRow(set: @escaping () -> Void, get: @escaping () -> Void) -> some View {
        HStack {
            Button("Set") { set() }
                .outlinedStyle()
                .padding(.horizontal, 4)
            Button("Get") { get() }
                .outlinedStyle()
                .padding(.horizontal, 4)
        }
    }

}
