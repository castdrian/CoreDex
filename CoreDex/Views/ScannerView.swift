//
//  ScannerView.swift
//  CoreDex
//
//  Created by Adrian Castro on 26.02.24.
//

import PkmnApi
import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage) -> Void

    func makeUIViewController(context _: Context) -> ScannerViewController {
        let scannerVC = ScannerViewController()
        scannerVC.onImageCaptured = onImageCaptured
        return scannerVC
    }

    func updateUIViewController(_: ScannerViewController, context _: Context) {}
}
