import SwiftUI

// MARK: - Data Models

struct TabItem<ID: Hashable>: Identifiable, Equatable {
    var id: ID
    var title: String
}

// MARK: - Tabs 

struct Tabs<ID: Hashable>: View {
    @EnvironmentObject private var appState: AppState
    
    let tabs: [TabItem<ID>]
    @Binding var selection: ID
    let size: CGSize
    let orientation: Orientation
    let onConfig: (() -> Void)?
    
    @Namespace private var animationNamespace

    var body: some View {
        if orientation == .portrait {
            portraitLayout
        } else {
            landscapeLayout
        }
    }
    
    // MARK: - Tabs Layouts
    
    private var portraitLayout: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                scrollContent(axis: .horizontal, minFrame: (size.width, nil)) {
                    HStack {
                        Divider().frame(height: 30)
                        ForEach(tabs) { tab in
                            portraitTabButton(for: tab)
                            Divider().frame(height: 30)
                        }
                    }
                }
                
                if onConfig != nil {
                    configButton()
                        .scaleEffect(x: 0.9, y: 1.3)
                        .padding(.trailing, 4)
                }
            }
            Divider()
        }
    }
    
    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            Divider()
            VStack(spacing: 0) {
                scrollContent(axis: .vertical, minFrame: (nil, size.height)) {
                    VStack {
                        Divider().frame(width: 90)
                        ForEach(tabs) { tab in
                            landscapeTabButton(for: tab)
                            Divider().frame(width: 90)
                        }
                    }
                }
                
                if onConfig != nil {
                    configButton()
                        .scaleEffect(x: 1.3, y: 0.9)
                        .padding(.bottom, 4)
                }
            }
            Divider()
        }
        .padding(.leading, 5)
    }
    
    private func portraitTabButton(for tab: TabItem<ID>) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation { selection = tab.id }
            } label: {
                Text(tab.title.localizedString(appState.localication))
                    .font(.headline)
                    .foregroundColor(selection == tab.id ? .blue : .gray)
                    .fixedSize(horizontal: true, vertical: false)
                    .contentShape(Rectangle())
                    .frame(minWidth: 60)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            
            underline(for: tab)
                .frame(height: 2)
        }
    }
    
    private func landscapeTabButton(for tab: TabItem<ID>) -> some View {
        HStack(spacing: 0) {
            underline(for: tab)
                .frame(width: 3)
            
            Button {
                withAnimation { selection = tab.id }
            } label: {
                Text(tab.title.localizedString(appState.localication))
                    .font(.title2)
                    .foregroundColor(selection == tab.id ? .blue : .gray)
                    .frame(minWidth: 120, minHeight: 50)
                    .contentShape(Rectangle())
                    .padding(.horizontal, 2)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Tabs Shared Components
    
    private func scrollContent<Content: View>(
        axis: Axis.Set,
        minFrame: (width: CGFloat?, height: CGFloat?),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ScrollViewReader { proxy in
            ScrollView(axis, showsIndicators: false) {
                content()
                    .frame(
                        minWidth: minFrame.width,
//                      minHeight: minFrame.height
                    )
            }
            .onChange(of: selection) { newValue in
                withAnimation { proxy.scrollTo(newValue, anchor: .center) }
            }
            .onChange(of: tabs) { _ in
                DispatchQueue.main.async {
                    withAnimation { proxy.scrollTo(selection, anchor: .center) }
                }
            }
        }
    }

    private func underline(for tab: TabItem<ID>) -> some View {
        Rectangle()
            .fill(selection == tab.id ? Color.blue : Color.clear)
            .cornerRadius(2)
            .animation(.easeInOut, value: selection)
            .matchedGeometryEffect(
                id: "underline",
                in: animationNamespace,
                isSource: selection == tab.id
            )
            .allowsHitTesting(false)
    }
    
    private func configButton() -> some View {
        Button(action: onConfig!) {
            Image(systemName: "line.3.horizontal")
                .font(.title)
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - TabViews

struct TabViews<ID: Hashable, Content: View>: View {
    let tabs: [TabItem<ID>]
    @Binding var selection: ID
    let content: (ID) -> Content
    var size: CGSize
    let orientation: Orientation
    
    var body: some View {
        ZStack {
            ForEach(tabs) { tab in
                content(tab.id)
                    .offset(
                        x: orientation == .portrait ? positionOffset(for: tab.id, multiplier: size.width) : 0, 
                        y: orientation == .landscape ? positionOffset(for: tab.id, multiplier: size.height) : 0
                    )
                    .zIndex(selection == tab.id ? 1 : -1)
                    // .hidden(selection != tab.id)
                    .opacity(selection == tab.id ? 1 : 0)
                // .allowsHitTesting(selection == tab.id)
            }
        }
        .frame(
            width: orientation == .portrait ? size.width : nil, 
            height: orientation == .landscape ? size.height : nil
        )
        .clipped()
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selection)
        .animation(.spring(), value: tabs)
    }
    
    private func positionOffset(for id: ID, multiplier: CGFloat) -> CGFloat {
        guard let currentIndex = tabs.firstIndex(where: { $0.id == id }),
              let selectedIndex = tabs.firstIndex(where: { $0.id == selection })
        else {
            return 0
        }

        return CGFloat(currentIndex - selectedIndex) * multiplier
    }
}

// MARK: - Main TabLayout

struct TabLayout<ID: Hashable, Content: View>: View {
    let tabs: [TabItem<ID>]
    @Binding var selection: ID
    let orientation: Orientation
    let onConfig: (() -> Void)?
    let content: (ID) -> Content
    
    init(
        tabs: [TabItem<ID>],
        selection: Binding<ID>,
        orientation: Orientation = .portrait,
        onConfig: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (ID) -> Content
    ) {
        self.tabs = tabs
        _selection = selection
        self.orientation = orientation
        self.content = content
        self.onConfig = onConfig
    }
    
    var body: some View {
        GeometryReader { geometry in
            if #available(iOS 16.0, macOS 13.0, *) {
                let layout = orientation == .portrait ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout()) 
                layout {
                    tabsView(size: geometry.size)
                    contentView(size: geometry.size)
                }
                .animation(.default, value: orientation)
            } else {
                if orientation == .portrait {
                    VStack(spacing: 0) {
                        tabsView(size: geometry.size)
                        contentView(size: geometry.size)
                    }
                } else {
                    HStack(spacing: 0) {
                        tabsView(size: geometry.size)
                        contentView(size: geometry.size)
                    }
                }
            }
        }
        .onChange(of: tabs) { newTabs in
            if !newTabs.contains(where: { $0.id == selection }), let firstTab = newTabs.first {
                selection = firstTab.id
            }
        }
    }
    
    private func tabsView(size: CGSize) -> some View {
        Tabs(
            tabs: tabs,
            selection: $selection,
            size: size,
            orientation: orientation,
            onConfig: onConfig
        )
    }
    
    private func contentView(size: CGSize) -> some View {
        TabViews(
            tabs: tabs,
            selection: $selection,
            content: content,
            size: size,
            orientation: orientation
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .edgesIgnoringSafeArea(.all) 

//        TabView(selection: $selection) {
//            ForEach(tabs) { _ in 
//                InventoryView().tag(AppPage.Inventory)
//                BarcodeView().tag(AppPage.Barcode)
//                SettingsUhfView().tag(AppPage.SettingsUHF)
//                ReadWriteView().tag(AppPage.ReadWrite)
//                RadarView().tag(AppPage.Radar)
//                LocationView().tag(AppPage.Location)
//                LockView().tag(AppPage.Lock)
//                KillView().tag(AppPage.Kill)
//                UpgradeView().tag(AppPage.Upgrade)
//            }
//        }
//        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
