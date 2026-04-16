//
//  Upgradle.swift
//  RFIDTools
//
//  Created by zsg on 2025/1/14.
//
import Foundation
import RFIDManager
import SwiftUI
import UniformTypeIdentifiers

struct UpgradeView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var globalOverlay: GlobalOverlay

    @StateObject private var viewModel = UpgradeViewModel()

    @State private var showingPicker = false
    @State private var upgradeType = RFIDUpgradeType.Mainboard

    var body: some View {
        ScrollView {
            HStack {
                Text("Upgrade Type")
                Picker("", selection: $upgradeType) {
                    ForEach(RFIDUpgradeType.allCases, id: \.self) { type in
                        Text(type.description.localizedString(appState.localication)).tag(type)
                    }
                }
                .flexibleButtonSizing()
                .pickerStyle(.segmented)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 20)

            Text(viewModel.selectFileUrl?.lastPathComponent ?? "")

            HStack(spacing: 10) {
                Button("Select File") { selectFile() }
                    .outlinedStyle()
                    .sheet(isPresented: $showingPicker) {
                        #if os(iOS)
                            // Use sheet to display the file selector
                            DocumentPicker(upgradeType: upgradeType) { url in
                                if let url = url {
                                    viewModel.selectFileUrl = url
                                    viewModel.upgradeResult = ""
                                }
                            }
                        #endif
                    }
                Button("Upgrade") { upgrade() }
                    .outlinedStyle()
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 30, trailing: 10))

            Text(viewModel.upgradeResult.localizedString(appState.localication))
                .font(.system(size: 20))
                .foregroundColor(viewModel.upgradeResult == "Upgrade Successful" ? .green : .red)
                .padding(.vertical, 20)
        }
        .onChange(of: viewModel.updateOverlay) { _ in
            showProgressView(msg: "Upgrading...", progress: viewModel.updateProgress)
        }
    }

    func selectFile() {
        #if os(iOS)
            showingPicker.toggle()
        #else 
            let panel = NSOpenPanel()
            let binType = UTType(filenameExtension: "bin") ?? .data
            panel.allowedContentTypes = upgradeType == .Bluetooth ? [.zip] : [binType]
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            if panel.runModal() == .OK {
                viewModel.selectFileUrl = panel.url
            }
        #endif
    }

    func upgrade() {
        viewModel.upgradeResult = ""
        guard let url = viewModel.selectFileUrl else {
            viewModel.selectFileUrl = nil
            viewModel.upgradeResult = "Select File First"
            return
        }
        guard let data = try? Data(contentsOf: url) else {
            viewModel.selectFileUrl = nil
            viewModel.upgradeResult = "Failed to read file".localizedString(appState.localication) + " : " + url.lastPathComponent
            return
        }

        showProgressView(msg: "Starting to upgrade...", progress: 0)

        viewModel.upgrade(type: upgradeType, fileData: data)
    }

    private func showProgressView(msg: String, progress: Int) {
        if progress == -1 {
            globalOverlay.hide()
            return
        }

        globalOverlay.showCustomView(dismissable: false) {
            VStack { 
                Spacer()
                    .frame(height: 90)
                ProgressView(
                    msg.localizedString(appState.localication) + " \(progress)%",
                    value: Double(progress),
                    total: 100
                )
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 200)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .shadow(radius: 10)
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    UpgradeView()
        .environmentObject(AppState.shared)
}
