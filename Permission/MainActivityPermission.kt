// File: android/app/src/main/kotlin/com/yourpackage/MainActivity.kt

package com.yourpackage.yourapp

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    // Tên channel phải trùng với Flutter
    private val CHANNEL = "permission_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Tạo MethodChannel để giao tiếp với Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openAppSettings" -> {
                    // Mở trang cài đặt của ứng dụng
                    val success = openAppSettings()
                    result.success(success)
                }
                "openLocationSettings" -> {
                    // Mở trang cài đặt vị trí của hệ thống
                    val success = openLocationSettings()
                    result.success(success)
                }
                "openNotificationSettings" -> {
                    // Mở trang cài đặt thông báo của ứng dụng
                    val success = openNotificationSettings()
                    result.success(success)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Mở trang cài đặt chi tiết của ứng dụng
     * Đây là nơi người dùng có thể cấp/thu hồi quyền
     */
    private fun openAppSettings(): Boolean {
        return try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
                // Thêm flags để đảm bảo intent hoạt động tốt
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            // Nếu không mở được trang cài đặt cụ thể, thử mở trang cài đặt chung
            try {
                val fallbackIntent = Intent(Settings.ACTION_SETTINGS)
                startActivity(fallbackIntent)
                true
            } catch (ex: Exception) {
                false
            }
        }
    }

    /**
     * Mở trang cài đặt vị trí của hệ thống
     */
    private fun openLocationSettings(): Boolean {
        return try {
            val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Mở trang cài đặt thông báo của ứng dụng (Android 8.0+)
     */
    private fun openNotificationSettings(): Boolean {
        return try {
            val intent = Intent().apply {
                when {
                    // Android 8.0 (API 26) trở lên
                    android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O -> {
                        action = Settings.ACTION_APP_NOTIFICATION_SETTINGS
                        putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    }
                    // Android 5.0 (API 21) đến 7.1 (API 25)
                    android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP -> {
                        action = "android.settings.APP_NOTIFICATION_SETTINGS"
                        putExtra("app_package", packageName)
                        putExtra("app_uid", applicationInfo.uid)
                    }
                    // Phiên bản cũ hơn
                    else -> {
                        action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                        data = Uri.fromParts("package", packageName, null)
                    }
                }
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            // Fallback: mở cài đặt app nếu không mở được cài đặt thông báo
            openAppSettings()
        }
    }
}

/**
 * Extension methods để xử lý permissions (tùy chọn)
 */
object PermissionHelper {
    
    /**
     * Kiểm tra xem có nên hiển thị rationale dialog không
     */
    fun shouldShowRequestPermissionRationale(activity: FlutterActivity, permission: String): Boolean {
        return activity.shouldShowRequestPermissionRationale(permission)
    }
    
    /**
     * Tạo intent để mở trang cài đặt cụ thể
     */
    fun createSettingsIntent(packageName: String, settingsAction: String = Settings.ACTION_APPLICATION_DETAILS_SETTINGS): Intent {
        return Intent(settingsAction).apply {
            data = Uri.fromParts("package", packageName, null)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
    }
}