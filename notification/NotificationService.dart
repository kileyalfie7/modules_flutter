# Hướng dẫn Setup Push Notification Flutter

## 1. Cài đặt Dependencies

Thêm vào `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^16.3.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
```

## 2. Cấu hình Firebase

### Android (android/app/build.gradle):
```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
}
```

### iOS (ios/Runner/Info.plist):
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## 3. Setup Notification Channels (Android)

Tạo file `android/app/src/main/res/raw/notification_channel.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_notification_channel_id">high_importance_channel</string>
    <string name="default_notification_channel_name">High Importance Notifications</string>
</resources>
```

## 4. Các Case Sử Dụng Phổ Biến

### Case 1: Thông báo tin nhắn mới
```dart
// Payload để gửi từ server
{
  "notification": {
    "title": "Tin nhắn mới từ Nguyễn Văn A",
    "body": "Chào bạn, tôi muốn hỏi về sản phẩm..."
  },
  "data": {
    "type": "message",
    "route": "/message",
    "messageId": "msg_123",
    "senderId": "user_456",
    "chatRoomId": "room_789"
  }
}
```

### Case 2: Thông báo đơn hàng
```dart
// Payload cho trạng thái đơn hàng
{
  "notification": {
    "title": "Đơn hàng #DH001 đã được xác nhận",
    "body": "Đơn hàng của bạn đang được chuẩn bị"
  },
  "data": {
    "type": "order",
    "route": "/order",
    "orderId": "DH001",
    "status": "confirmed",
    "estimatedDelivery": "2024-01-15"
  }
}
```

### Case 3: Thông báo khuyến mãi
```dart
// Payload cho chương trình khuyến mãi
{
  "notification": {
    "title": "🎉 Giảm giá 50% cho tất cả sản phẩm",
    "body": "Cơ hội cuối cùng! Chỉ còn 2 ngày"
  },
  "data": {
    "type": "promotion",
    "route": "/promotion",
    "promotionId": "SALE50",
    "validUntil": "2024-01-20",
    "discountPercent": "50"
  }
}
```

### Case 4: Thông báo hệ thống
```dart
// Payload cho thông báo bảo trì
{
  "notification": {
    "title": "Thông báo bảo trì hệ thống",
    "body": "Hệ thống sẽ bảo trì từ 2:00 - 4:00 sáng ngày mai"
  },
  "data": {
    "type": "system",
    "route": "/home",
    "maintenanceStart": "2024-01-15T02:00:00Z",
    "maintenanceEnd": "2024-01-15T04:00:00Z"
  }
}
```

### Case 5: Thông báo reminder
```dart
// Payload để nhắc nhở
{
  "notification": {
    "title": "⏰ Nhắc nhở: Cuộc họp sắp bắt đầu",
    "body": "Cuộc họp team sẽ bắt đầu sau 15 phút"
  },
  "data": {
    "type": "reminder",
    "route": "/calendar",
    "eventId": "event_123",
    "eventTime": "2024-01-15T14:00:00Z",
    "eventTitle": "Weekly Team Meeting"
  }
}
```

## 5. Xử lý Navigation Case Nâng cao

```dart
// Trong NotificationService, mở rộng hàm _handleNotificationTap
void _handleNotificationTap(RemoteMessage message) {
  String route = message.data['route'] ?? '/home';
  Map<String, dynamic>? data = message.data.isNotEmpty ? message.data : null;
  
  // Xử lý các case đặc biệt
  switch (message.data['type']) {
    case 'message':
      _handleMessageNotification(data);
      break;
    case 'order':
      _handleOrderNotification(data);
      break;
    case 'promotion':
      _handlePromotionNotification(data);
      break;
    case 'deeplink':
      _handleDeepLink(data);
      break;
    default:
      onNotificationTap?.call(route, data);
  }
}

// Xử lý thông báo tin nhắn
void _handleMessageNotification(Map<String, dynamic>? data) {
  if (data != null) {
    // Mở trực tiếp chat room
    onNotificationTap?.call('/chat', {
      'chatRoomId': data['chatRoomId'],
      'senderId': data['senderId'],
      'autoFocus': true, // Tự động focus input
    });
  }
}

// Xử lý thông báo đơn hàng
void _handleOrderNotification(Map<String, dynamic>? data) {
  if (data != null) {
    // Mở chi tiết đơn hàng với tab tracking
    onNotificationTap?.call('/order-detail', {
      'orderId': data['orderId'],
      'openTab': 'tracking', // Mở tab theo dõi
      'highlightStatus': data['status'],
    });
  }
}

// Xử lý deep link
void _handleDeepLink(Map<String, dynamic>? data) {
  if (data != null && data['deeplink'] != null) {
    String deeplink = data['deeplink'];
    // Parse deep link và navigate
    _parseAndNavigateDeepLink(deeplink);
  }
}
```

