// TabConfigManager.swift
// 管理和持久化 TabLayout 的显示项和顺序

import Foundation
import SwiftUI

class TabConfigManager: ObservableObject {
    private let storageKey = "TabConfig_SelectedPages"
    
    @Published var selectedPages: [AppPage] = [] {
        didSet {
            save()
        }
    }
    
    init() {
        load()
    }
    
    func isSelected(_ page: AppPage) -> Bool {
        selectedPages.contains(page)
    }
    
    func toggle(_ page: AppPage) {
        if let idx = selectedPages.firstIndex(of: page) {
            selectedPages.remove(at: idx)
        } else {
            selectedPages.append(page)
        }
    }
    
    func move(fromOffsets: IndexSet, toOffset: Int) {
        selectedPages.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }

    func contains(_ page: AppPage) -> Bool {
        selectedPages.contains(page)
    }
    
    private func save() {
        let raw = selectedPages.map { $0.rawValue }
        UserDefaults.standard.set(raw, forKey: storageKey)
    }
    
    private func load() {
        if let raw = UserDefaults.standard.array(forKey: storageKey) as? [String] {
            let all = AppPage.allCases
            selectedPages = raw.compactMap { str in all.first(where: { $0.rawValue == str }) }
        } else {
            selectedPages = AppPage.allCases
        }
    }
}
