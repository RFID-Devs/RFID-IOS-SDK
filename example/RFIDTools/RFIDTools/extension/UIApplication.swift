//
//  UIApplication.swift
//  RFIDBleDemo
//
//  Created by zsg on 2024/6/11.
//

import Foundation

#if canImport(UIKit)
    import UIKit

    // MARK: 不使用IQKeyboardManager的替代方案.  Alternative to not using IQKeyboardManager.

    extension UIApplication {
        // 该函数给应用程序的第一个窗口添加一个轻触手势识别器，允许用户通过点击输入字段外部来关闭键盘。
        // This function adds a tap gesture recognizer to the first window of the application,
        // allowing the user to dismiss the keyboard by tapping outside of text input fields.
        func addTapGestureRecognizer() {
            guard let window = windows.first else { return }

            let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
            tapGesture.requiresExclusiveTouchType = false
            tapGesture.cancelsTouchesInView = false
            tapGesture.delegate = self
            window.addGestureRecognizer(tapGesture)
        }
    }

    extension UIApplication: @retroactive UIGestureRecognizerDelegate {
        // 可以同时响应多个手势.  
        // Can respond to multiple gestures simultaneously
        public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
            return true 
        }

        public func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            // 检查触摸是否发生在UITextField或UITextView上
            // Check if the touch occurred on a UITextField or UITextView
            if let view = touch.view, view.isFirstResponder {
                // 如果是，则不触发手势识别  
                // If so, do not trigger the gesture recognition
                return false 
            }
            // 否则，触发手势识别  
            // Otherwise, trigger the gesture recognition
            return true 
        }
    }

#endif
