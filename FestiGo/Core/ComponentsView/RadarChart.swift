//
//  RadarChart.swift
//  FestiGo
//
//  Created by kisellsn on 06/06/2025.
//

import SwiftUI


struct RadarChartView: View {
    let data: [Double]
    let labels: [String]
    
    @State private var animatedData: [Double] = []

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 * 0.8
            let angles = data.indices.map { Double($0) * 2 * .pi / Double(data.count) }

            ZStack {
                gridPath(angles: angles, center: center, radius: radius)
                axisLabels(angles: angles, center: center, radius: radius)
                filledPolygon(angles: angles, center: center, radius: radius)
                polygonStroke(angles: angles, center: center, radius: radius)
            }
            .onAppear {
                animatedData = Array(repeating: 0.0, count: data.count)
                withAnimation(.easeOut(duration: 1.0)) {
                    animatedData = data
                }
            }
        }
    }

    // MARK: - Grid
    @ViewBuilder
    private func gridPath(angles: [Double], center: CGPoint, radius: CGFloat) -> some View {
        ForEach(1...5, id: \.self) { step in
            let fraction = Double(step) / 5.0
            Path { path in
                for (index, angle) in angles.enumerated() {
                    let point = CGPoint(
                        x: center.x + cos(angle) * radius * fraction,
                        y: center.y + sin(angle) * radius * fraction
                    )
                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.closeSubpath()
            }
            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
    }

    // MARK: - Labels
    @ViewBuilder
    private func axisLabels(angles: [Double], center: CGPoint, radius: CGFloat) -> some View {
        ForEach(labels.indices, id: \.self) { index in
            let angle = angles[index]
            let labelPoint = CGPoint(
                x: center.x + cos(angle) * radius * 1.15,
                y: center.y + sin(angle) * radius * 1.15
            )
            Text(labels[index])
                .font(.body)
                .foregroundColor(.primary)
                .frame(width: 60)
                .position(labelPoint)
        }
    }

    // MARK: - Filled Polygon
    private func filledPolygon(angles: [Double], center: CGPoint, radius: CGFloat) -> some View {
        Path { path in
            for (index, value) in animatedData.enumerated() {
                let angle = angles[index]
                let point = CGPoint(
                    x: center.x + cos(angle) * radius * value,
                    y: center.y + sin(angle) * radius * value
                )
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
        }
        .fill(Color.purple.opacity(0.4))
    }

    // MARK: - Stroke Outline
    private func polygonStroke(angles: [Double], center: CGPoint, radius: CGFloat) -> some View {
        Path { path in
            for (index, value) in animatedData.enumerated() {
                let angle = angles[index]
                let point = CGPoint(
                    x: center.x + cos(angle) * radius * value,
                    y: center.y + sin(angle) * radius * value
                )
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
        }
        .stroke(Color.purple, lineWidth: 2)
    }
}
