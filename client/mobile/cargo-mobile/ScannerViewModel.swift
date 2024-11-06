import Foundation
import Vision
import CoreImage
import AVFoundation

class ScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var isScanning = false
    @Published var scannedLabels: [CargoLabel] = []
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isTorchOn = false
    @Published var lastScannedCode: String?
    
    var captureSession: AVCaptureSession?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let session = captureSession,
              let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            showError(message: "Camera not available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.beginConfiguration()
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            }
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        } catch {
            showError(message: "Failed to setup camera: \(error.localizedDescription)")
        }
    }
    
    private func parseCargoLabel(_ text: String) -> CargoLabel? {
        let components = text.split(separator: "-")
        if components.count == 3 && components[0] == "AWB" {
            return CargoLabel(
                id: String(components[1]),
                awbNumber: String(components[1]),
                destination: String(components[2]),
                timestamp: Date(),
                weight: "0.0 KG",  // Default values
                pieces: 0,
                shipper: "Cathay",
                consignee: "John",
                specialHandling: [],
                status: "Pending"
            )
        }
        return nil
    }
    
    // QR Code delegate method
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                       didOutput metadataObjects: [AVMetadataObject],
                       from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            
            // Play a sound when QR code is detected
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            lastScannedCode = stringValue
            let cargoLabel = CargoLabel.mockDataFor(qrCode: stringValue)
            
            if !scannedLabels.contains(where: { $0.id == cargoLabel.id }) {
                DispatchQueue.main.async {
                    self.scannedLabels.append(cargoLabel)
                    self.isScanning = false
                }
            }
        }
    }
    
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.hasTorch {
                if device.torchMode == .off {
                    try device.setTorchModeOn(level: 1.0)
                    isTorchOn = true
                } else {
                    device.torchMode = .off
                    isTorchOn = false
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            showError(message: "Failed to toggle torch: \(error.localizedDescription)")
        }
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
        }
    }
}
