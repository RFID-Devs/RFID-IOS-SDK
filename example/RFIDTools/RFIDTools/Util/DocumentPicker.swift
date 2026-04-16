//
//  DocumentPicker.swift
//  RFIDTools
//
//  Created by zsg on 2025/1/14.
//

import RFIDManager
import SwiftUI

#if os(iOS)
    import MobileCoreServices
    import UniformTypeIdentifiers

    struct DocumentPicker: UIViewControllerRepresentable {
        class Coordinator: NSObject, UIDocumentPickerDelegate {
            var parent: DocumentPicker

            init(parent: DocumentPicker) {
                self.parent = parent
            }

            func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
                if let url = urls.first {
                    // Returns the file path
                    parent.didPickFile(url)
                }
            }

            func documentPickerWasCancelled(_: UIDocumentPickerViewController) {
                // Deselect
                parent.didPickFile(nil)
            }
        }

        var didPickFile: (URL?) -> Void
        var upgradeType: RFIDUpgradeType

        init(upgradeType: RFIDUpgradeType, didPickFile: @escaping (URL?) -> Void) {
            self.didPickFile = didPickFile
            self.upgradeType = upgradeType
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(parent: self)
        }

        // Create a file chooser and select only .bin
        func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
            var type: UTType
            if upgradeType == .Bluetooth {
                type = UTType(filenameExtension: "zip")!
            } else {
                type = UTType(filenameExtension: "bin")!
            }

            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [type], asCopy: true)
            documentPicker.delegate = context.coordinator
            return documentPicker
        }

        func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) {}
    }

#endif
