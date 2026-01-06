//
//  CategoryPill.swift
//  GuitarSongbook
//
//  A pill-shaped category button with count badge
//

import SwiftUI

/// A pill-shaped category button with count badge
///
/// Usage:
/// ```swift
/// CategoryPill(
///     title: "Rock",
///     count: 42,
///     isSelected: selectedCategory == "Rock",
///     color: .appAccent
/// ) {
///     selectedCategory = "Rock"
/// }
/// ```
struct CategoryPill: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let color: Color
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white : color)
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(CornerRadius.categoryPill)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.categoryPill)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        CategoryPill(
            title: "All",
            count: 42,
            isSelected: true,
            color: .appAccent
        ) {}

        CategoryPill(
            title: "Favorites",
            count: 12,
            isSelected: false,
            color: .appAccent,
            icon: "star.fill"
        ) {}
    }
    .padding()
    .warmBackground()
}
