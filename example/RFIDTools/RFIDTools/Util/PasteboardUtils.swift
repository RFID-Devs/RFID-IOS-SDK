//
//  PasteboardUtils.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/6.
//

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

class PasteboardUtils {
    // 静态方法设置粘贴板内容
    static func setStringToPasteboard(_ string: String) {
        #if os(iOS)
            // iOS 使用 UIPasteboard
            UIPasteboard.general.string = string
        #elseif os(macOS)
            // macOS 使用 NSPasteboard
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents() // 清空现有内容
            pasteboard.setString(string, forType: .string) // 设置新内容
        #endif
    }

    // 静态方法从粘贴板获取字符串
    static func getStringFromPasteboard() -> String? {
        #if os(iOS)
            // iOS 使用 UIPasteboard
            return UIPasteboard.general.string
        #elseif os(macOS)
            // macOS 使用 NSPasteboard
            let pasteboard = NSPasteboard.general
            return pasteboard.string(forType: .string)
        #endif
    }
}
