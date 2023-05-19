//
//  QRScanViewController.swift
//  linphone
//
//  Created by Nicola Innocenti on 12/05/23.
//
//

import UIKit
import AVFoundation

typealias StringBlock = (String?) -> Void
 
@objc class ScanQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let scanContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let btnClose: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancel_forward"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var completion: StringBlock?
    private var didFirstLoad = false
    
    @objc convenience init(onScanComplete: @escaping StringBlock) {
        self.init()
        self.completion = onScanComplete
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scanContainer)
        view.addSubview(btnClose)
        NSLayoutConstraint.activate([
            scanContainer.topAnchor.constraint(equalTo: view.topAnchor),
            scanContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scanContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scanContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            btnClose.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            btnClose.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            btnClose.widthAnchor.constraint(equalToConstant: 32),
            btnClose.heightAnchor.constraint(equalToConstant: 32)
        ])
        view.backgroundColor = .black
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

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .upce]
        } else {
            failed()
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didFirstLoad {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = CGRect(x: 0, y: 0, width: scanContainer.frame.size.width, height: scanContainer.frame.size.height)
            previewLayer.videoGravity = .resizeAspectFill
            scanContainer.layer.addSublayer(previewLayer)
            captureSession.startRunning()
            didFirstLoad = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if previewLayer != nil {
            previewLayer.frame = CGRect(x: 0, y: 0, width: scanContainer.frame.size.width, height: scanContainer.frame.size.height)
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        if let metadataObject = metadataObjects.first {
            captureSession.stopRunning()
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        } else {
            found(code: nil)
        }
    }

    func found(code: String?) {
        print("[SCAN QR] Found: \(code ?? "nil")")
        if let completion = completion {
            completion(code)
        }
        dismiss(animated: true)
    }
    
    func failed() {

    }

    @objc func close() {
        dismiss(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
