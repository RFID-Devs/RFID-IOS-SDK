//
//  LockKillView.swift
//  RFIDTools
//

import Foundation
import RFIDManager
import SwiftUI

struct LockKillView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var appState: AppState

    @State var filter: FilterEntity = .init()
    
    // Lock section states
    @State var showLock: Bool = false
    @State var accessPassword: String = ""
    @State var lockMode: RFIDLockMode = .Open
    @State var kill: Bool = false
    @State var access: Bool = false
    @State var epc: Bool = false
    @State var tid = false
    @State var user = false
    
    // Kill section states
    @State var showKill: Bool = false
    @State var killPassword: String = ""
    
    var body: some View {
        ScrollView {
            FilterView(filter: $filter)
            lockSectionView
                .padding(EdgeInsets(top: 2, leading: 5, bottom: 0, trailing: 5))
            killSectionView
                .padding(EdgeInsets(top: 4, leading: 5, bottom: 5, trailing: 5))
        }
    }
    
    // MARK: - Lock Section View

    private var lockSectionView: some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation { showLock.toggle() }
            }) {
                HStack {
                    Image(systemName: "lock")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.orange)
                        .frame(width: 22.0, height: 22.0)
                    Text("Lock/Unlock")
                        .font(.title3)
                        .foregroundColor(Color.orange)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.orange)
                        .frame(width: 16.0, height: 16.0)
                        .rotationEffect(.degrees(showLock ? 90 : 0))
                }
                .padding(8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if showLock {
                // Password field
                HStack {
                    Text("Password:")
                    TextField("can't be default password", text: $accessPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer()
                }
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                
                // LockMode
                VStack(alignment: .leading) {
                    Text("LockMode:")
                    HStack {
                        RadioButton("Unlock", lockMode == .Open, action: { lockMode = .Open })
                        Spacer()
                        RadioButton("PermanentUnlock", lockMode == .PermanentOpen, action: { lockMode = .PermanentOpen })
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 4, trailing: 2))
                    HStack {
                        RadioButton("Lock", lockMode == .Lock, action: { lockMode = .Lock })
                        Spacer()
                        RadioButton("PermanentLock", lockMode == .PermanentLock, action: { lockMode = .PermanentLock })
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 2))
                }
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                
                // LockBank
                VStack(alignment: .leading) {
                    Text("TagBank:")
                    FlowLayout(horizontalSpacing: 30, verticalSpacing: 20, items: [
                        AnyView(CheckButton("Access", access, action: { access.toggle() })),
                        AnyView(CheckButton("Kill", kill, action: { kill.toggle() })),
                        AnyView(CheckButton("EPC", epc, action: { epc.toggle() })),
                        AnyView(CheckButton("TID", tid, action: { tid.toggle() })),
                        AnyView(CheckButton("USER", user, action: { user.toggle() })),
                    ])
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 2))
                }
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                
                // Lock button
                HStack {
                    Spacer()
                    Button("Lock/Unlock") { lockMem() }
                        .outlinedStyle(color: .orange)
                        .frame(width: 200, height: 35)
                    Spacer()
                }
                .padding(.vertical, 6)
            }
        }
        .frame(alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(.orange, lineWidth: 1)
        )
        .padding(1)
    }
    
    // MARK: - Kill Section View

    private var killSectionView: some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation { showKill.toggle() }
            }) {
                HStack {
                    Image(systemName: "xmark.bin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.red)
                        .frame(width: 22.0, height: 22.0)
                    Text("Kill")
                        .font(.title3)
                        .foregroundColor(Color.red)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.red)
                        .frame(width: 16.0, height: 16.0)
                        .rotationEffect(.degrees(showKill ? 90 : 0))
                }
                .padding(8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if showKill {
                // Password field
                HStack {
                    Text("Password:")
                    TextField("can't be default password", text: $killPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer()
                }
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                
                // Kill button
                HStack {
                    Spacer()
                    Button("Kill") { killTag() }
                        .outlinedStyle(color: .red)
                        .frame(width: 200, height: 35)
                    Spacer()
                }
                .padding(.vertical, 6)
            }
        }
        .frame(alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(.red, lineWidth: 1)
        )
        .padding(1)
    }
    
    // MARK: - Radio Button

    func RadioButton(_ title: String, _ isSelected: Bool, action: @escaping () -> Void) -> some View {
        return Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "smallcircle.filled.circle" : "circle")
                    .resizable(resizingMode: .stretch)
                    .foregroundColor(isSelected ? .blue : colorScheme == .dark ? .white : .black)
                    .frame(width: 20.0, height: 20.0)
                Text(title.localizedString(appState.localication))
                    .foregroundColor(isSelected ? .blue : colorScheme == .dark ? .white : .black)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Check Button

    func CheckButton(_ title: String, _ isSelected: Bool, action: @escaping () -> Void) -> some View {
        let isTid = title == "TID"
        return Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square" : "square")
                    .resizable(resizingMode: .stretch)
                    .foregroundColor(isSelected ? .blue : colorScheme == .dark ? .white : .black)
                    .frame(width: 20.0, height: 20.0)
                Text(title)
                    .foregroundColor(isSelected ? .blue : colorScheme == .dark ? .white : .black)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isTid)
    }
    
    // MARK: - Lock Function

    func lockMem() {
        var lockBank: [Int] = []
        if access { 
            lockBank.append(RFIDLockBank.Access.rawValue)
        }
        if kill { 
            lockBank.append(RFIDLockBank.Kill.rawValue)
        }
        if epc { 
            lockBank.append(RFIDLockBank.EPC.rawValue)
        }
        if tid { 
            lockBank.append(RFIDLockBank.TID.rawValue)
        }
        if user { 
            lockBank.append(RFIDLockBank.USER.rawValue)
        }
        if lockBank.isEmpty {
            toast.show("TagBank can't be empty")
            return
        }
        let res = RFIDManager.getInstance().lockMem(
            filter: filter.toRFIDFilter(), 
            lockMode: lockMode.rawValue, 
            lockBank: lockBank, 
            password: accessPassword
        )
        if res.code == .success {
            toast.show("Success")
        } else {
            toast.show(res.message ?? "Failure")
        }
    }
    
    // MARK: - Kill Function

    func killTag() {
        let res = RFIDManager.getInstance().killTag(filter: filter.toRFIDFilter(), password: killPassword)
        if res.code == .success {
            toast.show("Success")
        } else {
            toast.show(res.message ?? "Failure")
        }
    }
}

#Preview {
    LockKillView()
        .environmentObject(AppState.shared)
}
