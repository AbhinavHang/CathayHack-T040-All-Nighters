//
//  ContentView.swift
//  cargo-mobile
//
//  Created by Аяжан on 6/11/2024.
//

import SwiftUI
struct ContentView: View {
    @StateObject private var scannerViewModel = ScannerViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if scannerViewModel.isScanning {
                    CameraView(viewModel: scannerViewModel)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    ScannedLabelsListView(labels: scannerViewModel.scannedLabels)
                }
                
                controlButtons
            }
            .navigationTitle("Cargo Scanner")
            .alert("Scanning Error", isPresented: $scannerViewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(scannerViewModel.errorMessage)
            }
        }
    }
    
    private var controlButtons: some View {
        HStack {
            Button(action: {
                scannerViewModel.isScanning.toggle()
            }) {
                Image(systemName: scannerViewModel.isScanning ? "stop.circle.fill" : "camera.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(scannerViewModel.isScanning ? .red : .blue)
            }
            
            if scannerViewModel.isScanning {
                Button(action: {
                    scannerViewModel.toggleTorch()
                }) {
                    Image(systemName: scannerViewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
