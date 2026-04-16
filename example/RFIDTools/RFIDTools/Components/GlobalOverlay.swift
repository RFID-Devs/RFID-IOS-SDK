//
//  GlobalProgress.swift
//  RFIDTools
//
//  Created by zsg on 2025/1/15.
//

import SwiftUI

// Global pop-up window
class GlobalOverlay: ObservableObject {
    @Published var isShowing = false 
    @Published var customView: AnyView? = nil
    /// enable dialog dismiss on outside touch.
    var dismissable: Bool = false 

    /// Display a global pop-up window, and display the custom view in a modal overlay
    /// 
    /// - Parameters:
    ///   - dismissable: A Boolean value that indicates whether the dialog can be dismissed by tapping outside the dialog. Default is `false`.
    ///   - content: A closure that provides the custom content to be displayed in the modal overlay.
    func showCustomView<Content: View>(dismissable: Bool = false, @ViewBuilder content: () -> Content) {
        customView = AnyView(content())
        isShowing = true
        self.dismissable = dismissable
    }

    /// Hide pop-up window
    func hide() {
        isShowing = false
        customView = nil
    }
}