## 6. Quản lý Badge Count Nâng cao

```dart
// Mở rộng NotificationService với persistent badge count
class NotificationService {
  static const String _badgeCountKey = 'notification_badge_count';
  
  // Load badge count từ storage khi khởi tạo
  Future<void> _loadBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    _badgeCount = prefs.getInt(_badgeCountKey) ?? 0;
    onBadgeCountUpdate?.call(_badgeCount);
  }
  
  // Lưu badge count vào storage
  Future<void> _saveBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_badgeCountKey, _badgeCount);
  }
  
  // Override các method tăng/giảm badge
  void _increaseBadgeCount() {
    _badgeCount++;
    onBadgeCountUpdate?.call(_badgeCount);
    _saveBadgeCount();
  }
  
  void _decreaseBadgeCount() {
    if (_badgeCount > 0) {
      _badgeCount--;
      onBadgeCountUpdate?.call(_badgeCount);
      _saveBadgeCount();
    }
  }
}
```

## 7. Custom Notification Sound

```dart
// Thêm sound tùy chỉnh cho notification
Future<void> _showLocalNotification(RemoteMessage message) async {
  // Xác định sound dựa trên type
  String soundFile = _getSoundForType(message.data['type']);
  
  final AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'Kênh thông báo quan trọng',
    importance: Importance.high,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound(soundFile),
    playSound: true,
    enableVibration: true,
    vibrationPattern: _getVibrationPattern(message.data['type']),
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    styleInformation: _getNotificationStyle(message),
  );
  
  const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'notification_sound.aiff', // File sound tùy chỉnh
  );
  
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidDetails,
    iOS: iOSDetails,
  );
  
  await _localNotifications.show(
    message.hashCode,
    message.notification?.title ?? 'Thông báo mới',
    message.notification?.body ?? 'Bạn có thông báo mới',
    platformChannelSpecifics,
    payload: _createPayload(message.data),
  );
}

// Lấy sound file theo loại notification
String _getSoundForType(String? type) {
  switch (type) {
    case 'message':
      return 'message_sound';
    case 'order':
      return 'order_sound';
    case 'promotion':
      return 'promotion_sound';
    case 'urgent':
      return 'urgent_sound';
    default:
      return 'default_sound';
  }
}

// Lấy pattern rung theo loại notification
Int64List _getVibrationPattern(String? type) {
  switch (type) {
    case 'urgent':
      return Int64List.fromList([0, 1000, 500, 1000]); // Rung mạnh
    case 'message':
      return Int64List.fromList([0, 500, 200, 500]); // Rung nhẹ
    default:
      return Int64List.fromList([0, 250, 250, 250]); // Rung thông thường
  }
}

// Tạo style notification phong phú
StyleInformation? _getNotificationStyle(RemoteMessage message) {
  String? type = message.data['type'];
  
  switch (type) {
    case 'message':
      return MessagingStyleInformation(
        Person(
          name: message.data['senderName'] ?? 'Người gửi',
          key: message.data['senderId'],
          icon: BitmapFilePathAndroidIcon(message.data['senderAvatar']),
        ),
        conversationTitle: message.data['chatTitle'],
        groupConversation: message.data['isGroup'] == 'true',
        messages: [
          Message(
            message.notification?.body ?? '',
            DateTime.now(),
            Person(
              name: message.data['senderName'] ?? 'Người gửi',
              key: message.data['senderId'],
            ),
          ),
        ],
      );
      
    case 'order':
      return BigTextStyleInformation(
        message.notification?.body ?? '',
        htmlFormatBigText: true,
        contentTitle: message.notification?.title,
        htmlFormatContentTitle: true,
        summaryText: 'Cập nhật đơn hàng',
        htmlFormatSummaryText: true,
      );
      
    case 'promotion':
      return BigPictureStyleInformation(
        DrawableResourceAndroidBitmap('@drawable/promotion_banner'),
        contentTitle: message.notification?.title,
        htmlFormatContentTitle: true,
        summaryText: message.notification?.body,
        htmlFormatSummaryText: true,
      );
      
    default:
      return null;
  }
}
```

## 8. Scheduled Notifications (Thông báo lên lịch)

