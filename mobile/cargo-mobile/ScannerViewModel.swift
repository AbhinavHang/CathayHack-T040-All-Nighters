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
    
    func mockDataFor(qrCode: String) -> CargoLabel {
            let mockData: [String: CargoLabel] = [
                "AWB123": CargoLabel(
                    id: "AWB123",
                    awbNumber: "160-12345678",
                    origin: "HKG",
                    destination: "LAX",
                    timestamp: Date(),
                    weight: "245.5 KG",
                    pieces: 3,
                    shipper: "ABC Electronics Ltd",
                    consignee: "XYZ Trading Co",
                    specialHandling: ["PER", "VUN"],
                    status: "Awaiting",
                    description: "Electronic Components",
                    deadline: Date().addingTimeInterval(3600) // 1 hour from now
                ),
                "AWB456": CargoLabel(
                    id: "AWB456",
                    awbNumber: "160-87654321",
                    origin: "PVG",
                    destination: "SIN",
                    timestamp: Date(),
                    weight: "1,240 KG",
                    pieces: 8,
                    shipper: "Global Tech Manufacturing",
                    consignee: "Singapore Electronics",
                    specialHandling: ["DGR", "CAO"],
                    status: "In Transit",
                    description: "Industrial Equipment",
                    deadline: Date().addingTimeInterval(7200) // 2 hours from now
                )
            ]
            
            return mockData[qrCode] ?? CargoLabel(
                id: qrCode,
                awbNumber: "Unknown",
                origin: "Unknown",
                destination: "Unknown",
                timestamp: Date(),
                weight: "N/A",
                pieces: 0,
                shipper: "Unknown",
                consignee: "Unknown",
                specialHandling: [],
                status: "Not Found",
                description: "Unknown",
                deadline: nil
            )
        }
    
    private func parseCargoLabel(_ text: String) -> CargoLabel? {
        let components = text.split(separator: "-")
        if components.count == 3 && components[0] == "AWB" {
            return CargoLabel(
                id: String(components[1]),
                awbNumber: String(components[1]),
                origin: "Hong Kong",
                destination: String(components[2]),
                timestamp: Date(),
                weight: "0.0 KG",  // Default values
                pieces: 0,
                shipper: "Cathay",
                consignee: "John",
                specialHandling: [],
                status: "Pending",
                description: "Luggage",
                deadline: Date().addingTimeInterval(3600) // 1 hour from now
            )
        }
        return nil
    }
    
    // QR Code delegate method
//    func metadataOutput(_ output: AVCaptureMetadataOutput,
//                           didOutput metadataObjects: [AVMetadataObject],
//                           from connection: AVCaptureConnection) {
//            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
//               let stringValue = metadataObject.stringValue {
//                
//                // Play a sound when QR code is detected
//                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//                
//                lastScannedCode = stringValue
//                let cargoLabel = mockDataFor(qrCode: stringValue)
//                
//                if !scannedLabels.contains(where: { $0.id == cargoLabel.id }) {
//                    DispatchQueue.main.async {
//                        self.scannedLabels.append(cargoLabel)
//                        self.isScanning = false
//                    }
//                }
//            }
//        }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                           didOutput metadataObjects: [AVMetadataObject],
                           from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let stringValue = metadataObject.stringValue {
                
                // Play a sound when QR code is detected
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                DispatchQueue.main.async {
                    self.lastScannedCode = stringValue
                    self.isScanning = false
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
