//
//  RoundedTopBackground.swift
//  FestiGo
//
//  Created by kisellsn on 14/05/2025.
//

import SwiftUI

struct RoundedTopBackground: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let curveHeight: CGFloat = 40

        path.move(to: CGPoint(x: 0, y: curveHeight))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: curveHeight),
                          control: CGPoint(x: rect.width / 2, y: -curveHeight))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}
