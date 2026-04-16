//
//  ContentView.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/5.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var globalOverlay = GlobalOverlay()

    var body: some View {
        ZStack(alignment: Alignment.leading) {
            MainView()

            if globalOverlay.isShowing {
                // Click on the mask to close the popup
                Color.gray
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if globalOverlay.dismissable {
                            globalOverlay.hide()
                        }
                    }

                VStack {
                    globalOverlay.customView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    //  .padding(30)
                }
            }

            ToastView()
        }
        .environment(\.locale, .init(identifier: appState.localication.rawValue))
        .environmentObject(appState)
        .environmentObject(toast)
        .environmentObject(globalOverlay)
        .onAppear {
            #if os(iOS)
                // phone monitors the screen direction, iPad and Mac fixed .landscape, no monitoring required
                if UIDevice.current.userInterfaceIdiom == .phone {
                    NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                        let deviceOrientation = UIDevice.current.orientation
                        
                        var orientation = appState.orientation
                        if deviceOrientation == .portrait {
                            orientation = .portrait
                        } else if deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight {
                            orientation = .landscape
                        }

                        if appState.orientation != orientation {
                            appState.orientation = orientation
                        }

//                         print("deviceOrientation=\(deviceOrientation.rawValue)  appState.orientation=\(appState.orientation)")
                    }
                }
            #endif
        }
    }
}

#Preview {
    ContentView()
}
