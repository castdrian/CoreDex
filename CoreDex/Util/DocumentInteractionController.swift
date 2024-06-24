//
//  DocumentInteractionController.swift
//  CoreDex
//
//  Created by Adrian Castro on 22.06.24.
//

import SwiftUI
import UIKit

struct DocumentInteractionController: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            let documentInteractionController = UIDocumentInteractionController(url: url)
            documentInteractionController.delegate = context.coordinator
            documentInteractionController.presentPreview(animated: true)
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let documentInteractionController = UIDocumentInteractionController(url: url)
        documentInteractionController.delegate = context.coordinator
        documentInteractionController.presentPreview(animated: true)

        if let rootVC = uiViewController.presentingViewController {
            documentInteractionController.presentOptionsMenu(from: rootVC.view.bounds, in: rootVC.view, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentInteractionControllerDelegate {
        var parent: DocumentInteractionController

        init(_ parent: DocumentInteractionController) {
            self.parent = parent
        }

        func documentInteractionControllerViewControllerForPreview(_: UIDocumentInteractionController) -> UIViewController {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = scene.windows.first?.rootViewController
            else {
                fatalError("Unable to find the root view controller")
            }
            return rootViewController
        }

        func documentInteractionControllerDidEndPreview(_: UIDocumentInteractionController) {
            do {
                try FileManager.default.removeItem(at: parent.url)
            } catch {
                print("Error removing temporary file: \(error)")
            }
        }
    }
}
