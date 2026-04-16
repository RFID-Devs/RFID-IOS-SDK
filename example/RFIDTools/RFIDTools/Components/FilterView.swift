//
//  FilterView.swift
//  RFIDTools
//
//  Created by zsg on 2024/4/29.
//

import Foundation
import RFIDManager
import SwiftUI

struct FilterView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @Binding var filter: FilterEntity

    @State private var offsetString: String = "32"
    @State private var lengthString: String = "96"
    @State private var dataString: String = ""
    @State private var isExpanded: Bool = false
    @State private var selectedBank: RFIDBank = .EPC

    var isPortrait = true

    var body: some View {
        VStack(spacing: 0) {
            filterHeader
            if isExpanded {
                filterContent
            }
        }
        .frame(alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(.gray, lineWidth: 1)
        )
        .padding(6)
    }

    private var filterHeader: some View {
        HStack {
            Button(action: {
                withAnimation {
                    filter.enable.toggle()
                    isExpanded = filter.enable
                }
            }) {
                if filter.enable {
                    Image(systemName: "checkmark.square")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .frame(width: 25.0, height: 25.0)
                    Text("Filter")
                        .font(.title2)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                } else {
                    Image(systemName: "square")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.gray)
                        .frame(width: 25.0, height: 25.0)
                    Text("Filter")
                        .font(.title2)  
                        .foregroundColor(.gray)
                }
            }
            .padding(8)
            .contentShape(Rectangle())
            .buttonStyle(.plain)

            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.gray)
                        .frame(width: 16.0, height: 16.0)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var filterContent: some View {
        VStack {
            if !isPortrait {
                VStack {
                    offsetTextField
                    lengthTextField
                }
                .frame(maxWidth: .infinity)
            } else {
                HStack {
                    offsetTextField
                    lengthTextField
                }
                .frame(maxWidth: .infinity)
            }

            HStack {
                Text("Bank:")
                Picker("", selection: $selectedBank) {
                    ForEach(RFIDBank.allCases.filter { $0 != .RESERVED }, id: \.self) { value in
                        Text(value.description).tag(value)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.trailing, 8)
                .flexibleButtonSizing()
                .onChange(of: selectedBank) { bank in
                    filter.bank = bank
                    switch bank {
                    case .EPC:
                        offsetString = "32"
                        filter.offset = 32
                    default:
                        offsetString = "0"
                        filter.offset = 0
                    }
                }
                .onChange(of: filter.bank) { newValue in
                    DispatchQueue.main.async { selectedBank = newValue }
                }
                .onAppear { selectedBank = filter.bank }
                .padding(.trailing, 8)
                #if os(macOS)
                    .padding(.leading, -8)
                #endif
                Spacer()
            }

            HStack {
                Text("Data:")
                TextField("", text: $filter.data)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: filter.data) { data in
                        DispatchQueue.main.async {
                            lengthString = "\(data.count * 4)"
                        }
                    }
                Spacer()
            }
        }
        .padding(8)
    }

    private var offsetTextField: some View {
        HStack {
            Text("Offset:")
            TextField("", text: $offsetString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .numbersOnly($offsetString)
                .onChange(of: offsetString) { newValue in
                    DispatchQueue.main.async {
                        filter.offset = Int(newValue) ?? 0
                    }
                }
            Text("(bit)")
            Spacer()
        }
    }

    private var lengthTextField: some View {
        HStack {
            Text("Length:")
            TextField("", text: $lengthString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .numbersOnly($lengthString)
                .onChange(of: lengthString) { newValue in
                    DispatchQueue.main.async {
                        filter.length = Int(newValue) ?? 0
                    }
                }
            Text("(bit)")
            Spacer()
        }
    }
}

// #Preview {
//    VStack {
//        @State var filter = FilterEntity(true)
//        FilterView(filter: $filter)
//    }
// }
