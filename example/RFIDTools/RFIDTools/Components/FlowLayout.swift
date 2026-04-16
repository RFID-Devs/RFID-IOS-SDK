//
//  FlowLayout.swift
//  RFIDTools
//

import SwiftUI

// MARK: - FlowLayout

struct FlowLayout: View {
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8
    var items: [AnyView]
    
    @State private var totalHeight: CGFloat = .zero
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        return ZStack(alignment: .topLeading) {
            ForEach(0..<items.count, id: \.self) { index in
                items[index]
                    .padding(.trailing, horizontalSpacing)
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= (lineHeight + verticalSpacing)
                            lineHeight = 0
                        }
                        let result = width
                        if index == items.count - 1 {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { dimension in
                        let result = height
                        if index == items.count - 1 {
                            height = 0
                        }
                        lineHeight = max(lineHeight, dimension.height)
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = geometry.size.height
            }
            return Color.clear
        }
    }
}
