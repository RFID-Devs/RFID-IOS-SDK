//
//  LocationView.swift
//  RFIDTools
//
//  Created by zsg on 2024/6/7.
//

import Combine
import Foundation
import RFIDManager
import SwiftUI

struct LocationView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isEditing = false

    @State var filter: FilterEntity = .init()
    @State var locationFlag = false
    @State var dynamicDistance = 30
    @State var value: Double = 0

    @State var cancellables = Set<AnyCancellable>()

    let locationQueue = DispatchQueue(label: "com.RFIDTools.locationQueue")

    var body: some View {
        GeometryReader { geometry in
            if appState.orientation == .portrait {
                VStack {
                    FilterView(filter: $filter)
                    buttonView
                    dynamicDistanceView
                    rectangleView
                    Spacer()
                }
            } else {
                HStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        FilterView(filter: $filter)
                        dynamicDistanceView
                        Spacer()
                        buttonView.padding()
                    }
                    .frame(width: geometry.size.width / 1.8)
                    Spacer()
                    rectangleView
                    Spacer()
                }
            }
        }
        .onAppear {
            // Page changes listening
            AppState.shared
                .$selectedPage
                .receive(on: DispatchQueue.main)
                .sink { newPage in
                    if AppState.shared.selectedPage != .Location, locationFlag == true {
                        location()
                    }
                }
                .store(in: &cancellables)

            // Bluetooth connection status listening
            AppState.shared
                .$connectState
                .receive(on: DispatchQueue.main)
                .sink { state in
                    if state == .disconnected {
                        locationFlag = false
                    }
                }
                .store(in: &cancellables)

            // Device keyEvent listening
            RFIDBleManager.shared
                .keyEventPublisher
                .receive(on: DispatchQueue.main)
                .sink { keyEvent in
                    keyEventHandler(keyEvent)
                }
                .store(in: &cancellables)
            RFIDUsbManager.shared
                .keyEventPublisher
                .receive(on: DispatchQueue.main)
                .sink { keyEvent in
                    keyEventHandler(keyEvent)
                }
                .store(in: &cancellables)
        }
        .onDisappear {
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
    }

    var buttonView: some View {
        Button(locationFlag ? "Stop" : "Start") { location() }
            .outlinedStyle()
            .padding(.horizontal, 6)
    }

    var dynamicDistanceView: some View {
        VStack {
            HStack {
                Text("Dynamic Distance")
                Spacer()
                HStack(spacing: 0) {
                    Button {
                        if dynamicDistance < 5 { return }
                        dynamicDistance -= 1
                        if !isEditing {
                            RFIDManager.getInstance().setDynamicDistance(dynamicDistance)
                        }
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 40, height: 28)
                            .background(Color.gray.opacity(0.1))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!locationFlag || dynamicDistance <= 5)

                    Divider().frame(height: 28)

                    Button {
                        if dynamicDistance > 30 { return }
                        dynamicDistance += 1
                        if !isEditing {
                            RFIDManager.getInstance().setDynamicDistance(dynamicDistance)
                        }
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 40, height: 28)
                            .background(Color.gray.opacity(0.1))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!locationFlag || dynamicDistance >= 30)
                }
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .cornerRadius(6)
            }
            .padding(10)

            Slider(
                value: Binding(
                    get: { Double(dynamicDistance) }, 
                    set: { value in 
                        dynamicDistance = Int(value) 
                    }
                ), 
                in: 5 ... 30,
                onEditingChanged: { isEditing in
                    if !isEditing {
                        RFIDManager.getInstance().setDynamicDistance(dynamicDistance)
                    }
                    self.isEditing = isEditing
                }
            )
            .disabled(!locationFlag)
            .padding(.horizontal, 25)
        }
    }

    var rectangleView: some View {
        GeometryReader { geometry in
            HStack(alignment: .center) {
                Spacer()
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .stroke(Color.gray, lineWidth: 2)
                        .frame(width: 50, height: geometry.size.height)
                    Rectangle()
                        .frame(width: 48, height: geometry.size.height * value / 100)
                        .foregroundColor(Color(hex: 0x50A9F4))
                }
                Spacer()
            }
        }
        .padding(.vertical, 10)
    }


    func keyEventHandler(_ keyEvent: RFIDKeyEvent) {
        if AppState.shared.selectedPage != .Location {
            return
        }
        location()
    }

    func location() {
        var res: RFIDResult
        if locationFlag {
            res = RFIDManager.getInstance().stopLocation() 
        } else {
            locationQueue.asyncAfter(deadline: .now() + 0.3) {
                dynamicDistance = 30
            }
            res = RFIDManager.getInstance().startLocation(
                filter: filter.toRFIDFilter(),
                locateInfoBlock: { locateInfo in
                    print("locateInfoBlock value=\(locateInfo.value)")
                    AudioPlayer.shared.playAudio()
                    // if filter.isEqualTagInfo(locateInfo.tag) {
                    value = locateInfo.value
                    // }
                }
            )
        }
        if res.code == .success {
            locationFlag.toggle()
        } else {
            toast.show(res.message ?? "Failure")
        }
    }
}

#Preview {
    LocationView()
        .environmentObject(AppState.shared)
}
