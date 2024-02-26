//
//  ScannerView.swift
//  CoreDex
//
//  Created by Adrian Castro on 26.02.24.
//

import SwiftUI
import PkmnApi

struct ScannerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ScannerViewController {
        return ScannerViewController()
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
    }
}
