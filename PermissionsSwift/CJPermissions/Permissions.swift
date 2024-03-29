//
//  Permissions.swift
//  PermissionsSwift
//
//  Created by Jayxiang on 2020/7/5.
//  Copyright © 2020 hyd-cjx. All rights reserved.
//

import Foundation
// 获取相册状态权限
import Photos
// 网络权限
import CoreTelephony
// 讯录权限
import Contacts
// 定位权限
import CoreLocation
// 蓝牙权限
import CoreBluetooth
// 语音识别
import Speech
// 推送权限
import UserNotifications
// 日历备忘录
import EventKit
// 媒体库
import MediaPlayer

public class Permissions: NSObject {
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    private var locationBlock: ((_ authorized: Bool) -> Void)?
    /// 是否自动弹出设置
    static var isAutoPresent: Bool = false
    
    // MARK: - 相册权限
    /// 是否开启相册权限
    static func getPhotoPermissions(_ сompletion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        // 首次安装APP，用户还未授权，系统会请求用户授权
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { result in
                DispatchQueue.main.async {
                    if result == .authorized {
                        сompletion(true)
                    } else {
                        сompletion(false)
                        Permissions().createAlertWithMessage(message: "相册")
                    }
                }
            }
        } else if (status == .authorized) {
            сompletion(true)
        } else {
            сompletion(false)
            Permissions().createAlertWithMessage(message: "相册")
        }
    }
    
    /// 是否开启相册权限 iOS 14 后
    @available(iOS 14, *)
    static func getPhotoPermissions(level: PHAccessLevel = .readWrite, _ сompletion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: level)
        // 首次安装APP，用户还未授权，系统会请求用户授权
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: level) { result in
                DispatchQueue.main.async {
                    if result == .authorized {
                        сompletion(true)
                    } else {
                        сompletion(false)
                        Permissions().createAlertWithMessage(message: "相册")
                    }
                }
            }
        } else if (status == .authorized) {
            сompletion(true)
        } else {
            сompletion(false)
            Permissions().createAlertWithMessage(message: "相册")
        }
    }
    
    // MARK: - 相机权限
    /// 是否开启相机权限
    static func getCameraPermissions(_ сompletion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        сompletion(true)
                    } else {
                        сompletion(false)
                    }
                }
            }
        } else if (status == .authorized) {
            сompletion(true)
        } else {
            сompletion(false)
        }
    }
    
    // MARK: - 网络权限
    /// 首次进入的蜂窝网络权限
    static func getNetworkPermissions(_ сompletion: @escaping (Bool) -> Void) {
        let cellularData = CTCellularData()
        let status = cellularData.restrictedState
        if status == .restrictedStateUnknown {
            cellularData.cellularDataRestrictionDidUpdateNotifier = { result in
                DispatchQueue.main.async {
                    if result == .notRestricted {
                        сompletion(true)
                    } else {
                        сompletion(false)
                    }
                }
            }
        } else if (status == .notRestricted) {
            сompletion(true)
        } else {
            сompletion(false)
        }
    }

    // MARK: - 通讯录权限
    /// 通讯录权限
    static func getAddressBookPermissions(_ сompletion: @escaping (Bool) -> Void) {
        let contactStore = CNContactStore()
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .notDetermined {
            contactStore.requestAccess(for: .contacts) { (granted, error) in
                DispatchQueue.main.async {
                    guard (error != nil) else {
                        сompletion(false)
                        return
                    }
                    if granted {
                        сompletion(true)
                    } else {
                        сompletion(false)
                    }
                }
            }
        } else if (status == .authorized) {
            сompletion(true)
        } else {
            сompletion(false)
        }
    }
    
    // MARK: - 获取定位权限
    /// 获取定位权限 是否一直获取 true:一直获取 false:使用期间获取
    static func getLocationPermissions(_ isAlways: Bool, _ сompletion: @escaping (Bool) -> Void) {
        guard !CLLocationManager.locationServicesEnabled() else {
            return
        }
        let status = CLLocationManager.authorizationStatus()
        DispatchQueue.main.async {
            if status.rawValue > 0 && status.rawValue < 3 {
                сompletion(false)
            } else if (status == .notDetermined) {
                Permissions().locationBlock = сompletion
                if isAlways {
                    Permissions().locationManager.requestAlwaysAuthorization()
                } else {
                    Permissions().locationManager.requestWhenInUseAuthorization()
                }
            } else {
                if isAlways {
                    if status == .authorizedAlways {
                        сompletion(true)
                    } else {
                        сompletion(false)
                    }
                } else {
                    сompletion(true)
                }
            }
        }
    }
    
    // MARK: - 蓝牙权限
    /// 蓝牙权限
    static func getBluetoothPermissions(_ сompletion: @escaping (Bool) -> Void) {
        if #available(iOS 13.1, *) {
            let bluetoothStatus = CBManager.authorization
            if bluetoothStatus == .notDetermined {
                CBCentralManager().scanForPeripherals(withServices: nil, options: nil)
            } else if bluetoothStatus == .allowedAlways {
                сompletion(true)
            } else {
                сompletion(false)
            }
        } else {
            let status = CBPeripheralManager.authorizationStatus()
            if status == .notDetermined {
                CBCentralManager().scanForPeripherals(withServices: nil, options: nil)
            } else if (status == .authorized) {
                сompletion(true)
            } else {
                сompletion(false)
            }
        }
    }
    
    // MARK: - 麦克风权限
    /// 麦克风权限
    static func getMicrophonePermissions(_ сompletion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .audio) { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        сompletion(true)
                    } else {
                        сompletion(false)
                    }
                }
            }
        } else if (status == .authorized) {
            сompletion(true)
        } else {
            сompletion(false)
        }
    }
    
    // MARK: - 语音识别权限
    /// 语音识别权限 iOS10 以上
    static func getSpeechRecognitionPermissions(_ сompletion: @escaping (Bool) -> Void) {
        let status = SFSpeechRecognizer.authorizationStatus()
        if status == .notDetermined {
            SFSpeechRecognizer.requestAuthorization { (granted) in
                DispatchQueue.main.async {
                    if granted == .authorized {
                        сompletion(true)
                    } else {
                        сompletion(false)
                    }
                }
            }
        } else if (status == .authorized) {
            сompletion(true)
        } else {
            сompletion(false)
        }
    }
    
    // MARK: - 推送权限
    /// 推送权限 iOS10 以上
    static func getPushPermissions(_ сompletion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            DispatchQueue.main.async {
                if granted {
                    сompletion(true)
                } else {
                    сompletion(false)
                }
            }
        }
    }
    
    // MARK: - 日历权限
    /// 日历权限
    static func getCalendarPermissions(_ сompletion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            DispatchQueue.main.async {
                if granted {
                    сompletion(true)
                } else {
                    сompletion(false)
                }
            }
        }
    }
    
    // MARK: - 提醒事项权限
    /// 提醒事项权限
    static func getReminderPermissions(_ сompletion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .reminder) { (granted, error) in
            DispatchQueue.main.async {
                if granted {
                    сompletion(true)
                } else {
                    сompletion(false)
                }
            }
        }
    }
    
    // MARK: - 媒体库权限
    /// 媒体库权限
    static func getMediaPermissions(_ сompletion: @escaping (Bool) -> Void) {
        let status = MPMediaLibrary.authorizationStatus()
        if status == .notDetermined {
            MPMediaLibrary.requestAuthorization { (granted) in
               DispatchQueue.main.async {
                    if granted == .authorized {
                        сompletion(true)
                    } else {
                        сompletion(false)
                    }
                }
            }
        } else if (status == .authorized) {
            сompletion(true)
        } else {
            сompletion(false)
        }
    }
}

