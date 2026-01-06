//
//  ShareConfirmationView.swift
//  FretNotShareExtension
//
//  Confirmation UI showing parsed chord chart preview
//

import SwiftUI

// Warm color palette for consistency with main app
extension Color {
    static let warmInputBackground = Color(red: 0.995, green: 0.99, blue: 0.985)
}

struct ShareConfirmationView: View {
    let capo: Int
    let chords: [String]
    let onConfirm: () -> Void
    let onCancel: () -> Void

    private var capoText: String {
        if capo == 0 {
            return "Not detected"
        }
        let suffix: String
        switch capo {
        case 1: suffix = "st"
        case 2: suffix = "nd"
        case 3: suffix = "rd"
        default: suffix = "th"
        }
        return "\(capo)\(suffix) fret"
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)

                Text("Import to Fret Not")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.top, 32)

            // Preview
            VStack(alignment: .leading, spacing: 16) {
                // Capo section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Capo:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(capoText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(capo > 0 ? .primary : .secondary)
                }

                if !chords.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(chords.count) chord\(chords.count == 1 ? "" : "s") detected:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        FlowLayout(spacing: 8) {
                            ForEach(chords, id: \.self) { chord in
                                Text(chord)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundColor(.orange)
                                    .cornerRadius(8)
                            }
                        }
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                        Text("No chords detected - you can add them manually")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.warmInputBackground)
            .cornerRadius(12)

            Spacer()

            // Actions
            VStack(spacing: 12) {
                Button(action: onConfirm) {
                    Text("Open in Fret Not")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }

                Button(action: onCancel) {
                    Text("Cancel")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: ProposedViewSize(result.frames[index].size))
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    // Start new line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview("With Capo") {
    ShareConfirmationView(
        capo: 2,
        chords: ["Am", "E7", "G", "D", "F", "C", "Dm"],
        onConfirm: {},
        onCancel: {}
    )
}

#Preview("No Capo") {
    ShareConfirmationView(
        capo: 0,
        chords: ["Am", "E7", "G", "D"],
        onConfirm: {},
        onCancel: {}
    )
}
