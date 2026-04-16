//
//  UserDrivenToggle.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/9.
//

import SwiftUI

struct UserDrivenToggle<Label: View>: View {
    @ObservedObject var controller: UserDrivenValue<Bool>
    let label: () -> Label
    private var userChangeHandler: ((Bool) -> Void)? = nil

    init(controller: UserDrivenValue<Bool>, @ViewBuilder label: @escaping () -> Label) {
        self.controller = controller
        self.label = label
    }

    var body: some View {
        Toggle(isOn: controller.makeBinding()) {
            label()
        }
        .onChange(of: controller.value) { newValue in
            if controller.isUserChange {
                // 重置状态
                controller.isUserChange = false
                // 执行用户回调
                userChangeHandler?(newValue)
            }
        }
    }

    // 添加用户回调的修饰符
    func onUserChange(_ action: @escaping (Bool) -> Void) -> UserDrivenToggle<Label> {
        var newView = self
        newView.userChangeHandler = action
        return newView
    }
}
