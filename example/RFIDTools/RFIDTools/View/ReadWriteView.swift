//
//  ReadWriteView.swift
//  RFIDTools
//
//  Created by zsg on 2024/5/16.
//

import Foundation
import RFIDManager
import SwiftUI

struct ReadWriteView: View {
    @EnvironmentObject private var appState: AppState

    @State var filter: FilterEntity = .init()
    @State var offset: Int = 2
    @State var offsetString: String = ""
    @State var length: Int = 6
    @State var lengthString: String = ""
    @State var bank: RFIDBank = .EPC
    @State var password: String = "00000000"
    @State var data: String = ""

    var body: some View {
        ScrollView {
            VStack {
                FilterView(filter: $filter)
                HStack {
                    Text("Offset:")
                    TextField("", text: $offsetString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .numbersOnly($offsetString)
                        .frame(maxWidth: 100)
                        .onAppear {
                            offsetString = "\(offset)"
                        }
                        .onChange(of: offsetString) { newValue in
                            self.offset = Int(newValue) ?? 0
                        }
                    Text("(word)")
                    Spacer()
                }
                .padding(.horizontal, 6)
                HStack {
                    Text("Length:")
                    TextField("", text: $lengthString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .numbersOnly($lengthString)
                        .frame(maxWidth: 100)
                        .onAppear {
                            lengthString = "\(length)"
                        }
                        .onChange(of: lengthString) { newValue in
                            self.length = Int(newValue) ?? 0
                        }
                    Text("(word)")
                    Spacer()
                }
                .padding(.horizontal, 6)
                HStack(alignment: .center) {
                    Text("Bank:")
                    Picker("", selection: $bank) {
                        ForEach(RFIDBank.allCases, id: \.self) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.trailing, 8)
                    .onChange(of: bank) { _ in
                        switch bank {
                        case .RESERVED:
                            offsetString = "0"
                            lengthString = "4"
                        case .EPC:
                            offsetString = "2"
                            lengthString = "6"
                        case .TID, .USER:
                            offsetString = "0"
                            lengthString = "6"
                        default:
                            break
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 6)
                HStack {
                    Text("Password:")
                    TextField("00000000", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer()
                }
                .padding(.horizontal, 6)
                HStack {
                    Text("Data:")
                    TextEditor(text: $data)
                    #if os(macOS)
                        .padding(EdgeInsets(top: 4, leading: 2, bottom: 4, trailing: 2))
                        .background(.background)
                    #endif
                        .frame(minHeight: 32)
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous).stroke(.gray, lineWidth: 0.3)
                        )
                        .onChange(of: data) { _ in
                            let len = data.count / 4
                            lengthString = "\(len)"
                        }
                    Spacer()
                }
                .padding(.horizontal, 6)

                HStack(spacing: 10) {
                    Button("Write") { writeTag() }
                        .outlinedStyle()
                    Button("Read") { readTag() }
                        .outlinedStyle()
                }
                .padding(EdgeInsets(top: 15, leading: 10, bottom: 30, trailing: 10))
            }
        }
    }

    func readTag() {
        let tempLen = length
        let res = RFIDManager.getInstance().readData(
            filter: filter.toRFIDFilter(),
            bank: bank.rawValue,
            offset: offset,
            length: length,
            password: password
        )
        if res.code == .success {
            data = res.data as! String
            toast.show(data)
        } else {
            data = ""
            toast.show(res.message ?? "Failure")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                lengthString = "\(tempLen)"
            }
        }
    }

    func writeTag() {
        let res = RFIDManager.getInstance().writeData(
            filter: filter.toRFIDFilter(),
            bank: bank.rawValue,
            offset: offset,
            length: length,
            password: password,
            data: data
        )
        if res.code == .success {
            toast.show("Success")
        } else {
            toast.show(res.message ?? "Failure")
        }
    }
}

#Preview {
    ReadWriteView()
        .environmentObject(AppState.shared)
}
