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


struct CameraView: View {
    @ObservedObject var viewModel: ScannerViewModel
    @State private var showingDetail = false
    @State private var scannedCargo: CargoLabel?
    
    var body: some View {
        ZStack {
            CameraPreviewView(session: viewModel.captureSession)
                .edgesIgnoringSafeArea(.all)
            
            // QR Code scanning frame
            Rectangle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 250, height: 250)
                .background(Color.black.opacity(0.3))
                .overlay(
                    Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white.opacity(0.8))
                )
            
            VStack {
                Spacer()
                Text("Align QR Code within frame")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
            }
        }
        .onChange(of: viewModel.lastScannedCode) { newValue in
            if let code = newValue {
                Task {
                    await fetchCargoDetails(for: code)
                }
            }
        }
        .sheet(item: $scannedCargo) { cargo in
            NavigationView {
                CargoDetailView(cargo: cargo)
                    .navigationBarItems(trailing: Button("Done") {
                        scannedCargo = nil
                        viewModel.isScanning = true
                    })
            }
        }
    }
    
    private func fetchCargoDetails(for qrCode: String) async {
        do {
            // Extract AWB number from QR code if needed
            let awbNumber = qrCode // Modify this if your QR code format is different
            
            let cargo = try await APIService.shared.fetchCargoByAWB(awbNumber)
            await MainActor.run {
                self.scannedCargo = cargo
                viewModel.isScanning = false
            }
        } catch {
            print("Error fetching cargo details: \(error)")
            // Handle error appropriately
        }
    }
}
