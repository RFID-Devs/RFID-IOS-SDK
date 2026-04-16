//
//  InventoryView.swift
//  RFIDTools
//
//  Created by zsg on 2024/4/26.
//

import Foundation
import RFIDManager
import SwiftUI

struct InventoryView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var globalOverlay: GlobalOverlay
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject private var viewModel = InventoryViewModel.shared

    var body: some View {
        HStack {
            if appState.orientation == .portrait {
                VStack {
                    FilterView(filter: $viewModel.filter)
                    buttonRow
                    intventoryTimeView
                    InventoryList(viewModel.tagList, viewModel.all)
                }
            } else {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        ScrollView {
                            FilterView(filter: $viewModel.filter, isPortrait: false)
                            buttonRow
                            intventoryTimeView
                            Spacer()
                        }
                        .frame(width: min(geometry.size.width * 0.4, 400))
                        InventoryList(viewModel.tagList, viewModel.all)
                            .frame(minWidth: 430)
                    }
                }
            }
        }
    }

    var buttonRow: some View {
        HStack(spacing: 8) {
            Button(action: export) {
                Image(systemName: "square.and.arrow.up.circle")
                    .font(.largeTitle)
                    .foregroundColor(Color.blue)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            Button("Clear") { viewModel.clear() }
                .outlinedStyle()
            Button("Single") { viewModel.sinleInventory() }
                .outlinedStyle(disabled: viewModel.inventoryFlag)
            Button(viewModel.inventoryFlag ? "Stop" : "Inventory") { viewModel.inventory() }
                .outlinedStyle()
        }
        .frame(height: 36)
        .padding(.horizontal, 10)
    }

    var intventoryTimeView: some View {
        HStack {
            // Has no effect, used to capture autofocus and prevent autofocus to the TextField component below
            TextField("", text: .constant(""))
                .frame(width: 0, height: 0)
                .opacity(0)

            Text("Inventory Duration:")
            TextField("999999", text: $viewModel.inventoryDuration)
                .frame(maxWidth: 100)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .numbersOnly($viewModel.inventoryDuration)
                .disabled(viewModel.inventoryFlag)
                .onChange(of: viewModel.inventoryDuration) { newValue in
                    viewModel.inventoryDuration = newValue.filter { $0.isNumber }
                }
            Text("s")
            Spacer()
            Text("\(viewModel.inventoryTime)s")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
            Spacer()
        }
        .padding(.horizontal, 10)
        .onReceive(viewModel.timer) { _ in
            if viewModel.inventoryFlag {
                viewModel.inventoryTime = String(format: "%.1f", Date().timeIntervalSince(viewModel.startTime))
            }
        }
    }

    // MARK: InventoryList View

    struct InventoryList: View {
        @EnvironmentObject private var appState: AppState
        @EnvironmentObject private var globalOverlay: GlobalOverlay

        @State private var selectedTag: RFIDTagInfo?
        let tagList: [RFIDTagInfo]
        let all: Int

        init(_ tagList: [RFIDTagInfo], _ all: Int) {
            self.tagList = tagList
            self.all = all
        }

        var body: some View {
            List {
                Section(header: listHeader) {
                    ForEach(tagList) { tag in
                        let tagActionSheet = Binding<Bool>(
                            get: { selectedTag == tag },
                            set: { newValue in
                                if newValue {
                                    selectedTag = tag
                                } else {
                                    selectedTag = nil
                                }
                            }
                        )

                        HStack {
                            VStack(alignment: .leading) {
                                if !tag.reserved.isEmpty {
                                    Text("RESERVED:\(tag.reserved)")
                                }
                                if tag.reserved.isEmpty && tag.tid.isEmpty {
                                    Text(tag.epc)
                                } else {
                                    Text("EPC:\(tag.epc)")
                                }
                                if !tag.tid.isEmpty {
                                    Text("TID:\(tag.tid)")
                                }
                                if !tag.user.isEmpty {
                                    Text("USER:\(tag.user)")
                                }
                            }
                            .conditionalTextSelection()
                            Spacer()
                            Text("\(tag.count)")
                                .frame(minWidth: 30, alignment: .center)
                            if !DevicePlatform.isIPhone {
                                Text("\(tag.antenna)")
                                    .frame(minWidth: 26, alignment: .center)
                            }
                            Text(String(format: "%.2f", tag.rssi))
                                .frame(minWidth: 54, alignment: .center)
                        }
                        .onTapGesture {}
                        .onLongPressGesture(minimumDuration: 0.5) {
                            if tag.reserved.isEmpty && tag.tid.isEmpty {
                                PasteboardUtils.setStringToPasteboard(tag.epc)
                                toast.show(tag.epc)
                            } else {
                                selectedTag = tag
                            }
                        }
                        #if !os(macOS)
                        .actionSheet(isPresented: tagActionSheet) {
                            var buttons: [ActionSheet.Button] = []
                            if !tag.reserved.isEmpty {
                                buttons.append(.default(Text("Copy RESERVED")) {
                                    PasteboardUtils.setStringToPasteboard(tag.reserved)
                                    toast.show(tag.reserved)
                                })
                            }
                            buttons.append(.default(Text("Copy EPC")) {
                                PasteboardUtils.setStringToPasteboard(tag.epc)
                                toast.show(tag.epc)
                            })
                            if !tag.tid.isEmpty {
                                buttons.append(.default(Text("Copy TID")) {
                                    PasteboardUtils.setStringToPasteboard(tag.tid)
                                    toast.show(tag.tid)
                                })
                            }
                            if !tag.user.isEmpty {
                                buttons.append(.default(Text("Copy USER")) {
                                    PasteboardUtils.setStringToPasteboard(tag.user)
                                    toast.show(tag.user)
                                })
                            }
                            buttons.append(.cancel())

                            return ActionSheet(
                                title: Text(""),
                                buttons: buttons
                            )
                        }
                        #endif
                    }
                }
            }
            .listStyle(.plain) 
        }

        var listHeader: some View {
            HStack {
                Text("Tag:")
                Text("\(tagList.count)").font(.system(.body, design: .monospaced))
                Spacer()
                Text("All:")
                Text("\(all)").font(.system(.body, design: .monospaced))
                Spacer()
                Text("Count")
                    .frame(width: 50, alignment: .trailing)
                if !DevicePlatform.isIPhone {
                    Text("Ant")
                        .frame(width: 30, alignment: .center)
                }
                Text("RSSI")
                    .frame(width: 50, alignment: .center)
            }.frame(minHeight: 30)
        }
    }

    // MARK: Export

    func export() {
        if viewModel.inventoryFlag {
            toast.show("Please stop inventory first")
            return
        }
        if viewModel.tagList.isEmpty {
            toast.show("No data to export")
            return
        }

        globalOverlay.showCustomView(dismissable: false) {
            VStack {
                Text("Exporting data...")
                    .frame(width: 200)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .shadow(radius: 10)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }

        let res = viewModel.exportToXlsx()
        globalOverlay.hide()
        toast.show(res, 3)
    }
}

#Preview {
    VStack {
        InventoryView()
            .environmentObject(AppState.shared)
    }
}
