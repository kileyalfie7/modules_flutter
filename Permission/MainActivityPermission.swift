// File: ios/Runner/AppDelegate.swift

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Lấy flutter controller
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // Tạo MethodChannel với tên trùng với Flutter và Android
        let permissionChannel = FlutterMethodChannel(name: "permission_settings",
                                                   binaryMessenger: controller.binaryMessenger)
        
        // Xử lý các method call từ Flutter
        permissionChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            switch call.method {
            case "openAppSettings":
                // Mở trang cài đặt của ứng dụng
                self?.openAppSettings(result: result)
                
            case "openLocationSettings":
                // Mở trang cài đặt vị trí của hệ thống
                self?.openLocationSettings(result: result)
                
            case "openNotificationSettings":
                // Mở trang cài đặt thông báo của hệ thống
                self?.openNotificationSettings(result: result)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /**
     * Mở trang cài đặt của ứng dụng
     * Đây là nơi người dùng có thể cấp/thu hồi quyền cho ứng dụng
     */
    private func openAppSettings(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            // Kiểm tra xem URL cài đặt app có khả dụng không
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl) { success in
                        result(success)
                    }
                } else {
                    result(false)
                }
            } else {
                result(false)
            }
        }
    }
    
    /**
     * Mở trang cài đặt vị trí của hệ thống
     * Lưu ý: iOS không cho phép mở trực tiếp trang cài đặt vị trí
     * Chỉ có thể mở trang cài đặt chung
     */
    private func openLocationSettings(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            // iOS không cho phép mở trực tiếp trang Location Settings
            // Chỉ có thể mở Settings app hoặc app settings
            if let settingsUrl = URL(string: "App-Prefs:Privacy&path=LOCATION") {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl) { success in
                        result(success)
                    }
                } else {
                    // Fallback: mở cài đặt app
                    self.openAppSettings(result: result)
                }
            } else {
                // Fallback: mở cài đặt app
                self.openAppSettings(result: result)
            }
        }
    }
    
    /**
     * Mở trang cài đặt thông báo
     * iOS không cho phép mở trực tiếp trang notification settings
     * Chỉ có thể mở trang cài đặt app
     */
    private func openNotificationSettings(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            // iOS không cho phép mở trực tiếp trang Notification Settings
            // Chỉ có thể mở app settings
            self.openAppSettings(result: result)
        }
    }
}

/**
 * Extension để xử lý permissions (tùy chọn)
 */
extension AppDelegate {
    
    /**
     * Kiểm tra trạng thái quyền notification
     */
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    /**
     * Yêu cầu quyền notification
     */
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}