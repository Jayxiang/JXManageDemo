//
//  CameraViewController.swift
//  PermissionsSwift
//
//  Created by Jayxiang on 2020/7/7.
//  Copyright © 2020 hyd-cjx. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet weak var frontCameraView: UIView!
    @IBOutlet weak var backCameraView: UIView!
    
    /// 获取设备：前置摄像头
    var frontDevice: AVCaptureDevice!
    /// 会话，协调着input到output的数据传输，input和output的桥梁
    var frontCaptureSession: AVCaptureSession!
    /// 图像预览层，实时显示捕获的图像
    var frontPreviewLayer: AVCaptureVideoPreviewLayer!
    /// 图像流输出
    var frontOutput:  AVCaptureVideoDataOutput!
    
    /// 后置摄像
    var backDevice: AVCaptureDevice!
    /// 后置会话，协调着input到output的数据传输，input和output的桥梁
    var backCaptureSession: AVCaptureSession!
    /// 后置图像预览层，实时显示捕获的图像
    var backPreviewLayer: AVCaptureVideoPreviewLayer!
    /// 后置图像流输出
    var backOutput:  AVCaptureVideoDataOutput!
    
    /// 相机开始同时拍照
    var beganTakePicture:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        creatSession()
        setConfiguration()
        
        //  iPhone11 pro 可以同时开启前置和后置
