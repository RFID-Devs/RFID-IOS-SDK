//
//  Data.swift
//  RFIDTools
//
//  Created by zsg on 2024/6/12.
//

import Foundation

extension Data {
    var hexDescription: String {
        let dataStr = map { String(format: "%02hhx ", $0) }.joined().trimmingCharacters(in: .whitespaces)
        return "{len=\(count), data=\(dataStr)}"
    }

    var hexString: String {
        let dataStr = map { String(format: "%02hhx", $0) }.joined().trimmingCharacters(in: .whitespaces)
        return dataStr
    }
}
