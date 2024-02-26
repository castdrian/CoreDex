//
//  ScannerView.swift
//  CoreDex
//
//  Created by Adrian Castro on 26.02.24.
//

import SwiftUI
import PkmnApi

struct ScannerView: UIViewControllerRepresentable {
    var onImageCaptured: ((UIImage) -> Void)

    func makeUIViewController(context: Context) -> ScannerViewController {
        let scannerVC = ScannerViewController()
        scannerVC.onImageCaptured = onImageCaptured
        return scannerVC
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}
