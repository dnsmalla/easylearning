//
//  DrawingComponents.swift
//  NPLearn
//
//  Shared drawing components for writing practice
//

import SwiftUI

// MARK: - Line Model

struct Line: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
}

// MARK: - Drawing Canvas View

struct DrawingCanvasView: View {
    @Binding var lines: [Line]
    @Binding var currentLine: Line
    
    var body: some View {
        Canvas { context, size in
            // Draw completed lines
            for line in lines {
                var path = Path()
                if let firstPoint = line.points.first {
                    path.move(to: firstPoint)
                    for point in line.points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                context.stroke(
                    path,
                    with: .color(line.color),
                    lineWidth: line.lineWidth
                )
            }
            
            // Draw current line
            var currentPath = Path()
            if let firstPoint = currentLine.points.first {
                currentPath.move(to: firstPoint)
                for point in currentLine.points.dropFirst() {
                    currentPath.addLine(to: point)
                }
            }
            context.stroke(
                currentPath,
                with: .color(currentLine.color),
                lineWidth: currentLine.lineWidth
            )
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentLine.points.append(value.location)
                }
                .onEnded { _ in
                    if !currentLine.points.isEmpty {
                        lines.append(currentLine)
                        currentLine = Line(points: [], color: .black, lineWidth: 3)
                    }
                }
        )
    }
}


