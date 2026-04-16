//
//  FilterEntity.swift
//  RFIDTools
//
//  Created by zsg on 2024/5/8.
//

import Foundation
import RFIDManager

// filter class to struct
struct FilterEntity {
    var enable: Bool = false
    var bank: RFIDBank = .EPC
    var offset: Int = 32
    var length: Int = 96
    var data: String = ""

    init() {}

    init(_ enable: Bool) {
        self.enable = enable
    }

    init(enable: Bool, bank: RFIDBank, offset: Int, length: Int, data: String) {
        self.enable = enable
        self.bank = bank
        self.offset = offset
        self.length = length
        self.data = data
    }

    init(filter: RFIDFilter) {
        self.enable = filter.enable
        self.bank = RFIDBank(rawValue: filter.bank)!
        self.offset = filter.offset
        self.length = filter.length
        self.data = filter.data
    }

    func toRFIDFilter() -> RFIDFilter {
        return RFIDFilter(enable: enable, bank: bank.rawValue, offset: offset, length: length, data: data)
    }

    func isEqualTagInfo(_ tagInfo: RFIDTagInfo) -> Bool {
        if !enable { return false }
//        if bank == .EPC {
//            return tagInfo.epc.contains(data)
//        } else if bank == .TID {
//            return tagInfo.tid.contains(data)
//        } else if bank == .USER {
//            return tagInfo.user.contains(data)
//        }
        if bank == .EPC {
            return tagInfo.epc == data
        } else if bank == .TID {
            return tagInfo.tid == data
        } else if bank == .USER {
            return tagInfo.user == data
        }
        return false
    }
}
