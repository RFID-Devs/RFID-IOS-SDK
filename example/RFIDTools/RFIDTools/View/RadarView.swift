//
//  RadarView.swift
//  RFIDTools
//
//  Created by zsg on 2024/4/26.
//

import Combine
import Foundation
import RFIDManager
import SwiftUI

struct RadarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isEditing = false

    @State var filter: FilterEntity = .init()
    @State var radarLocationFlag = false
    @State var dynamicDistance = 30
    @State var azimuth: Double = 0.0
    @State var radarList: [RFIDLocateInfo] = []

    @State var cancellables = Set<AnyCancellable>()

    let radarQueue = DispatchQueue(label: "com.RFIDTools.radarQueue")

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            FilterView(filter: $filter)

            Button(radarLocationFlag ? "Stop" : "Start") { radarLocation() }
                .outlinedStyle()
                .padding(.horizontal, 6)

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
                    .disabled(!radarLocationFlag || dynamicDistance <= 5)

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
                    .disabled(!radarLocationFlag || dynamicDistance >= 30)
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
            .disabled(!radarLocationFlag)
            .padding(.horizontal, 25)

            if appState.orientation == .landscape {
                Text("Please use the portrait orientation.")
                    .foregroundColor(.red)
            }

            RadarDrawView(target: filter, angle: -self.azimuth, radarList: self.radarList)
                .frame(maxWidth: 500)
                .padding()

            Spacer()
        }
        .onAppear {
            // Page changes listening
            AppState.shared
                .$selectedPage
                .receive(on: DispatchQueue.main)
                .sink { newPage in
                    if AppState.shared.selectedPage != .Radar, radarLocationFlag == true {
                        radarLocation()
                    }
                }
                .store(in: &cancellables)

            // Bluetooth connection status listening
            AppState.shared
                .$connectState
                .receive(on: DispatchQueue.main)
                .sink { state in
                    if state == .disconnected {
                        radarLocationFlag = false
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


    func keyEventHandler(_ keyEvent: RFIDKeyEvent) {
        if AppState.shared.selectedPage != .Radar {
            return
        }
        radarLocation()
    }

    func radarLocation() {
        var res: RFIDResult
        if radarLocationFlag {
            res = RFIDManager.getInstance().stopRadarLocation()
        } else {
            radarQueue.asyncAfter(deadline: .now() + 0.3) {
                dynamicDistance = 30
            }
            res = RFIDManager.getInstance().startRadarLocation(
                filter: filter.toRFIDFilter(),
                radarInfoBlock: { radarTagList in
                    AudioPlayer.shared.playAudio()
                    radarList = radarTagList
//                  for tag in radarList {
//                      print("tag=\(tag.description)")
//                  }
                },
                radarAngleBlock: { azimuth in
                    // print("azimuth=\(azimuth)")
                    self.azimuth = azimuth
                }
            )
        }

        if res.code == .success {
            radarLocationFlag.toggle()
        } else {
            toast.show(res.message ?? "Failure")
        }
//      print("res=\(res.description)")
    }
}

#Preview {
    RadarView()
        .environmentObject(AppState.shared)
}
