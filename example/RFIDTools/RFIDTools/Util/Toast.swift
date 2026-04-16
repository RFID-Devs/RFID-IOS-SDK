//
//  Toast.swift
//  RFIDTools
//
//  Created by zsg on 2024/5/9.
//

import Foundation
import SwiftUI

struct ToastView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject var toastManager: ToastManager

    var body: some View {
        VStack {
            if let message = toastManager.message {
                Spacer()
                VStack {
                    Text(message.localizedString(appState.localication))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation {
                                toastManager.message = nil
                            }
                        }
                        .transition(.move(edge: .bottom))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .edgesIgnoringSafeArea(.all)
                Spacer()
            }
        }
    }
}

class ToastManager: ObservableObject {
    @Published var message: String?
    private var dismissTask: DispatchWorkItem?

    func show(_ message: String, _ timeout: Double = 1.5) {
        // 如果已经有一个Toast正在显示，取消它的消失任务
        cancelDismissTask()

        DispatchQueue.main.async {
            // 更新消息
            self.message = message
        }

        // 创建一个新的消失任务
        let task = DispatchWorkItem {
            withAnimation {
                self.message = nil
            }
        }

        // 保存任务引用
        dismissTask = task

        // 安排任务在指定时间后执行
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: task)
    }

    private func cancelDismissTask() {
        dismissTask?.cancel()
        dismissTask = nil
    }
}

// 创建一个全局的ToastManager实例
let toast = ToastManager()
