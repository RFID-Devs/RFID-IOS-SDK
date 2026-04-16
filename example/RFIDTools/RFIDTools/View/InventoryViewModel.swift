//
//  InventoryViewModel.swift
//  RFIDTools
//
//  Created by zsg on 2025/6/9.
//

import Combine
import Foundation
import RFIDManager
#if os(macOS)
    import AppKit
#endif

// MARK: - InventoryViewModel

class InventoryViewModel: ObservableObject {
    static let shared = InventoryViewModel()

    @Published var filter: FilterEntity = .init()
    @Published var inventoryFlag = false
    @Published var tagList: [RFIDTagInfo] = []
    @Published var all = 0

    @Published var inventoryDuration = ""
    @Published var inventoryTime = "0"
    @Published var stopInventoryTimer: Timer?
    @Published var startTime = Date()
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @Published var tagQueue = DispatchQueue(label: "com.RFIDTools.tagQueue")

    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Page changes listening
        AppState.shared
            .$selectedPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPage in
                print("InventoryViewModel newPage = \(newPage)")
                if AppState.shared.selectedPage != .Inventory, self?.inventoryFlag == true {
                    self?.stopInventory()
                }
            }
            .store(in: &cancellables)

        // Bluetooth connection status listening
        AppState.shared
            .$connectState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if state == .disconnected {
                    self?.inventoryFlag = false
                }
            }
            .store(in: &cancellables)

        // Device keyEvent listening
        RFIDBleManager.shared
            .keyEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keyEvent in
                self?.keyEventHandler(keyEvent)
            }
            .store(in: &cancellables)
        RFIDUsbManager.shared
            .keyEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keyEvent in
                self?.keyEventHandler(keyEvent)
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    func keyEventHandler(_ keyEvent: RFIDKeyEvent) {
        if AppState.shared.selectedPage != .Inventory {
            return
        }
        print("keyEvent=\(keyEvent)")

        if keyEvent.isKeyDown {
            startInventory()
        } else if keyEvent.isKeyUp {
            if keyEvent.keyCode == 1 {
                inventory()
            } else {
                stopInventory()
            }
        }
    }

    func clear() {
        tagList.removeAll()
        all = 0
        inventoryTime = "0"
    }

    // MARK: Inventory Func

    func sinleInventory() {
        tagQueue.async {
            let res = RFIDManager.getInstance().singleInventory(filter: self.filter.toRFIDFilter())
            if let data = res.data {
                self.addTagToList(data as! RFIDTagInfo)
            } else {
                toast.show(res.message ?? "Failure")
            }
//            print(res.description)
        }
    }

    func inventory() {
        print("invnetory = \(inventoryFlag)")

        if inventoryFlag {
            stopInventory() 
        } else {
            startInventory()
        }
    }

    func startInventory() {
        if inventoryFlag {
            return
        }
        let res = RFIDManager.getInstance().startInventory(
            filter: filter.toRFIDFilter(), 
            inventoryParam: RFIDInventoryParam(unique: false),
            tagInfoListBlock: { tagInfoList in
//                print("tagInfoList = \(tagInfoList)")
                self.tagQueue.async {
                    for tagInfo in tagInfoList {
                        self.addTagToList(tagInfo)
                    }
                }
            }
        )
        if res.code == .success {
            inventoryFlag = true
            startTimer()

            stopInventoryTimer = Timer.scheduledTimer(
                withTimeInterval: TimeInterval(inventoryDuration) ?? 999_999, 
                repeats: false
            ) { _ in
                if self.inventoryFlag {
                    self.stopInventory()
                }
            }
            RunLoop.current.add(stopInventoryTimer!, forMode: .common)

        } else {
            toast.show(res.message ?? "Failure")
        }
    }

    func stopInventory() {
        if !inventoryFlag {
            return
        }
        let res = RFIDManager.getInstance().stopInventory()
        if res.code == .success {
            inventoryFlag = false
            stopInventoryTimer?.invalidate()
            stopTimer()
        } else {
            toast.show(res.message ?? "Failure")
        }
    }

    func startTimer() {
        startTime = Date()
        timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    }

    func stopTimer() {
        timer.upstream.connect().cancel()
    }

    // MARK: addTagToList

    func addTagToList(_ tagInfo: RFIDTagInfo) {
        AudioPlayer.shared.playAudio()
        DispatchQueue.main.async {
            let (index, exist) = self.binarySearchInsertionIndex(of: tagInfo, in: self.tagList)
            if exist {
                self.tagList[index].count += tagInfo.count
                self.tagList[index].rssi = tagInfo.rssi
                self.tagList[index].antenna = tagInfo.antenna
            } else {
                self.tagList.insert(tagInfo, at: index)
                // RFIDManager.triggerBeep(duration: 40)
            }
            self.all += tagInfo.count
        }
    }

    func binarySearchInsertionIndex(of tagInfo: RFIDTagInfo, in list: [RFIDTagInfo]) -> (Int, Bool) {
        var low = 0
        var high = list.count - 1

        while low <= high {
            let mid = low + (high - low) / 2
            if list[mid] == tagInfo {
                // Finds equal element, returns the index
                return (mid, true)
            } else if list[mid] < tagInfo {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }

        // Returns the index which the new element should be inserted.
        return (low, false)
    }


    // MARK: Export

    func exportToXlsx() -> String {
        var targetPath: String?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "rfid_\(dateFormatter.string(from: Date())).xlsx"

        #if os(iOS)
            // iOS - 保存到沙盒的Document/export目录
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? NSHomeDirectory()
            let exportDir = "\(documentDirectory)/export"
            let fileManager = FileManager.default

            // 创建export目录（如果不存在）
            if !fileManager.fileExists(atPath: exportDir) {
                do {
                    try fileManager.createDirectory(atPath: exportDir, withIntermediateDirectories: true)
                } catch {
                    return "Create directory error: \(error)"
                }
            }

            targetPath = "\(exportDir)/\(fileName)"
        #elseif os(macOS)
            // macOS - 使用保存面板选择位置
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.spreadsheet] // macOS 11+
            savePanel.nameFieldStringValue = fileName

            // 同步显示保存面板（主线程）
            let response = savePanel.runModal()
            guard response == .OK, let url = savePanel.url else {
                return "Export cancelled"
            }

            targetPath = url.path
        #endif

        guard let finalPath = targetPath else {
            return "Invalid file path" 
        }

        print("Export Path: \(finalPath)")

        // create .xlsx file
        guard let workbook = workbook_new(finalPath.cString(using: .utf8)) else {
            return "Create .xlsx File fail"
        }

        // ========== Create a format object ==========
        // 表头格式（居中 + 加粗）
        let headerFormat = workbook_add_format(workbook)
        format_set_bold(headerFormat)
        format_set_align(headerFormat, UInt8(LXW_ALIGN_CENTER.rawValue))
        format_set_align(headerFormat, UInt8(LXW_ALIGN_VERTICAL_CENTER.rawValue))
        // 数据格式 - 居左 + 垂直居中 + 可换行（用于 EPC/TID/USER/RESERVED）
        let leftWrapFormat = workbook_add_format(workbook)
        format_set_align(leftWrapFormat, UInt8(LXW_ALIGN_LEFT.rawValue))
        format_set_align(leftWrapFormat, UInt8(LXW_ALIGN_VERTICAL_CENTER.rawValue))
        format_set_text_wrap(leftWrapFormat) // 启用自动换行
        // 数据格式 - 居中（用于 PC/RSSI/COUNT）
        let centerFormat = workbook_add_format(workbook)
        format_set_align(centerFormat, UInt8(LXW_ALIGN_CENTER.rawValue))
        format_set_align(centerFormat, UInt8(LXW_ALIGN_VERTICAL_CENTER.rawValue))

        // Add worksheet
        guard let worksheet = workbook_add_worksheet(workbook, nil) else {
            workbook_close(workbook)
            return "Create worksheet fail " 
        }

        // ========== set column width / set row height ==========
        worksheet_set_column(worksheet, 0, 0, 24.5, nil) // EPC 
        worksheet_set_column(worksheet, 1, 1, 24.5, nil) // TID 
        worksheet_set_column(worksheet, 2, 2, 24.5, nil) // USER 
        worksheet_set_column(worksheet, 3, 3, 18, nil) // RESERVED 
        worksheet_set_column(worksheet, 4, 6, 10, nil) // PC/RSSI/COUNT 
        worksheet_set_row(worksheet, 0, 20, headerFormat)

        // ========== write header ==========
        let headers = ["EPC", "TID", "USER", "RESERVED", "PC", "Rssi", "Count"]
        for (colIndex, header) in headers.enumerated() {
            worksheet_write_string(
                worksheet, 
                0,
                lxw_col_t(UInt32(colIndex)),
                header.cString(using: .utf8),
                headerFormat
            )
        }

        // ========== write data ==========
        for (rowIndex, tag) in tagList.enumerated() {
            let row = UInt32(rowIndex + 1)
            // EPC (居左 + 自动换行)
            worksheet_write_string(worksheet, row, 0, tag.epc.cString(using: .utf8), leftWrapFormat)
            // TID (居左 + 自动换行)
            worksheet_write_string(worksheet, row, 1, tag.tid.cString(using: .utf8), leftWrapFormat)
            // USER (居左 + 自动换行)
            worksheet_write_string(worksheet, row, 2, tag.user.cString(using: .utf8), leftWrapFormat)
            // RESERVED (居左)
            worksheet_write_string(worksheet, row, 3, tag.reserved.cString(using: .utf8), leftWrapFormat)
            // PC (居中)
            worksheet_write_string(worksheet, row, 4, tag.pc.cString(using: .utf8), centerFormat)
            // RSSI (居中)
            worksheet_write_string(
                worksheet, row, 5, 
                String(format: "%.2f", tag.rssi).cString(using: .utf8), 
                centerFormat
            )
            // COUNT (居中)
            worksheet_write_number(worksheet, row, 6, Double(tag.count), centerFormat)
        }

        // close and save
        workbook_close(workbook)

        if DevicePlatform.isMac {
            return "Export Success. Save in directory:\n\(finalPath)" 
        } else {
            return "Export Success. Save in directory:\nRFIDTools/export/\(fileName)" 
        }
    }
}
