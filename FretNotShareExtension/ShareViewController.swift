//
//  ShareViewController.swift
//  FretNotShareExtension
//
//  Share Extension for importing chord charts from any app
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    private let sharedDefaults = UserDefaults(suiteName: "group.com.akaminsky.fretnot")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Extract shared text
        extractSharedText { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let text):
                self.handleSharedText(text)
            case .failure(let error):
                self.showError(error)
            }
        }
    }

    // MARK: - Text Extraction

    private func extractSharedText(completion: @escaping (Result<String, Error>) -> Void) {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            completion(.failure(ShareError.noContent))
            return
        }

        // Try multiple text type identifiers
        let textTypes = [
            UTType.plainText.identifier,
            UTType.utf8PlainText.identifier,
            "public.text",
            "public.plain-text"
        ]

        // Find first supported type
        var supportedType: String?
        for typeIdentifier in textTypes {
            if itemProvider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                supportedType = typeIdentifier
                break
            }
        }

        guard let typeToLoad = supportedType else {
            completion(.failure(ShareError.unsupportedType))
            return
        }

        // Load the item
        itemProvider.loadItem(forTypeIdentifier: typeToLoad, options: nil) { item, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            DispatchQueue.main.async {
                // Try different ways to extract text
                if let text = item as? String {
                    completion(.success(text))
                } else if let data = item as? Data, let text = String(data: data, encoding: .utf8) {
                    completion(.success(text))
                } else if let url = item as? URL {
                    // Some apps share text as a file URL
                    if let text = try? String(contentsOf: url, encoding: .utf8) {
                        completion(.success(text))
                    } else {
                        completion(.failure(ShareError.invalidFormat))
                    }
                } else {
                    completion(.failure(ShareError.invalidFormat))
                }
            }
        }
    }

    // MARK: - Text Handling

    private func handleSharedText(_ text: String) {
        // Parse the chord chart
        let parsed = ChordChartParser.parse(text)

        // Save to shared UserDefaults
        sharedDefaults?.set(parsed.capoPosition, forKey: "sharedCapo")
        sharedDefaults?.set(parsed.chords, forKey: "sharedChords")
        sharedDefaults?.set(parsed.fullText, forKey: "sharedNotes")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "sharedTimestamp")
        sharedDefaults?.synchronize()

        // Show confirmation UI
        showConfirmation(parsed: parsed)
    }

    // MARK: - UI

    private func showConfirmation(parsed: ParsedChordChart) {
        let hostingController = UIHostingController(
            rootView: ShareConfirmationView(
                capo: parsed.capoPosition,
                chords: parsed.chords,
                onConfirm: { [weak self] in
                    self?.openMainApp()
                },
                onCancel: { [weak self] in
                    self?.cancelShare()
                }
            )
        )

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to import chord chart: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.cancelShare()
        })
        present(alert, animated: true)
    }

    // MARK: - Actions

    private func openMainApp() {
        // Open main app with custom URL scheme
        guard let url = URL(string: "fretnot://share-extension") else {
            cancelShare()
            return
        }

        // Walk up the responder chain to find UIApplication
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                if #available(iOS 18.0, *) {
                    application.open(url, options: [:]) { _ in
                        // Dismiss after opening
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                        }
                    }
                } else {
                    _ = application.perform(#selector(UIApplication.open(_:options:completionHandler:)), with: url)

                    // Dismiss after opening
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                    }
                }
                return
            }
            responder = responder?.next
        }

        // Fall back to extensionContext.open as last resort
        self.extensionContext?.open(url, completionHandler: { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
        })
    }

    private func cancelShare() {
        extensionContext?.cancelRequest(withError: ShareError.userCancelled)
    }
}

// MARK: - Error Types

enum ShareError: LocalizedError {
    case noContent
    case invalidFormat
    case unsupportedType
    case userCancelled

    var errorDescription: String? {
        switch self {
        case .noContent: return "No content to share"
        case .invalidFormat: return "Invalid text format"
        case .unsupportedType: return "Unsupported content type"
        case .userCancelled: return "User cancelled"
        }
    }
}
