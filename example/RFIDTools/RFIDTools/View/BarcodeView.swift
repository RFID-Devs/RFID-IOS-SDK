//
//  BarcodeView.swift
//  RFIDTools
//
//  Created by zsg on 2024/5/16.
//

import RFIDManager
import SwiftUI

struct BarcodeView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var appState: AppState

    @StateObject var viewModel = BarcodeViewModel()
    @State var showConfig: Bool = false

    var body: some View {
        GeometryReader { geometry in
            if appState.orientation == .portrait {
                VStack {
                    configView
                    barcodesView
                    Spacer()
                    continueCheckView
                    buttonsView
                }
            } else {
                HStack {
                    VStack {
                        ScrollView(.vertical, showsIndicators: false) {
                            configView
                        }
                        Spacer()
                        continueCheckView
                        buttonsView
                    }
                    .frame(width: geometry.size.width * 3 / 7)
                    barcodesView
                        .frame(width: geometry.size.width * 4 / 7)
                        .padding(.trailing, 4)
                }
            }
        }
        .padding(6)
    }

    private var configView: some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation { showConfig.toggle() }
            }) {
                HStack {
                    Image(systemName: "gearshape")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .frame(width: 22.0, height: 22.0)
                        .rotationEffect(.degrees(showConfig ? 90 : 0))
                    Text("Barcode Config")
                        .font(.title3)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit) 
                        .foregroundColor(Color.gray)
                        .frame(width: 16.0, height: 16.0)
                        .rotationEffect(.degrees(showConfig ? 90 : 0))
                }
                .padding(8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if showConfig {
                HStack {
                    Text("Barcode Type")
                    Spacer()
                    UserDrivenPicker(controller: viewModel.barcodeTypeController) {
                        Text("Close").tag(false)
                        Text("Open").tag(true)
                    }
//                    .onUserChange { barcodeType in
//                        viewModel.setBarcodeType(barcodeType)
//                    }
                    .frame(width: 150)
                }
                .padding(8)

                btnSetAndGetRow(
                    set: { viewModel.setBarcodeType(viewModel.barcodeTypeController.value) },
                    get: { viewModel.getBarcodeType() }
                )
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))

                Divider()

                Text("Barcode Paramter")
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                HStack {
                    Text("Key:")
                    TextField("Hexadecimal", text: $viewModel.parameterKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer()
                    Text("Value:")
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    TextField("Hexadecimal", text: $viewModel.parameterValue)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal, 8)

                btnSetAndGetRow(
                    set: viewModel.setBarcodeParameter, 
                    get: viewModel.getBarcodeParameter
                )
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))

                Divider()
            }
        }
        .frame(alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(.gray, lineWidth: 1)
        )
        .padding(1)
    }

    func btnSetAndGetRow(set: @escaping () -> Void, get: @escaping () -> Void) -> some View {
        HStack(spacing: 10) {
            Button("Set") { set() }
                .outlinedStyle()
            Button("Get") { get() }
                .outlinedStyle()
        }
        .padding(.top, 6)
        .padding(.horizontal, 10)
    }

    var continueCheckView: some View {
        HStack {
            Button(action: { viewModel.continuous.toggle() }) {
                Image(systemName: viewModel.continuous ? "checkmark.square" : "square")
                    .resizable(resizingMode: .stretch)
                    .foregroundColor(viewModel.barcodeFlag ? .gray : (colorScheme == .dark ? .white : .black))
                    .frame(width: 20.0, height: 20.0)
                Text("Continuous")
                    .foregroundColor(viewModel.barcodeFlag ? .gray : (colorScheme == .dark ? .white : .black))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.barcodeFlag)
            Spacer()
        }
    }

    var barcodesView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { scrollView in
                VStack {
                    ForEach(viewModel.barcodeList.indices, id: \.self) { index in
                        VStack {
                            HStack {
                                Text(viewModel.barcodeList[index].barcode).id(index)
                                Spacer()
                                Text(getBarcodeInfoType(viewModel.barcodeList[index]))
                                    .foregroundColor(.blue)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                    .id(index)
                            }
                            Divider()
                        }
                        .padding(.vertical, 5)
                        .conditionalTextSelection()
                        .onTapGesture {
                        }
                        .onLongPressGesture(minimumDuration: 0.5) {
                            let barcode = viewModel.barcodeList[index].barcode
                            PasteboardUtils.setStringToPasteboard(barcode)
                            toast.show(barcode)
                        }
                    }
                    .onChange(of: viewModel.barcodeList) { _ in
                        withAnimation {
                            scrollView.scrollTo(viewModel.barcodeList.count - 1, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }

    var buttonsView: some View {
        HStack {
            Button("Clear") { viewModel.barcodeList.removeAll() }
                .outlinedStyle()
            Button(viewModel.barcodeFlag ? "Stop" : "Scan") { viewModel.barcodeToggle() }
                .outlinedStyle()
        }
    }

    func getBarcodeInfoType(_ barcodeInfo: RFIDBarcodeInfo) -> String {
        var type = ""
        if barcodeInfo.ssiId > 0 {
            type = RFIDBarcodeTypeInSSIID.getBarcodeType(barcodeInfo.ssiId)
        } else if barcodeInfo.codeId.rawValue != "" {
            type = barcodeInfo.codeId.rawValue
        }

        return type
    }
}

#Preview {
    BarcodeView()
        .environmentObject(AppState.shared)
}
