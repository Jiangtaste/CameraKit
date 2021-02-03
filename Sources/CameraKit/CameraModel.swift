//
//  File.swift
//
//
//  Created by Paul Lee on 2021/2/3.
//

import AVFoundation
import Foundation

class CameraModel: NSObject, ObservableObject {
    // published vars
    @Published var session = AVCaptureSession()
    @Published var preview: AVCaptureVideoPreviewLayer!

    // 默认使用前置相机
    @Published var cameraPosition: AVCaptureDevice.Position = .front

    // 默认为拍照模式
    @Published var mediaType: MediaType = .photo
    private var output: AVCaptureOutput = AVCapturePhotoOutput()

    // 输出内容

    // 拍摄输出
    enum MediaType {
        case photo, video
    }

    // MARK: - 硬件权限

    // 监测相机，麦克风权限
    private func checkPermissions(for mediaType: AVMediaType) {
        // 检测是否已获得相机授权
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .notDetermined:
            // 尚未询问用户授权
            requestCameraAccess()
        case .authorized:
            // 用户已授权
            configureDevices()
            return
        case .denied:
            // 用户已拒绝授权
            handelPermissonDenied()
            return
        case .restricted:
            // 家长控制权限
            handelPermissonDenied()
            return
        default:
            return
        }
    }

    // 请求设备权限
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { status in
            if status {
                // 同意相机授权
                self.configureDevices()
            } else {
                // 拒绝相机授权
                self.handelPermissonDenied()
            }
        }
    }

    // 未获取权限
    private func handelPermissonDenied() {
    }

    // MARK: - 初始化设备

    private func configureDevices() {
        session.beginConfiguration()

        // 添加输入
        configureInput()

        // 添加输出
        configureOutput()

        session.commitConfiguration()
    }

    private func configureInput() {
        debugPrint("[CameraModel] configure input with \(cameraPosition) device")

        // 移除已添加的输入设备，切换摄像头时需要
        for input in session.inputs { session.removeInput(input) }

        // 将指定的摄像头添加到输入
        do {
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) else {
                debugPrint("[CameraModel] failed to get camera deivce")
                return
            }

            let input = try AVCaptureDeviceInput(device: camera)

            if session.canAddInput(input) { session.addInput(input) }
        } catch {
            debugPrint("[CameraModel] configure input failed. \(error.localizedDescription)")
        }
    }

    private func configureOutput() {
        // 移除已添加的输出，切换拍照/视频模式时需要
        for output in session.outputs { session.removeOutput(output) }

        // 根据meidaType添加输出
        switch mediaType {
        case .photo:
            // 拍照
            output = AVCapturePhotoOutput()
        case .video:
            // 录制视频
            output = AVCaptureMovieFileOutput()
        }

        if session.canAddOutput(output) {
            session.addOutput(output)
        }
    }

    // MARK: - Capture Output Handlers

    private func handlePhotoOutput(output photo: AVCapturePhoto) {
//        guard let imageData = photo.fileDataRepresentation() else { return }
//        photoData = imageData
    }

    private func handleMovieOutput(output url: URL) {
        print("Movie URL: \(url.absoluteString)")
    }
}

// MARK: - User intents

extension CameraModel {
    // 切换相机

    // 拍照
    // 录制
    // 停止录制
}

// MARK: - AVCapture Photo Output Delegate

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // error handler
        if let error = error {
            debugPrint(error.localizedDescription)
            return
        }

        handlePhotoOutput(output: photo)
    }
}

// MARK: - AVCapture Movie Output Delegate

extension CameraModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // error handler
        if let error = error {
            debugPrint(error.localizedDescription)
            return
        }

        handleMovieOutput(output: outputFileURL)
    }
}
