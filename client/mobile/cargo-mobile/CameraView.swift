//
//  CameraView.swift
//  cargo-mobile-2
//
//  Created by Аяжан on 6/11/2024.
//

import Foundation
// CameraView.swift
import SwiftUI
import AVFoundation
import Foundation
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ScannerViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Setup preview layer
        if let captureSession = viewModel.captureSession {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = UIScreen.main.bounds
            previewLayer.videoGravity = .resizeAspectFill
            viewController.view.layer.addSublayer(previewLayer)
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Handle updates if needed
    }
    
    // Add Coordinator if needed
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
    }
}
