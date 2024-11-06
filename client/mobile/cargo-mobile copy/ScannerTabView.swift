//
//  ScannerTabView.swift
//  cargo-mobile
//
//  Created by Аяжан on 6/11/2024.
//

import Foundation
import Foundation
import SwiftUI
import AVFoundation
import Foundation
import UIKit

struct ScannerTabView: View {
    @ObservedObject var viewModel: ScannerViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isScanning {
                    CameraView(viewModel: viewModel)
                } else {
                    ScannedLabelsListView(labels: viewModel.scannedLabels)
                }
                
                controlButtons
            }
            .navigationTitle("Cargo Scanner")
            .alert("Scanning Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    private var controlButtons: some View {
        HStack {
            Button(action: {
                viewModel.isScanning.toggle()
            }) {
                Image(systemName: viewModel.isScanning ? "stop.circle.fill" : "camera.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(viewModel.isScanning ? .red : .blue)
            }
            
            if viewModel.isScanning {
                Button(action: {
                    viewModel.toggleTorch()
                }) {
                    Image(systemName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
    }
}
