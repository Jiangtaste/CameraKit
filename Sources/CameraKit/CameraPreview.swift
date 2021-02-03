//
//  CameraPreview.swift
//
//
//  Created by Paul Lee on 2021/2/3.
//

import AVFoundation
import SwiftUI

struct CameraPreview: UIViewRepresentable {
    typealias UIViewType = UIView

    @StateObject var camera: CameraModel

    func makeUIView(context: Context) -> UIView {
        // make uiView
        let view = UIView(frame: UIScreen.main.bounds)
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame

        // properties...
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        //
    }
}
