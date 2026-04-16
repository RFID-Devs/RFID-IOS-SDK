//
//  Localication.swift
//  RFIDTools
//
//  Created by zsg on 2024/4/26.
//

import Foundation

enum Localication: String, CaseIterable, Identifiable {
    case en = "en"
    case zh_Hans = "zh-Hans"
    var id: String { self.rawValue }
}

extension String {
    func localizedString(_ identifier: Localication = .en) -> String {
        if let path = Bundle.main.path(forResource: identifier.rawValue, ofType: "lproj") {
            if let bundle = Bundle(path: path) {
                return bundle.localizedString(forKey: self, value: self, table: nil)
            }
        }
        return self
    }
}

enum LocaleStrings: String, CaseIterable, Identifiable {
    case en = "English"
    case zh_Hans = "中文"
    var id: String { self.rawValue }
}

extension LocaleStrings {
    var suggestedLocalication: Localication {
        switch self {
            case .zh_Hans: return .zh_Hans
            case .en: return .en
        }
    }
}

//
//class LocaleViewModel: ObservableObject {
//    @Published var localeString: Localication
//    
//    init(_ localeString: Localication) {
//        self.localeString = localeString
//    }
//}

//struct LocalizedStringKey: ExpressibleByStringLiteral {
//    let key: String
//    
//    init(_ key: String) {
//        self.key = key
//    }
//    
//    init(stringLiteral value: String) {
//        self.init(value)
//    }
//}
//
//extension LocalizedStringKey: CustomStringConvertible {
//    var description: String {
//        NSLocalizedString(key, comment: "")
//    }
//}
