// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RFID-IOS-SDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "RFIDBleSDK",
            targets: ["RFIDBleSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "RFIDBleSDK",
            url: "https://github.com/RFID-Devs/RFID-IOS-SDK/releases/download/v1.1.2/RFIDBleSDK.xcframework.zip",
            checksum: "cbbb60a8b5b63933d40e36866a8ae22af0861655569533c9449dca917aed1a7b"
        )
    ]
)
