//
//  SettingsUhfView.swift
//  RFIDTools
//
//  Created by zsg on 2024/4/26.
//

import Foundation
import RFIDManager
import SwiftUI

struct SettingsUhfView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    @StateObject var viewModel = SettingsUhfViewModel()
    @State private var showResetAlert: Bool = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            // MARK: Frequency

            VStack {
                HStack {
                    Text("Frequency").frame(minWidth: 100, alignment: .leading)
                    Spacer()
                    Picker("", selection: $viewModel.frequency) {
                        ForEach(RFIDFrequency.allCases) { fre in
                            Text(fre.description).tag(fre).frame(minWidth: 100)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Spacer()
                }
                buttonRow(set: viewModel.setFrequency, get: { viewModel.getFrequency() })
            }
            .padding(.vertical, 5)
            Divider()

            // MARK: Power

            VStack {
                HStack {
                    Text("Power").frame(minWidth: 100, alignment: .leading)
                    Spacer()
                    Picker("", selection: $viewModel.power) {
                        ForEach(1 ... 30, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Spacer()
                }
                buttonRow(set: viewModel.setPower, get: { viewModel.getPower() })
            }
            Divider()

            // MARK: Antenna States

            if viewModel.showAntennaStates {
                VStack(alignment: .leading) {
                    Text("Antenna States").frame(minWidth: 100, alignment: .leading)
                    FlowLayout(horizontalSpacing: 20, verticalSpacing: 15, items: [
                        AnyView(CheckButton("Antenna 1", viewModel.antennaStates[0], action: { viewModel.antennaStates[0].toggle() })),
                        AnyView(CheckButton("Antenna 2", viewModel.antennaStates[1], action: { viewModel.antennaStates[1].toggle() })),
                        AnyView(CheckButton("Antenna 3", viewModel.antennaStates[2], action: { viewModel.antennaStates[2].toggle() })),
                        AnyView(CheckButton("Antenna 4", viewModel.antennaStates[3], action: { viewModel.antennaStates[3].toggle() })),
                    ])
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 2))
                    buttonRow(set: viewModel.setAntennaStates, get: { viewModel.getAntennaStates() })
                }
                Divider()
            }

            // MARK: RFLink

            VStack {
                HStack {
                    Text("RFLink").frame(minWidth: 100, alignment: .leading)
                    Spacer()
                    Picker("", selection: $viewModel.rfLink) {
                        ForEach(RFIDRFLink.allCases, id: \.self) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Spacer()
                }
                buttonRow(set: viewModel.setRFLink, get: { viewModel.getRFLink() })
            }
            Divider()

            // MARK: MemeryBank

            VStack {
                HStack {
                    Text("Inventory Bank").frame(minWidth: 100, alignment: .leading)
                    Spacer()
                    Picker("", selection: $viewModel.inventoryBank) {
                        ForEach(RFIDMemoryBank.InventoryBank.allCases, id: \.self) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: viewModel.inventoryBank) { _ in
                        if viewModel.inventoryBank == .EPC_RESERVED {
                            viewModel.length = "4"
                        } else if viewModel.inventoryBank == .EPC_TID_USER {
                            viewModel.length = "6"
                        }
                    }
                    Spacer()
                }
                if viewModel.inventoryBank == .EPC_TID_USER || viewModel.inventoryBank == .EPC_RESERVED {
                    HStack {
                        Text("Offset(word):")
                        TextField("", text: $viewModel.offset)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .numbersOnly($viewModel.offset)
                        Spacer()
                        Text("Length(word):")
                        TextField("", text: $viewModel.length)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .numbersOnly($viewModel.length)
                        Spacer()
                    }
                }
                buttonRow(set: viewModel.setMemoryBank, get: { viewModel.getMemoryBank() })
            }
            Divider()

            // MARK: Gen2

            VStack {
                HStack {
                    Text("Session").frame(minWidth: 100, alignment: .leading)
                    Picker("", selection: $viewModel.session) {
                        ForEach(RFIDGen2.QuerySession.allCases, id: \.self) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(0)
                    Spacer()
                    Text("Target").frame(minWidth: 100, alignment: .leading)
                    Picker("", selection: $viewModel.target) {
                        ForEach(RFIDGen2.QueryTarget.allCases, id: \.self) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(0)
                    Spacer()
                }
                buttonRow(set: viewModel.setGen2, get: { viewModel.getGen2() })
            }
            Divider()

            // MARK: FastID

            UserDrivenToggle(controller: viewModel.fastIDController) {
                Text("FastID")
            }
            .onUserChange { fastID in
                viewModel.setFastID(fastID, false)
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 10))
            Divider()

            // MARK: TagFocus

            UserDrivenToggle(controller: viewModel.tagFocusController) {
                Text("TagFocus")
            }
            .onUserChange { tagFocus in
                viewModel.setTagFocus(tagFocus, false)
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 10))
            Divider()

            // MARK: Reset UHF

            VStack {
                Button("Reset UHF") {
                    showResetAlert = true
                }
                .outlinedStyle(color: .red)
                .padding(.horizontal, 4)
                .alert(isPresented: $showResetAlert) {
                    Alert(
                        title: Text("Reset UHF Confirm".localizedString(appState.localication)),
                        primaryButton: .destructive(Text("Confirm".localizedString(appState.localication))) {
                            viewModel.resetUhf()
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

    func CheckButton(_ title: String, _ isSelected: Bool, action: @escaping () -> Void) -> some View {
        return Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square" : "square")
                    .resizable(resizingMode: .stretch)
                    .foregroundColor(isSelected ? .blue : colorScheme == .dark ? .white : .black)
                    .frame(width: 20.0, height: 20.0)
                Text(title.localizedString(appState.localication))
                    .foregroundColor(isSelected ? .blue : colorScheme == .dark ? .white : .black)
                    .border(.background, width: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        SettingsUhfView()
            .environmentObject(AppState.shared)
    }
}
