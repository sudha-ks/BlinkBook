//
//  CameraService.swift
//  BlinkBook
//
//  Created by Sudha on 10/09/25.
//

import Foundation
import AVFoundation
import UIKit
import Combine

/// Protocol for camera service to enable dependency injection and testing
protocol CameraServiceProtocol {
    func requestPermission() -> AnyPublisher<Bool, CameraError>
    func checkPermissionStatus() -> CameraPermissionStatus
    func startSession() -> AnyPublisher<AVCaptureSession, CameraError>
    func stopSession()
    func capturePhoto() -> AnyPublisher<UIImage, CameraError>
}

/// Service responsible for camera management and photo capture
class CameraService: NSObject, CameraServiceProtocol {
    
    // MARK: - Properties
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.blinkbook.camera.session")
    private let photoQueue = DispatchQueue(label: "com.blinkbook.camera.photo")
    
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var photoCaptureCompletion: ((Result<UIImage, CameraError>) -> Void)?
    
    // MARK: - Public Methods
    
    /// Requests permission to access the camera
    /// - Returns: A publisher that emits true if permission is granted, false otherwise
    func requestPermission() -> AnyPublisher<Bool, CameraError> {
        return Future<Bool, CameraError> { promise in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                promise(.success(granted))
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Checks the current permission status for camera access
    /// - Returns: The current permission status
    func checkPermissionStatus() -> CameraPermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return .authorized
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    
    /// Starts the camera session
    /// - Returns: A publisher that emits the capture session when ready
    func startSession() -> AnyPublisher<AVCaptureSession, CameraError> {
        return Future<AVCaptureSession, CameraError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.deviceNotFound))
                return
            }
            
            self.sessionQueue.async {
                print("🎥 Setting up camera session...")
                self.setupCaptureSession { result in
                    switch result {
                    case .success:
                        print("🎥 Camera session setup successful, starting...")
                        self.captureSession.startRunning()
                        DispatchQueue.main.async {
                            print("🎥 Camera session started, isRunning: \(self.captureSession.isRunning)")
                            promise(.success(self.captureSession))
                        }
                    case .failure(let error):
                        print("❌ Camera session setup failed: \(error)")
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Stops the camera session
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    /// Captures a photo from the current camera session
    /// - Returns: A publisher that emits the captured image
    func capturePhoto() -> AnyPublisher<UIImage, CameraError> {
        return Future<UIImage, CameraError> { [weak self] promise in
            guard let self = self else {
                print("❌ CameraService: self is nil")
                promise(.failure(.captureFailed))
                return
            }
            
            print("📷 CameraService: capturePhoto called")
            
            self.photoQueue.async {
                print("📷 CameraService: On photo queue")
                
                // Check if photoOutput is connected to session
                if !self.captureSession.outputs.contains(self.photoOutput) {
                    print("❌ CameraService: photoOutput not connected to session")
                    promise(.failure(.cannotAddOutput))
                    return
                }
                
                // Check if photoOutput is ready for capture
                if !self.photoOutput.isStillImageStabilizationSupported {
                    print("⚠️ CameraService: Image stabilization not supported")
                }
                
                self.photoCaptureCompletion = { result in
                    print("📷 CameraService: Photo capture completion callback")
                    promise(result)
                }
                
                let settings = AVCapturePhotoSettings()
                settings.flashMode = .auto
                settings.isHighResolutionPhotoEnabled = true
                
                print("📷 CameraService: Calling capturePhoto with settings")
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    /// Sets up the capture session with camera and photo output
    private func setupCaptureSession(completion: @escaping (Result<Void, CameraError>) -> Void) {
        // Check if session is already configured
        if !captureSession.inputs.isEmpty && !captureSession.outputs.isEmpty {
            print("🎥 Camera session already configured")
            completion(.success(()))
            return
        }
        
        captureSession.beginConfiguration()
        
        // Remove existing inputs and outputs first
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        captureSession.outputs.forEach { captureSession.removeOutput($0) }
        
        // Set session preset
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            captureSession.commitConfiguration()
            completion(.failure(.deviceNotFound))
            return
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                print("✅ Camera input added successfully")
            } else {
                captureSession.commitConfiguration()
                completion(.failure(.cannotAddInput))
                return
            }
        } catch {
            captureSession.commitConfiguration()
            completion(.failure(.deviceNotFound))
            return
        }
        
        // Add photo output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
            print("✅ Photo output added successfully")
        } else {
            captureSession.commitConfiguration()
            completion(.failure(.cannotAddOutput))
            return
        }
        
        captureSession.commitConfiguration()
        completion(.success(()))
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("📷 Delegate: didFinishProcessingPhoto called")
        
        if let error = error {
            print("❌ Delegate: Photo processing error: \(error.localizedDescription)")
            photoCaptureCompletion?(.failure(.captureFailed))
            return
        }
        
        print("📷 Delegate: Getting image data...")
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("❌ Delegate: Failed to get image data")
            photoCaptureCompletion?(.failure(.invalidImage))
            return
        }
        
        print("📷 Delegate: Image captured, size: \(image.size)")
        
        // Process the image (resize, fix orientation)
        print("📷 Delegate: Processing image...")
        let processedImage = image.fixedOrientation()?.resizedToFit(maxSize: CGSize(width: Constants.Camera.maxImageSize, height: Constants.Camera.maxImageSize))
        
        if let processedImage = processedImage {
            print("✅ Delegate: Image processed successfully, final size: \(processedImage.size)")
            photoCaptureCompletion?(.success(processedImage))
        } else {
            print("❌ Delegate: Image processing failed")
            photoCaptureCompletion?(.failure(.processingFailed))
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("📷 Delegate: willCapturePhotoFor called")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("📷 Delegate: didCapturePhotoFor called")
    }
}

// MARK: - Supporting Types

/// Camera permission status
enum CameraPermissionStatus {
    case authorized
    case denied
    case notDetermined
}

/// Camera-related errors
enum CameraError: LocalizedError {
    case permissionDenied
    case deviceNotFound
    case cannotAddInput
    case cannotAddOutput
    case captureFailed
    case invalidImage
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return Constants.ErrorMessages.cameraPermissionDenied
        case .deviceNotFound:
            return "Camera device not found."
        case .cannotAddInput:
            return "Cannot add camera input to capture session."
        case .cannotAddOutput:
            return "Cannot add photo output to capture session."
        case .captureFailed:
            return "Failed to capture photo."
        case .invalidImage:
            return Constants.ErrorMessages.invalidImage
        case .processingFailed:
            return "Failed to process captured image."
        }
    }
}
