//
//  RFIDToolsApp.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/5.
//

import SwiftUI

@main
struct RFIDToolsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            #if !os(macOS)
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
            #endif
        }
    }
}
