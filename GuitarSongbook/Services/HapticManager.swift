//
//  HapticManager.swift
//  GuitarSongbook
//
//  Centralized haptic feedback management
//

import UIKit

class HapticManager {
    static let shared = HapticManager()

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        // Prepare generators for reduced latency
        lightGenerator.prepare()
        mediumGenerator.prepare()
        selectionGenerator.prepare()
    }

    // Light impact - for subtle interactions
    func light() {
        lightGenerator.impactOccurred()
        lightGenerator.prepare()
    }

    // Medium impact - for standard interactions
    func medium() {
        mediumGenerator.impactOccurred()
        mediumGenerator.prepare()
    }

    // Heavy impact - for significant actions
    func heavy() {
        heavyGenerator.impactOccurred()
        heavyGenerator.prepare()
    }

    // Success notification - for completed actions
    func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    // Error notification - for failed actions
    func error() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }

    // Selection - for picker/selection changes
    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
}
