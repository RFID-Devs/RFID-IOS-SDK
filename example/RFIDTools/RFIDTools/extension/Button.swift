//
//  Button.swift
//  RFIDTools
//

import SwiftUI


// 便捷扩展
extension Button {
    func outlinedStyle(color: Color = .blue, disabled: Bool = false) -> some View {
        buttonStyle(OutlinedButtonStyle(color: color, disabled: disabled))
            .buttonStyle(.plain)
            .disabled(disabled)
    }
}

// MARK: - OutlinedButtonStyle

/// 自定义圆角边框按钮样式
struct OutlinedButtonStyle: ButtonStyle {
    /// 按钮颜色
    var color: Color = .blue
    /// 是否禁用按钮，用于禁用按钮时显示灰色边框
    var disabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 35)
            .foregroundColor(disabled ? Color.gray : color)
            .background(Color.clear)
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(disabled ? Color.gray : color, lineWidth: 1)
            )
            .opacity(configuration.isPressed || disabled ? 0.46 : 1.0) // 按下时的反馈
    }
}
