//
//  PageManagerView.swift
//  SwiftTest
//
//  Created by zsg on 2025/5/22.
//

import SwiftUI

struct PageManagerView: View {
    @ObservedObject var tabConfig: TabConfigManager
    @EnvironmentObject var appState: AppState

    @Environment(\.presentationMode) private var presentationMode

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            HStack {
                Text("Page Manager".localizedString(appState.localication)).font(.title2).bold()
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding()
            List {
                ForEach(tabConfig.selectedPages, id: \.self) { page in
                    HStack {
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(.blue)
                        Text(page.rawValue.localizedString(appState.localication))
                            .strikethrough(isPageDisabled(page))
                            .foregroundColor(isPageDisabled(page) ? .gray : .primary)
                    }
                    .frame(minWidth: 100, minHeight: 30, alignment: .leading)
                    .contentShape(Rectangle())
                    .modifier(iOS15ListRowPadding())
                    .onTapGesture {
                        if tabConfig.selectedPages.count == 1 {
                            alertMessage = "At least one page must be kept".localizedString(appState.localication)
                            showAlert = true
                        } else {
                            tabConfig.toggle(page)
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertMessage))
                    }
                }
                .onMove(perform: tabConfig.move)

                ForEach(AppPage.allCases.filter { !tabConfig.selectedPages.contains($0) }, id: \.self) { page in
                    HStack {
                        Image(systemName: "square")
                            .foregroundColor(.gray)
                        Text(page.rawValue.localizedString(appState.localication))
                            .strikethrough(isPageDisabled(page))
                            .foregroundColor(isPageDisabled(page) ? .gray : .primary)
                    }
                    .frame(minWidth: 100, minHeight: 30, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        tabConfig.toggle(page)
                    }
                }
            }
            .id(UUID())
            .listStyle(.plain)
            .animation(.default, value: tabConfig.selectedPages)
            #if !os(macOS)
                .environment(\.editMode, .constant(.active))
            #endif

            Spacer()
        }
    }

    // iOS 15 以下专用的行间距调整修饰符
    private struct iOS15ListRowPadding: ViewModifier {
        func body(content: Content) -> some View {
            if #available(iOS 16, *) {
                content
            } else {
                content
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .padding(.leading, -40) // 抵消系统默认的额外间距
            }
        }
    }

    // 判断页面是否应该被禁用（显示删除线）
    private func isPageDisabled(_ page: AppPage) -> Bool {
        if DevicePlatform.isMac && page == .Radar {
            return true
        }
        if appState.connectionType == .USB && page == .SettingsBluetooth {
            return true
        }
        return false
    }
}
