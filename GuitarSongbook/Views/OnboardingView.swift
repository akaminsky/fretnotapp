//
//  OnboardingView.swift
//  GuitarSongbook
//
//  Onboarding flow shown on first app launch
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0

    let onComplete: () -> Void

    // Placeholder image names - replace with your actual App Store screenshot names
    private let pages = [
        "onboarding-1",
        "onboarding-2",
        "onboarding-3",
        "onboarding-4",
        "onboarding-5",
        "onboarding-6",
        "onboarding-7"
    ]

    var body: some View {
        ZStack {
            // Page view
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(imageName: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Close button (X) in top-right corner
            VStack {
                HStack {
                    Spacer()

                    Button {
                        completeOnboarding()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }

                Spacer()
            }
        }
        .ignoresSafeArea()
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onComplete()
        dismiss()
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let imageName: String

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        // Try to load the image, show placeholder if not found
        if let uiImage = UIImage(named: imageName) {
            if isIPad {
                // iPad: Show image at natural size, centered on dark background
                ZStack {
                    Color.black
                        .ignoresSafeArea()

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                        .padding(40)
                }
            } else {
                // iPhone: Fill screen as before
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
        } else {
            // Placeholder for when images aren't added yet
            ZStack {
                Color.warmInputBackground

                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)

                    Text("Add '\(imageName).png'")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("to Assets.xcassets")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
}
