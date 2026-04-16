//
//  RadarBackground.swift
//  RFIDTools
//
//  Created by zsg on 2024/5/14.
//

import Foundation
import RFIDManager
import SwiftUI

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

struct RadarDrawView: View {
    let target: FilterEntity
    let angle: Double
    var radarList: [RFIDLocateInfo]

    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width, geometry.size.height)

            ZStack {
                radarGrid(width)
                radarLines(width).rotationEffect(.degrees(angle))
                radarCircles(width).rotationEffect(.degrees(angle))
                radarNumbers(width).rotationEffect(.degrees(angle))
                Image("phone")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width / 13, height: width / 6)
                radarTags(width).rotationEffect(.degrees(angle))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }

    func radarGrid(_ width: CGFloat) -> some View {
        let halfWidth = Double(width / 2.0) * -1
        let step = Double(width / 12.0)

        return ZStack {
            ForEach(0 ..< 12) { index in
                Line()
                    .stroke(.gray, style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .frame(width: width)
                    .offset(y: CGFloat(halfWidth + step * Double(index)))
            }
            ForEach(0 ..< 12) { index in
                Line()
                    .stroke(.gray, style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .frame(width: width)
                    .offset(y: CGFloat(halfWidth + step * Double(index)))
            }
            .rotationEffect(.degrees(90))
        }
        .opacity(0.8)
        .mask(Circle().frame(width: width, height: width))
    }

    func radarLines(_ width: CGFloat) -> some View {
        return ZStack {
            Line()
                .stroke(.gray, lineWidth: 1)
                .frame(width: width - 60)
                .rotationEffect(.degrees(90))

            Line()
                .stroke(.gray, lineWidth: 1)
                .frame(width: width - 60)
                .rotationEffect(.degrees(180))
        }
    }

    func radarCircles(_ width: CGFloat) -> some View {
        let radius = (width - 10) / 2
        let circumference = 2 * .pi * radius
        let gapLength5 = (circumference / CGFloat(360 / 5)) - 1
        let gapLength30 = (circumference / CGFloat(360 / 30)) - 4
        return ZStack {
            Circle()
                .fill(Color.gray)
                .frame(width: width)
                .opacity(0.5)
            Circle()
                .stroke(.gray, lineWidth: 2)
                .frame(width: width / 3)
            Circle()
                .stroke(.gray, lineWidth: 2 - 30)
                .frame(width: width / 3)
            Circle()
                .stroke(.gray, lineWidth: 2)
                .frame(width: width / 1.5)
            Circle()
                .stroke(.gray, lineWidth: 2)
                .frame(width: width)
            Circle()
                .fill(Color(hex: 0x9EB4DD))
                .frame(width: width / 3)
            // scale
            Circle()
                .stroke(.gray, style: StrokeStyle(lineWidth: 10, dash: [1, gapLength5]))
                .frame(width: width - 10)
                .rotationEffect(.degrees(-0.25))
            Circle()
                .stroke(.gray, style: StrokeStyle(lineWidth: 10, dash: [4, gapLength30]))
                .frame(width: width - 10)
                .rotationEffect(.degrees(-0.75))
        }
    }

    func radarNumbers(_ width: CGFloat) -> some View {
        let offsetY = width / 2 - 20
        return ForEach(0 ..< 12) { index in
            let theta = index * 30
            Text("\(theta)")
                .font(.headline)
                .foregroundColor(Color.gray)
                .offset(y: -offsetY)
                .rotationEffect(.degrees(Double(theta)))
        }
    }

    func radarTags(_ width: CGFloat) -> some View {
        let diameter = width / 15
        let r = width / 2

        return ZStack {
            ForEach(radarList) { radarInfo in
                let tagFillColor = target.isEqualTagInfo(radarInfo.tag) ? Color.yellow : Color.blue
                let offsetY: CGFloat = calculateOffsetY(r: r, value: radarInfo.value) // max(-r, (-r) * (1.0 - radarInfo.value / 100.0))
                let rotation = radarInfo.angle

                Circle()
                    .fill(tagFillColor)
                    .frame(width: diameter)
                    .offset(y: offsetY)
                    .rotationEffect(.degrees(rotation))
                    .opacity(0.8)
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: diameter)
                    .offset(y: offsetY)
                    .rotationEffect(.degrees(rotation))
                    .opacity(0.8)
            }
        }
    }

    private func calculateOffsetY(r: CGFloat, value: Double) -> CGFloat {
        let normalizedValue = value / 100
        let baseOffset = -r * (1 - normalizedValue)
        return max(-r, baseOffset)
    }
}

// #Preview {
//    VStack {
//        @State var radarList: [RFIDLocateInfo] = []
//
//        RadarDrawView(target: FilterEntity(false), angle: 45, radarList: radarList)
//    }
// }