//        creatBack()
//        setBack()
    }
    
    func creatSession() {
        // SessionPreset,用于设置output输出流的画面质量
        frontCaptureSession = AVCaptureSession()
        //captureSession.sessionPreset = AVCaptureSession.Preset.photo
        if UIDevice.current.userInterfaceIdiom == .phone {
            frontCaptureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        } else {
            frontCaptureSession.sessionPreset = AVCaptureSession.Preset.photo
        }
        // 设置为高分辨率
        if frontCaptureSession.canSetSessionPreset(AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1280x720")) {
            frontCaptureSession.sessionPreset = AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1280x720")
        }
        // 获取输入设备,builtInWideAngleCamera是通用相机,AVMediaType.video代表视频媒体,back表示前置摄像头,如果需要后置摄像头修改为front
        if #available(iOS 10.0, *) {
            let availbleDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front).devices
            frontDevice = availbleDevices.first
        } else {
            let devices = AVCaptureDevice.devices(for: .video)
            guard devices.count > 0 else { return } /// 初始化摄像头设备
            guard let front = devices.filter({  return $0.position == .front }).first else { return }
            self.frontDevice = front
        }
    }
    // 配置 session
    func setConfiguration() {
        frontCaptureSession.beginConfiguration()
        do {
            // 将后置摄像头作为session的input 输入流
            let captureDeviceInput = try AVCaptureDeviceInput(device: frontDevice)
            frontCaptureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        // 设定视频预览层,也就是相机预览layer
        frontPreviewLayer = AVCaptureVideoPreviewLayer(session: frontCaptureSession)
        frontCameraView.layer.addSublayer(frontPreviewLayer)
        frontPreviewLayer.frame = frontCameraView.bounds
        // 相机页面展现形式-拉伸充满frame
        //previewLayer.videoGravity = AVLayerVideoGravity(rawValue: "AVLayerVideoGravityResizeAspectFill")
        frontPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
         
        // 设定输出流
        frontOutput = AVCaptureVideoDataOutput()
        // 指定像素格式
        frontOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
        // 是否直接丢弃处理旧帧时捕获的新帧,默认为True,如果改为false会大幅提高内存使用
        frontOutput.alwaysDiscardsLateVideoFrames = true
        if frontCaptureSession.canAddOutput(frontOutput) {
            frontCaptureSession.addOutput(frontOutput)
        }
        // beginConfiguration()和commitConfiguration()方法中的修改将在commit时同时提交
        frontCaptureSession.commitConfiguration()
        frontCaptureSession.startRunning()
        // 开新线程进行输出流代理方法调用
        let queue = DispatchQueue(label: "captureQueue")
        frontOutput.setSampleBufferDelegate(self, queue: queue)
         
        let captureConnection = frontOutput.connection(with: .video)
        if captureConnection?.isVideoStabilizationSupported == true {
            /// 这个很重要 这个是为了拍照完成，防止图片旋转90度
            captureConnection?.videoOrientation = self.getCaptureVideoOrientation()
        }
    }
    
    func creatBack() {
        // SessionPreset,用于设置output输出流的画面质量
        backCaptureSession = AVCaptureSession()
        //captureSession.sessionPreset = AVCaptureSession.Preset.photo
        if UIDevice.current.userInterfaceIdiom == .phone {
            backCaptureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        } else {
            backCaptureSession.sessionPreset = AVCaptureSession.Preset.photo
        }
        // 设置为高分辨率
        if backCaptureSession.canSetSessionPreset(AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1280x720")) {
            backCaptureSession.sessionPreset = AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1280x720")
        }
        // 获取输入设备,builtInWideAngleCamera是通用相机,AVMediaType.video代表视频媒体,back表示前置摄像头,如果需要后置摄像头修改为front
        if #available(iOS 10.0, *) {
            let availbleDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices
            backDevice = availbleDevices.first
        } else {
            let devices = AVCaptureDevice.devices(for: .video)
            guard devices.count > 0 else { return } /// 初始化摄像头设备
            guard let front = devices.filter({  return $0.position == .back }).first else { return }
            self.backDevice = front
        }
    }
    func setBack() {
        backCaptureSession.beginConfiguration()
        do {
            // 将后置摄像头作为session的input 输入流
            let captureDeviceInput = try AVCaptureDeviceInput(device: backDevice)
            backCaptureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        // 设定视频预览层,也就是相机预览layer
        backPreviewLayer = AVCaptureVideoPreviewLayer(session: backCaptureSession)
        backCameraView.layer.addSublayer(backPreviewLayer)
        backPreviewLayer.frame = backCameraView.bounds
        // 相机页面展现形式-拉伸充满frame
        //previewLayer.videoGravity = AVLayerVideoGravity(rawValue: "AVLayerVideoGravityResizeAspectFill")
        backPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        // 设定输出流
        backOutput = AVCaptureVideoDataOutput()
        // 指定像素格式
        backOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
        // 是否直接丢弃处理旧帧时捕获的新帧,默认为True,如果改为false会大幅提高内存使用
        backOutput.alwaysDiscardsLateVideoFrames = true
        if backCaptureSession.canAddOutput(backOutput) {
            backCaptureSession.addOutput(backOutput)
        }
        // beginConfiguration()和commitConfiguration()方法中的修改将在commit时同时提交
        backCaptureSession.commitConfiguration()
        backCaptureSession.startRunning()
        // 开新线程进行输出流代理方法调用
        let queue = DispatchQueue(label: "backCaptureQueue")
        backOutput.setSampleBufferDelegate(self, queue: queue)

        let captureConnection = backOutput.connection(with: .video)
        if captureConnection?.isVideoStabilizationSupported == true {
            /// 这个很重要 这个是为了拍照完成，防止图片旋转90度
            captureConnection?.videoOrientation = self.getCaptureVideoOrientation()
        }
    }
    /// 旋转方向
    func getCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait,.faceUp,.faceDown:
            return .portrait
        // 如果这里设置成AVCaptureVideoOrientationPortraitUpsideDown,则视频方向和拍摄时的方向是相反的。
        case .portraitUpsideDown:
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
    /// CMSampleBufferRef=>UIImage
    func imageConvert(sampleBuffer:CMSampleBuffer?) -> UIImage? {
        guard sampleBuffer != nil && CMSampleBufferIsValid(sampleBuffer!) == true else { return nil }
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer!)
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer!)
        return UIImage(ciImage: ciImage)
    }

}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if beganTakePicture == true {
            beganTakePicture = false
            /// 注意在主线程中执行
            DispatchQueue.main.async {
                self.frontCaptureSession.stopRunning()
                print(self.imageConvert(sampleBuffer: sampleBuffer)!)
            }
        }
    }
}
