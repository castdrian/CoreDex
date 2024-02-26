//
//  ScannerViewController.swift
//  CoreDex
//
//  Created by Adrian Castro on 26.02.24.
//

import Foundation
import AVFoundation
import CoreMotion
import UIKit
import PkmnApi

class ScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isProcessing = false
    var motionManager = CMMotionManager()
    var lastMotionData: CMDeviceMotion?
    var currentSampleBuffer: CMSampleBuffer?
    var onImageCaptured: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        startMotionUpdates()
    }
    
    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.2
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard error == nil else {
                    print("Error in motion updates: \(error!)")
                    return
                }
                
                if let motion = motion {
                    self?.processDeviceMotion(motion)
                }
            }
        }
    }
    
    func processDeviceMotion(_ motion: CMDeviceMotion) {
        let rotationThreshold = 0.05
        let accelerationThreshold = 0.05
        
        let rotationRate = motion.rotationRate
        let userAcceleration = motion.userAcceleration
        
        if abs(rotationRate.x) < rotationThreshold && abs(rotationRate.y) < rotationThreshold && abs(rotationRate.z) < rotationThreshold && abs(userAcceleration.x) < accelerationThreshold && abs(userAcceleration.y) < accelerationThreshold && abs(userAcceleration.z) < accelerationThreshold {
            if !isProcessing, let sampleBuffer = currentSampleBuffer {
                isProcessing = true
                captureFrame(sampleBuffer: sampleBuffer)
            }
        } else {
            isProcessing = false
        }
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if (captureSession.canAddOutput(videoOutput)) {
            captureSession.addOutput(videoOutput)
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        currentSampleBuffer = sampleBuffer
    }
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func captureFrame(sampleBuffer: CMSampleBuffer) {
        guard let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else {
            isProcessing = false
            return
        }
        
        onImageCaptured?(image)
        isProcessing = false
    }
}