```dart
// Thêm vào NotificationService
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // Khởi tạo timezone
  Future<void> _initializeTimezone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
  
  // Lên lịch notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String route = '/home',
    Map<String, dynamic>? data,
    NotificationType type = NotificationType.system,
  }) async {
    final tz.TZDateTime scheduledDateTime = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );
    
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Thông báo đã lên lịch',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidDetails);
    
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDateTime,
      platformChannelSpecifics,
      payload: _createPayload({'route': route, 'data': data}),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Lặp lại hàng ngày
    );
  }
  
  // Lên lịch thông báo lặp lại
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String route = '/home',
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'repeating_channel',
      'Repeating Notifications',
      channelDescription: 'Thông báo lặp lại',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidDetails);
    
    await _localNotifications.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      platformChannelSpecifics,
      payload: _createPayload({'route': route, 'data': data}),
    );
  }
  
  // Hủy notification đã lên lịch
  Future<void> cancelScheduledNotification(int id) async {
    await _localNotifications.cancel(id);
  }
  
  // Hủy tất cả notification đã lên lịch
  Future<void> cancelAllScheduledNotifications() async {
    await _localNotifications.cancelAll();
  }
}
```

## 9. Notification Analytics & Tracking

```dart
// Thêm tracking cho notification
class NotificationAnalytics {
  static final NotificationAnalytics _instance = NotificationAnalytics._internal();
  factory NotificationAnalytics() => _instance;
  NotificationAnalytics._internal();
  
  // Track khi notification được nhận
  void trackNotificationReceived({
    required String notificationId,
    required String type,
    required String title,
    DateTime? timestamp,
  }) {
    // Gửi event lên analytics service (Firebase Analytics, etc.)
    _sendAnalyticsEvent('notification_received', {
      'notification_id': notificationId,
      'notification_type': type,
      'notification_title': title,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
    });
  }
  
  // Track khi notification được nhấn
  void trackNotificationTapped({
    required String notificationId,
    required String type,
    required String route,
    DateTime? timestamp,
  }) {
    _sendAnalyticsEvent('notification_tapped', {
      'notification_id': notificationId,
      'notification_type': type,
      'target_route': route,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
    });
  }
  
  // Track khi notification bị dismiss
  void trackNotificationDismissed({
    required String notificationId,
    required String type,
    DateTime? timestamp,
  }) {
    _sendAnalyticsEvent('notification_dismissed', {
      'notification_id': notificationId,
      'notification_type': type,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
    });
  }
  
  void _sendAnalyticsEvent(String eventName, Map<String, dynamic> parameters) {
    // Implement gửi event lên analytics service
    print('Analytics Event: $eventName - $parameters');
  }
}

// Tích hợp tracking vào NotificationService
class NotificationService {
  void _handleForegroundMessage(RemoteMessage message) {
    // Track notification received
    NotificationAnalytics().trackNotificationReceived(
      notificationId: message.messageId ?? '',
      type: message.data['type'] ?? 'unknown',
      title: message.notification?.title ?? '',
    );
    
    _increaseBadgeCount();
    _showLocalNotification(message);
  }
  
  void _handleNotificationTap(RemoteMessage message) {
    // Track notification tapped
    NotificationAnalytics().trackNotificationTapped(
      notificationId: message.messageId ?? '',
      type: message.data['type'] ?? 'unknown',
      route: message.data['route'] ?? '/home',
    );
    
    _decreaseBadgeCount();
    
    String route = message.data['route'] ?? '/home';
    Map<String, dynamic>? data = message.data.isNotEmpty ? message.data : null;
    onNotificationTap?.call(route, data);
  }
}
```

## 10. Notification Permission Management

```dart
// Widget quản lý quyền notification
class NotificationPermissionWidget extends StatefulWidget {
  final Widget child;
  
  const NotificationPermissionWidget({Key? key, required this.child}) : super(key: key);
  
  @override
  State<NotificationPermissionWidget> createState() => _NotificationPermissionWidgetState();
}

class _NotificationPermissionWidgetState extends State<NotificationPermissionWidget> {
  bool _hasPermission = false;
  bool _isChecking = true;
  
  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }
  
  Future<void> _checkNotificationPermission() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    final NotificationSettings settings = await messaging.getNotificationSettings();
    
    setState(() {
      _hasPermission = settings.authorizationStatus == AuthorizationStatus.authorized;
      _isChecking = false;
    });
    
    if (!_hasPermission) {
      _showPermissionDialog();
    }
  }
  
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cho phép thông báo'),
          content: Text(
            'Ứng dụng cần quyền gửi thông báo để cập nhật thông tin mới nhất cho bạn.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Có thể disable features yêu cầu notification
              },
              child: Text('Để sau'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestPermission();
              },
              child: Text('Cho phép'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _requestPermission() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    setState(() {
      _hasPermission = settings.authorizationStatus == AuthorizationStatus.authorized;
    });
    
    if (!_hasPermission) {
      _showSettingsDialog();
    }
  }
  
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mở cài đặt'),
          content: Text(
            'Bạn cần mở cài đặt và cho phép thông báo để sử dụng tính năng này.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Mở app settings
                // openAppSettings(); // Cần package permission_handler
              },
              child: Text('Mở cài đặt'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return widget.child;
  }
}
```

