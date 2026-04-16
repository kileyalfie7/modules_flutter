# Hướng dẫn cài đặt Permission Manager Module

## 📋 Tổng quan

Module này cung cấp giải pháp hoàn chỉnh để quản lý quyền truy cập trên Flutter, hỗ trợ cả iOS và Android với khả năng:

- ✅ Kiểm tra và yêu cầu quyền truy cập
- ✅ Xử lý tất cả các trạng thái quyền (granted, denied, permanently denied, etc.)
- ✅ Hiển thị dialog giải thích tại sao cần quyền
- ✅ Mở trực tiếp trang cài đặt của app trên cả iOS và Android
- ✅ UI components sẵn sàng sử dụng
- ✅ Hỗ trợ tiếng Việt hoàn chỉnh

## 🛠 Bước 1: Cài đặt Dependencies

### 1.1 Thêm vào pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  permission_handler: ^11.0.1
```

### 1.2 Chạy lệnh cài đặt

```bash
flutter pub get
```

## 📱 Bước 2: Cấu hình Android

### 2.1 Cập nhật MainActivity.kt

Tạo hoặc cập nhật file `android/app/src/main/kotlin/com/yourpackage/MainActivity.kt`:

```kotlin
// Xem nội dung trong artifact android_native_settings
```

### 2.2 Cập nhật AndroidManifest.xml

Cập nhật file `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Xem nội dung trong artifact android_manifest -->
```

### 2.3 Cấu hình Gradle (nếu cần)

Trong file `android/app/build.gradle`, đảm bảo:

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        targetSdkVersion 34
        minSdkVersion 21
    }
}
```

## 🍎 Bước 3: Cấu hình iOS

### 3.1 Cập nhật AppDelegate.swift

Cập nhật file `ios/Runner/AppDelegate.swift`:

```swift
// Xem nội dung trong artifact ios_native_settings
```

### 3.2 Cập nhật Info.plist

Cập nhật file `ios/Runner/Info.plist`:

```xml
<!-- Xem nội dung trong artifact ios_info_plist -->
```

### 3.3 Cấu hình iOS Deployment Target

Trong file `ios/Runner.xcodeproj/project.pbxproj`, đảm bảo:

```
IPHONEOS_DEPLOYMENT_TARGET = 12.0
```

## 📁 Bước 4: Thêm files vào project

### 4.1 Tạo file permission_manager.dart

Tạo file `lib/permission_manager.dart` và copy nội dung từ artifact `permission_manager`.

### 4.2 Cập nhật main.dart

Sử dụng ví dụ trong artifact `example_usage` để test module.

## 🚀 Bước 5: Sử dụng Module

### 5.1 Import module

```dart
import 'permission_manager.dart';
```

### 5.2 Kiểm tra quyền đơn lẻ

```dart
// Kiểm tra trạng thái quyền
final result = await PermissionManager.checkPermission(PermissionType.camera);
print('Trạng thái camera: ${result.message}');

// Yêu cầu quyền
final requestResult = await PermissionManager.requestPermission(PermissionType.camera);
if (requestResult.status.isGranted) {
  print('Đã có quyền camera');
}
```

### 5.3 Xử lý quyền với UI hoàn chỉnh

```dart
await PermissionManager.handlePermission(
  context,
  PermissionType.camera,
  onGranted: () {
    // Quyền được cấp - mở camera
    print('Camera sẵn sàng');
  },
  onDenied: () {
    // Quyền bị từ chối
    print('Không thể sử dụng camera');
  },
  rationaleTitle: 'Cần quyền Camera',
  rationaleMessage: 'App cần camera để chụp ảnh',
);
```

### 5.4 Kiểm tra nhiều quyền cùng lúc

```dart
final permissions = [
  PermissionType.camera,
  PermissionType.microphone,
  PermissionType.location,
];

final results = await PermissionManager.checkMultiplePermissions(permissions);
for (final result in results) {
  print('${result.type}: ${result.message}');
}
```

### 5.5 Sử dụng PermissionWidget

```dart
PermissionWidget(
  permissions: [
    PermissionType.camera,
    PermissionType.microphone,
    PermissionType.storage,
  ],
  onAllPermissionsGranted: () {
    print('Tất cả quyền đã được cấp!');
  },
)
```

### 5.6 Mở cài đặt app

```dart
// Mở trang cài đặt của app
final success = await PermissionManager.openAppSettings();
if (success) {
  print('Đã mở cài đặt');
} else {
  print('Không thể mở cài đặt');
}
```

## 🔧 Xử lý các trường hợp đặc biệt

### Permanently Denied

