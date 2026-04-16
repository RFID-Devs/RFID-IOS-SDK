//
//  UserDrivenPicker.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/9.
//

import SwiftUI

struct UserDrivenPicker<SelectionValue: Hashable, Content: View>: View {
    @ObservedObject var controller: UserDrivenValue<SelectionValue>
    let content: () -> Content
    private var userChangeHandler: ((SelectionValue) -> Void)?

    init(
        controller: UserDrivenValue<SelectionValue>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.controller = controller
        self.content = content
    }

    var body: some View {
        Picker("", selection: controller.makeBinding(), content: content)
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: controller.value) { newValue in
                if controller.isUserChange {
                    controller.isUserChange = false
                    userChangeHandler?(newValue)
                }
            }
    }

    func onUserChange(_ action: @escaping (SelectionValue) -> Void) -> UserDrivenPicker<SelectionValue, Content> {
        var newView = self
        newView.userChangeHandler = action
        return newView
    }
}
