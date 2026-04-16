//
//  UserDrivenValue.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/9.
//

import SwiftUI

final class UserDrivenValue<Value>: ObservableObject {
    @Published private(set) var value: Value
    public var isUserChange = false

    init(_ initialValue: Value) {
        value = initialValue
    }

    func makeBinding() -> Binding<Value> {
        Binding<Value>(
            get: { [unowned self] in self.value },
            set: { [unowned self] newValue in
                // 标记为用户操作
                self.isUserChange = true
                DispatchQueue.main.async {
                    self.value = newValue
                }
            }
        )
    }

    func setValue(_ newValue: Value) {
        DispatchQueue.main.async {
            // 程序修改时不标记为userChange
            self.isUserChange = false
            DispatchQueue.main.async {
                self.value = newValue
            }
        }
    }
}