```dart
final isPermanentlyDenied = await PermissionManager.isPermanentlyDenied(PermissionType.camera);
if (isPermanentlyDenied) {
  // Hiển thị dialog yêu cầu đi tới cài đặt
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Cần cấp quyền'),
      content: Text('Vui lòng vào Cài đặt để cấp quyền Camera'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            PermissionManager.openAppSettings();
          },
          child: Text('Cài đặt'),
        ),
      ],
    ),
  );
}
```

### Should Show Rationale

```dart
final shouldShow = await PermissionManager.shouldShowRequestRationale(PermissionType.camera);
if (shouldShow) {
  // Hiển thị dialog giải thích trước khi request
}
```

## 🐛 Troubleshooting

### Lỗi thường gặp:

1. **MissingPluginException**: Chạy `flutter clean && flutter pub get`

2. **Permission không hoạt động trên iOS**: Kiểm tra Info.plist có đầy đủ usage descriptions

3. **Không mở được Settings**: Kiểm tra LSApplicationQueriesSchemes trong Info.plist

4. **Android compilation error**: Kiểm tra targetSdkVersion >= 31 cho Android 12+

### Debug:

```dart
// Bật debug logs
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('Permission result: ${result.status}');
}
```

## 📝 Lưu ý quan trọng

### Android:

- Android 6.0+ (API 23+): Runtime permissions
- Android 10+ (API 29+): Scoped storage
- Android 11+ (API 30+): Package visibility
- Android 12+ (API 31+): Approximate location
- Android 13+ (API 33+): Granular media permissions

### iOS:

- iOS 12.0+: Deployment target
- iOS 14+: App Tracking Transparency
- iOS 15+: Location button
- Một số quyền cần thêm entitlements

### Best Practices:

1. Luôn kiểm tra quyền trước khi sử dụng tính năng
2. Giải thích rõ ràng tại sao cần quyền
3. Cung cấp alternative nếu người dùng từ chối quyền
4. Test trên cả device thật và simulator
5. Xử lý gracefully khi không có quyền

## 🔍 Testing

### Test trên emulator/simulator:

```bash
# Reset permissions
adb shell pm reset-permissions com.yourpackage.yourapp

# Grant specific permission
adb shell pm grant com.yourpackage.yourapp android.permission.CAMERA
```

### Test cases cần kiểm tra:

- [ ] Lần đầu yêu cầu quyền
- [ ] Người dùng từ chối quyền
- [ ] Người dùng từ chối và check "Don't ask again"
- [ ] Mở lại app sau khi từ chối quyền
- [ ] Cấp quyền từ Settings và quay lại app
- [ ] Multiple permissions cùng lúc
- [ ] App background/foreground state changes

Chúc bạn thành công với Permission Manager! 🎉

Tóm tắt
Tôi đã tạo một module quản lý quyền truy cập hoàn chỉnh cho Flutter với các tính năng chính:
🔑 Tính năng chính:

Quản lý đầy đủ các loại quyền: Camera, Microphone, Storage, Location, Contacts, Photos, Notification
Xử lý tất cả trạng thái: Granted, Denied, Permanently Denied, Restricted, Limited
UI Components sẵn sàng: PermissionWidget với giao diện thân thiện
Mở trực tiếp Settings: Native code cho cả Android và iOS

📱 Về việc mở Settings:
Để trả lời thắc mắc của bạn về cách đi đến đúng phần setting:
Android:

Sử dụng Settings.ACTION_APPLICATION_DETAILS_SETTINGS với package URI
Đi thẳng đến trang cài đặt quyền của app cụ thể
Có fallback cho các trường hợp đặc biệt

iOS:

Sử dụng UIApplication.openSettingsURLString
iOS chỉ cho phép mở trang Settings của app, không thể đi sâu hơn
Người dùng sẽ thấy trang cài đặt của app với tất cả quyền

🛠 Cấu hình Native:

Android: MethodChannel trong MainActivity.kt
iOS: MethodChannel trong AppDelegate.swift
Channel name: "permission_settings" (trùng nhau để đồng bộ)

📋 Files cần tạo:

lib/permission_manager.dart - Module chính
android/app/src/main/kotlin/.../MainActivity.kt - Android native
ios/Runner/AppDelegate.swift - iOS native
android/app/src/main/AndroidManifest.xml - Android permissions
ios/Runner/Info.plist - iOS usage descriptions

🎯 Điểm mạnh:

Xử lý hoàn chỉnh tất cả cases: Từ chối lần đầu, từ chối vĩnh viễn, cần giải thích
UI thân thiện: Dialog tự động, SnackBar thông báo, Loading states
Đa ngôn ngữ: Tất cả text bằng tiếng Việt
Error handling: Try-catch toàn diện, fallback cho các trường hợp lỗi
Best practices: Tuân thủ Material Design và iOS Human Interface Guidelines
