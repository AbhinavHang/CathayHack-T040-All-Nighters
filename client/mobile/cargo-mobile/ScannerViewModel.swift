//
//  ScannerViewModel.swift
//  cargo-mobile-2
//
//  Created by Аяжан on 6/11/2024.
//

import Foundation

//
//  ScannerViewModel.swift
//  cargo-mobile
//
//  Created by Аяжан on 6/11/2024.
//

import Foundation
import Vision
import CoreImage
import AVFoundation

class ScannerViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var isScanning = false
    @Published var scannedLabels: [CargoLabel] = []
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isTorchOn = false
    
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
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInitiated))
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        } catch {
            showError(message: "Failed to setup camera: \(error.localizedDescription)")
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
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        processImage(ciImage)
    }
    
    private func processImage(_ image: CIImage) {
        let request = VNRecognizeTextRequest { [weak self] request, error in
            if let error = error {
                self?.showError(message: "Text recognition failed: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            self?.processRecognizedText(recognizedStrings)
        }
        
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            showError(message: "Failed to process image: \(error.localizedDescription)")
        }
    }
    
    private func processRecognizedText(_ strings: [String]) {
        for text in strings {
            if let label = parseCargoLabel(text) {
                DispatchQueue.main.async {
                    if !self.scannedLabels.contains(where: { $0.id == label.id }) {
                        self.scannedLabels.append(label)
                    }
                }
            }
        }
    }
    
    private func parseCargoLabel(_ text: String) -> CargoLabel? {
        let components = text.split(separator: "-")
        if components.count == 3 && components[0] == "AWB" {
            return CargoLabel(
                id: String(components[1]),
                awbNumber: String(components[1]),
                destination: String(components[2]),
                timestamp: Date()
            )
        }
        return nil
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
        }
    }
}