## 11. Testing Notification

```dart
// File test_notification.dart
class NotificationTester {
  static Future<void> testAllNotificationTypes() async {
    final notifications = [
      {
        'title': '💬 Tin nhắn mới',
        'body': 'Bạn có tin nhắn mới từ Nguyễn Văn A',
        'route': '/message',
        'data': {'messageId': 'test_msg_1', 'senderId': 'user_123'},
      },
      {
        'title': '📦 Cập nhật đơn hàng',
        'body': 'Đơn hàng #DH001 đã được giao thành công',
        'route': '/order',
        'data': {'orderId': 'DH001', 'status': 'delivered'},
      },
      {
        'title': '🎉 Khuyến mãi hot',
        'body': 'Giảm giá 50% cho tất cả sản phẩm. Nhanh tay!',
        'route': '/promotion',
        'data': {'promotionId': 'SALE50', 'discount': '50'},
      },
      {
        'title': '⚠️ Thông báo khẩn cấp',
        'body': 'Hệ thống sẽ bảo trì trong 30 phút tới',
        'route': '/home',
        'data': {'type': 'urgent', 'maintenanceTime': '30'},
      },
    ];
    
    for (int i = 0; i < notifications.length; i++) {
      await Future.delayed(Duration(seconds: 2));
      await NotificationService().showTestNotification(
        title: notifications[i]['title'] as String,
        body: notifications[i]['body'] as String,
        route: notifications[i]['route'] as String,
        data: notifications[i]['data'] as Map<String, dynamic>,
      );
    }
  }
  
  // Test scheduled notification
  static Future<void> testScheduledNotification() async {
    await NotificationService().scheduleNotification(
      id: 999,
      title: '⏰ Nhắc nhở',
      body: 'Đây là thông báo đã được lên lịch',
      scheduledDate: DateTime.now().add(Duration(seconds: 10)),
      route: '/reminder',
      data: {'reminderId': 'test_reminder'},
    );
  }
  
  // Test repeating notification
  static Future<void> testRepeatingNotification() async {
    await NotificationService().scheduleRepeatingNotification(
      id: 998,
      title: '🔄 Thông báo lặp lại',
      body: 'Đây là thông báo lặp lại hàng ngày',
      repeatInterval: RepeatInterval.daily,
      route: '/daily',
    );
  }
}

// Thêm button test vào HomeScreen
ElevatedButton(
  onPressed: () async {
    await NotificationTester.testAllNotificationTypes();
  },
  child: Text('Test All Notifications'),
),
ElevatedButton(
  onPressed: () async {
    await NotificationTester.testScheduledNotification();
  },
  child: Text('Test Scheduled (10s)'),
),
```

## 12. Troubleshooting & Best Practices

### Common Issues:

1. **Notification không hiện trên iOS**: Kiểm tra certificates và provisioning profiles
2. **Badge count không cập nhật**: Đảm bảo app có quyền badge
3. **Sound không phát**: File sound phải ở định dạng đúng và path chính xác
4. **Deep link không hoạt động**: Kiểm tra URL scheme configuration

### Best Practices:

1. **Luôn xử lý edge cases** khi parse notification data
2. **Implement retry mechanism** cho failed notifications  
3. **Cache notification locally** để offline access
4. **Respect user preferences** về notification settings
5. **Test trên nhiều devices** và OS versions
6. **Monitor notification performance** và delivery rates
7. **Implement proper error handling** và logging
8. **Use appropriate notification channels** cho Android
9. **Optimize notification frequency** để tránh spam
10. **Provide clear opt-out mechanisms** cho users

### Security Considerations:

1. **Validate notification data** trước khi xử lý
2. **Không expose sensitive information** trong notification content
3. **Use proper authentication** cho notification endpoints
4. **Implement rate limiting** để prevent abuse
5. **Log notification events** cho security monitoring