/// CLLocationManagerDelegate：定位代理回调
extension Permissions: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let statusBlock = locationBlock else { return }
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            statusBlock(true)
        default:
            statusBlock(false)
        }
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}

extension Permissions {
    /// 提示信息
    func createAlertWithMessage(message: String) {
        guard Permissions.isAutoPresent else {
            return
        }
        let alertMessage = "您可以进入系统设置>隐私>\(message)，允许访问您的\(message)"
        let titleMessage = "\(message)权限未开启"
        let alertController: UIAlertController = UIAlertController(title: titleMessage, message: alertMessage, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        let ensureAction: UIAlertAction = UIAlertAction(title: "确定", style: .default) { (_) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(ensureAction)
        DispatchQueue.main.async {
            self.topViewController()?.present(alertController, animated: true, completion: nil)
        }
    }
    private func topViewController() -> UIViewController? {
        var resultVC: UIViewController?
        resultVC = self._topViewController((UIApplication.shared.keyWindow?.rootViewController)!)
        while ((resultVC?.presentedViewController) != nil) {
            resultVC = self._topViewController(resultVC?.presentedViewController)
        }
        return resultVC
    }
    private func _topViewController(_ viewController: UIViewController?) -> UIViewController? {
        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return self._topViewController(selectedViewController)
        }
        if let navigationController = viewController as? UINavigationController,
            let topViewController = navigationController.topViewController {
            return self._topViewController(topViewController)
        }
        return viewController
    }
}
