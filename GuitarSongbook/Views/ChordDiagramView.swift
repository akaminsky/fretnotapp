//
//  ChordDiagramView.swift
//  GuitarSongbook
//
//  SVG-style chord diagram view
//

import SwiftUI

struct ChordDiagramView: View {
    let chordName: String
    
    private let strings = ["E", "A", "D", "G", "B", "e"]
    private let chordLibrary = ChordLibrary.shared
    
    var body: some View {
        VStack(spacing: 6) {
            Text(chordName)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
            
            if let chordData = chordLibrary.findChord(chordName) {
                Text(chordData.name)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                ChordDiagramCanvas(chordData: chordData, strings: strings)
                    .frame(width: 90, height: 110)
            } else {
                Text("Diagram not available")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 90, height: 110)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
    }
}

// MARK: - Chord Diagram Canvas

struct ChordDiagramCanvas: View {
    let chordData: ChordData
    let strings: [String]
    
    private let stringSpacing: CGFloat = 14
    private let fretSpacing: CGFloat = 18
    private let startX: CGFloat = 15
    private let startY: CGFloat = 20
    
    var body: some View {
        Canvas { context, size in
            // Draw strings (vertical lines)
            for i in 0..<6 {
                let x = startX + CGFloat(i) * stringSpacing
                var path = Path()
                path.move(to: CGPoint(x: x, y: startY))
                path.addLine(to: CGPoint(x: x, y: startY + 5 * fretSpacing))
                context.stroke(path, with: .color(.primary), lineWidth: 1)
            }
            
            // Draw frets (horizontal lines) - 6 frets now
            for i in 0..<6 {
                let y = startY + CGFloat(i) * fretSpacing
                var path = Path()
                path.move(to: CGPoint(x: startX, y: y))
                path.addLine(to: CGPoint(x: startX + 5 * stringSpacing, y: y))
                context.stroke(path, with: .color(.primary), lineWidth: i == 0 ? 3 : 1)
            }
            
            // Draw barre if present
            if let barre = chordData.barre {
                let y = startY + (CGFloat(barre) - 0.5) * fretSpacing + fretSpacing/2
                let rect = CGRect(x: startX - 3, y: y - 2, width: 5 * stringSpacing + 6, height: 4)
                context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(.primary))
            }
            
            // Draw finger positions
            for (stringIndex, fret) in chordData.fingers.enumerated() {
                let x = startX + CGFloat(stringIndex) * stringSpacing
                
                if fret == -1 {
                    // X - don't play
                    let text = Text("×")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    context.draw(text, at: CGPoint(x: x, y: 10))
                } else if fret == 0 {
                    // O - open string
                    var circle = Path()
                    circle.addArc(center: CGPoint(x: x, y: 10), radius: 4, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
                    context.stroke(circle, with: .color(.green), lineWidth: 2)
                } else {
                    // Finger position
                    let y = startY + (CGFloat(fret) - 0.5) * fretSpacing + fretSpacing/2
                    var circle = Path()
                    circle.addArc(center: CGPoint(x: x, y: y), radius: 5, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
                    context.fill(circle, with: .color(.primary))
                }
            }
        }
    }
}

// MARK: - Chord Diagrams Grid

struct ChordDiagramsGrid: View {
    let chords: [String]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 100), spacing: 12)
        ], spacing: 12) {
            ForEach(chords, id: \.self) { chord in
                ChordDiagramView(chordName: chord)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ChordDiagramView(chordName: "Am")
        ChordDiagramView(chordName: "C")
        ChordDiagramView(chordName: "G")
        ChordDiagramView(chordName: "F")
    }
    .padding()
    .background(Color(.systemGray6))
}
