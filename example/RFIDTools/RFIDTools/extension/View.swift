//
//  View.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/6.
//

import SwiftUI

extension View {
    /// 数字专用输入框（自动适配 iOS 数字键盘）  
    /// 适用于 `TextField`、`TextEditor`
    /// - Parameters:
    ///   - text: 绑定的文本
    ///   - includeDecimal: 是否允许小数点（默认false）
    func numbersOnly(_ text: Binding<String>, includeDecimal: Bool = false) -> some View {
        modifier(NumbersOnlyViewModifier(text: text, includeDecimal: includeDecimal))
        #if os(iOS)
            .keyboardType(includeDecimal ? .decimalPad : .numberPad)
        #endif
    }

    /// 可能会造成状态丢失，谨慎使用
    @ViewBuilder
    func hidden(_ isHidden: Bool) -> some View {
        if isHidden {
            hidden()
        } else {
            self
        }
    }

    /// only recommended to be used by macOS 
    @ViewBuilder
    func conditionalTextSelection() -> some View {
        if #available(iOS 999, macOS 12.0, *) {
            self.textSelection(.enabled)
        } else {
            self
        }
    }

    @ViewBuilder
    func flexibleButtonSizing() -> some View {
        if #available(macOS 26.0, iOS 26.0, *) {
            // .flexible can only be compiled on macOS 26 or later. If compilation error, please just return self.
            self.buttonSizing(.flexible)
        } else {
            self
        }
    }
}

private struct NumbersOnlyViewModifier: ViewModifier {
    @Binding var text: String
    let includeDecimal: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: text) { newValue in
                // 过滤非数字字符（可选支持小数点）
                let filtered = newValue.filter {
                    $0.isNumber || (includeDecimal && $0 == ".")
                }

                // 避免多个小数点
                if includeDecimal {
                    let components = filtered.components(separatedBy: ".")
                    if components.count > 2 {
                        text = String(filtered.dropLast())
                        return
                    }
                }

                if filtered != newValue {
                    text = filtered
                }
            }
    }
}
