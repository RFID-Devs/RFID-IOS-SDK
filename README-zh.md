# RFIDManager 中文文档

Apple 全平台的 RFID 标签读写管理框架

### Overview

> 中文文档 ｜ [English](README.md)

RFIDManager 是一个专为 Apple 平台设计的 RFID SDK，实现了完整的 RFID 标签读写、盘点、定位等功能。SDK 采用现代 Swift 语言开发，提供简洁易用的 API 接口。

### 平台支持

|通信方式\平台|iOS|iPad|macOS|
|:-:|:-:|:-:|:-:|
|蓝牙|✅|✅|✅|
|USB|❌|❌|✅|

### 核心功能

- **标签盘点**: 快速扫描和识别大量 RFID 标签
- **标签读写**: 读取和写入标签的 EPC、TID、User 等内存区
- **标签定位**: 基于 RSSI 的标签定位和寻找功能
- **条码扫描**: 集成条码扫描功能
- **设备管理**: 完整的设备连接、配置和状态管理

### 文档和教程

- [RFIDManager API文档](https://rfid-devs.github.io/RFID-IOS-SDK)
- [初识RFIDManager](https://rfid-devs.github.io/RFID-IOS-SDK/tutorials/meet-rfidmanager)
