//
//  MoreView.swift
//  RFIDTools
//
//  Created by zsg on 2024/4/28.
//

import Foundation
import RFIDManager
import SwiftUI

struct MoreView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var globalOverlay: GlobalOverlay

    @State private var offsetY = CGSize.zero
    @State var isAllowToDrag: Bool = false
    @State private var connectionType: RFIDConnectionType = AppState.shared.connectionType
    @State private var localication = AppState.shared.localication

    var body: some View {
        let bounds: CGRect = {
            #if os(macOS)
                NSApplication.shared.windows.first?.frame ?? .zero
            #else
                UIScreen.main.bounds
            #endif
        }()

        VStack {
            Spacer()
            VStack {
                Rectangle()
                    .foregroundColor(Color(.gray))
                    .cornerRadius(30)
                    .frame(width: bounds.width / 6, height: DevicePlatform.isIPhone ? 5 : 10)
                Spacer()
                VStack(spacing: 10) {
                    Spacer()
                    MaxWidthButton(text: "Device Information", onClick: {
                        globalOverlay.showCustomView(dismissable: true, content: { DeviceInfoView() })
                    })
                    Spacer()

                    if DevicePlatform.isMac {
                        Picker("", selection: $connectionType) {
                            Text("Bluetooth").tag(RFIDConnectionType.Bluetooth)
                            Text("USB").tag(RFIDConnectionType.USB)
                        }
                        .pickerStyle(.segmented)
                        .flexibleButtonSizing()
                        .padding(.leading, -8)
                        .onChange(of: connectionType) { type in
                            if appState.connectState == .connected {
                                if type == .Bluetooth {
                                    _ = RFIDUsbManager.shared.disconnect()
                                } else if type == .USB {
                                    RFIDBleManager.shared.disconnectPeripheral()
                                }
                            }
                            DispatchQueue.main.async {
                                appState.connectionType = type
                            }
                            UserDefaults.standard.setValue(type.rawValue, forKey: AppState.KEY_CONNECTION_TYPE)
                        }
                        Spacer()
                    }

                    Picker("", selection: $localication) {
                        ForEach(LocaleStrings.allCases) { localeString in
                            Text(localeString.rawValue)
                                .tag(localeString.suggestedLocalication)
                        }
                    }
                    .pickerStyle(.segmented)
                    .flexibleButtonSizing()
                    .padding(.leading, -8)
                    .onChange(of: localication) { lang in
                        DispatchQueue.main.async {
                            appState.localication = lang
                        }
                        UserDefaults.standard.setValue(lang.rawValue, forKey: AppState.KEY_LOCALE_IDENTIFIER)
                    }
                    Spacer()
                }
            }
            .padding()
            .frame(maxWidth: DevicePlatform.isIPhone ? .infinity : bounds.width / 2, maxHeight: 160)
            .background(colorScheme == .dark ? Color(hex: 0x202020) : Color.white)
            .cornerRadius(10, antialiased: true)
            .offset(y: isAllowToDrag ? offsetY.height : 0)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // 如果向下拖动
                        if gesture.translation.height > 0 {
                            self.isAllowToDrag = true
                            self.offsetY = gesture.translation
                        }
                    }
                    .onEnded { _ in
                        // 如果拖动位置大于60
                        if (self.offsetY.height) > 60 { 
                            globalOverlay.hide()
                        } else {
                            self.offsetY = .zero
                        }
                    }
            )
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    struct MaxWidthButton: View {
        @EnvironmentObject private var appState: AppState
        var text: String
        var onClick: () -> Void
        var body: some View {
            Button(action: {
                onClick()
            }) {
                Text(text.localizedString(appState.localication))
                    .frame(maxWidth: .infinity, maxHeight: 30)
            }
        }
    }
}

#Preview {
    VStack {
        MoreView()
            .environmentObject(AppState.shared)
    }
}
