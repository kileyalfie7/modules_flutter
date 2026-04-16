// notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

/// Service quản lý push notification
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Callback để xử lý navigation khi nhấn notification
  Function(String route, Map<String, dynamic>? data)? onNotificationTap;
  
  // Callback để cập nhật badge count
  Function(int count)? onBadgeCountUpdate;
  
  int _badgeCount = 0;
  
  /// Khởi tạo notification service
  Future<void> initialize({
    required Function(String route, Map<String, dynamic>? data) onTap,
    Function(int count)? onBadgeUpdate,
  }) async {
    onNotificationTap = onTap;
    onBadgeCountUpdate = onBadgeUpdate;
    
    // Yêu cầu quyền notification
    await _requestPermission();
    
    // Khởi tạo local notifications
    await _initializeLocalNotifications();
    
    // Khởi tạo Firebase messaging
    await _initializeFirebaseMessaging();
    
    // Lấy token FCM
    await _getFCMToken();
  }
  
  /// Yêu cầu quyền notification
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    
    print('Quyền notification: ${settings.authorizationStatus}');
  }
  
  /// Khởi tạo local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  /// Khởi tạo Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Xử lý khi app đang chạy foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Xử lý khi app được mở từ notification (background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Xử lý khi app được mở từ notification khi app đã terminate
    RemoteMessage? initialMessage = 
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }
  
  /// Lấy FCM token
  Future<String?> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Lỗi khi lấy FCM token: $e');
      return null;
    }
  }
  
  /// Xử lý notification khi app đang chạy foreground
  void _handleForegroundMessage(RemoteMessage message) {
    print('Nhận notification khi app đang chạy: ${message.messageId}');
    
    // Tăng badge count
    _increaseBadgeCount();
    
    // Hiển thị local notification
    _showLocalNotification(message);
  }
  
  /// Xử lý khi nhấn vào notification
  void _handleNotificationTap(RemoteMessage message) {
    print('Nhấn vào notification: ${message.messageId}');
    
    // Giảm badge count
    _decreaseBadgeCount();
    
    // Lấy route và data từ notification
    String route = message.data['route'] ?? '/home';
    Map<String, dynamic>? data = message.data.isNotEmpty ? message.data : null;
    
    // Gọi callback navigation
    onNotificationTap?.call(route, data);
  }
  
  /// Xử lý khi nhấn local notification
  void _onNotificationTapped(NotificationResponse response) {
    print('Nhấn vào local notification: ${response.id}');
    
    // Giảm badge count
    _decreaseBadgeCount();
    
    // Parse payload để lấy route và data
    if (response.payload != null) {
      Map<String, dynamic> payload = _parsePayload(response.payload!);
      String route = payload['route'] ?? '/home';
      Map<String, dynamic>? data = payload['data'];
      
      onNotificationTap?.call(route, data);
    }
  }
  
  /// Hiển thị local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Kênh thông báo quan trọng',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Thông báo mới',
      message.notification?.body ?? 'Bạn có thông báo mới',
      platformChannelSpecifics,
      payload: _createPayload(message.data),
    );
  }
  
  /// Tạo payload cho local notification
  String _createPayload(Map<String, dynamic> data) {
    return data.toString(); // Có thể dùng json.encode cho phức tạp hơn
  }
  
  /// Parse payload từ local notification
  Map<String, dynamic> _parsePayload(String payload) {
    // Implement logic parse payload phù hợp với format bạn sử dụng
    return {'route': '/home', 'data': null};
  }
  
  /// Tăng badge count
  void _increaseBadgeCount() {
    _badgeCount++;
    onBadgeCountUpdate?.call(_badgeCount);
  }
  
  /// Giảm badge count
  void _decreaseBadgeCount() {
    if (_badgeCount > 0) {
      _badgeCount--;
      onBadgeCountUpdate?.call(_badgeCount);
    }
  }
  
  /// Đặt lại badge count về 0
  void clearBadgeCount() {
    _badgeCount = 0;
    onBadgeCountUpdate?.call(_badgeCount);
  }
  
  /// Lấy badge count hiện tại
  int get badgeCount => _badgeCount;
  
  /// Gửi notification local (test)
  Future<void> showTestNotification({
    required String title,
    required String body,
    String route = '/home',
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Kênh test thông báo',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    _increaseBadgeCount();
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      platformChannelSpecifics,
      payload: _createPayload({'route': route, 'data': data}),
    );
  }
}

// notification_manager.dart
import 'package:flutter/material.dart';

/// Widget quản lý badge notification trên app icon
class NotificationBadge extends StatefulWidget {
  final Widget child;
  final int count;
  final Color? badgeColor;
  final Color? textColor;
  final double? fontSize;
  
  const NotificationBadge({
    Key? key,
    required this.child,
    required this.count,
    this.badgeColor,
    this.textColor,
    this.fontSize,
  }) : super(key: key);
  
  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.badgeColor ?? Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                widget.count > 99 ? '99+' : '${widget.count}',
                style: TextStyle(
                  color: widget.textColor ?? Colors.white,
                  fontSize: widget.fontSize ?? 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// notification_types.dart
/// Các loại notification khác nhau
enum NotificationType {
  message,    // Tin nhắn
  order,      // Đơn hàng
  promotion,  // Khuyến mãi
  system,     // Hệ thống
  news,       // Tin tức
}

/// Model cho notification data
class NotificationData {
  final String id;
  final String title;
  final String body;
  final String route;
  final Map<String, dynamic>? data;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  
  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.route,
    this.data,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
  
  /// Tạo từ RemoteMessage
  factory NotificationData.fromRemoteMessage(RemoteMessage message) {
    return NotificationData(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Thông báo',
      body: message.notification?.body ?? '',
      route: message.data['route'] ?? '/home',
      data: message.data.isNotEmpty ? message.data : null,
      type: _getNotificationType(message.data['type']),
      timestamp: DateTime.now(),
    );
  }
  
  /// Xác định loại notification từ string
  static NotificationType _getNotificationType(String? typeString) {
    switch (typeString) {
      case 'message':
        return NotificationType.message;
      case 'order':
        return NotificationType.order;
      case 'promotion':
        return NotificationType.promotion;
      case 'system':
        return NotificationType.system;
      case 'news':
        return NotificationType.news;
      default:
        return NotificationType.system;
    }
  }
  
  /// Copy with để tạo bản sao với một số thay đổi
  NotificationData copyWith({
    String? id,
    String? title,
    String? body,
    String? route,
    Map<String, dynamic>? data,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      route: route ?? this.route,
      data: data ?? this.data,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

// main.dart - Ví dụ sử dụng
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int notificationCount = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }
  
  /// Khởi tạo notification service
  Future<void> _initializeNotifications() async {
    await NotificationService().initialize(
      onTap: _handleNotificationNavigation,
      onBadgeUpdate: _updateBadgeCount,
    );
  }
  
  /// Xử lý navigation khi nhấn notification
  void _handleNotificationNavigation(String route, Map<String, dynamic>? data) {
    print('Chuyển đến màně hình: $route với data: $data');
    
    // Navigate đến màn hình tương ứng
    switch (route) {
      case '/message':
        navigatorKey.currentState?.pushNamed('/message', arguments: data);
        break;
      case '/order':
        navigatorKey.currentState?.pushNamed('/order', arguments: data);
        break;
      case '/promotion':
        navigatorKey.currentState?.pushNamed('/promotion', arguments: data);
        break;
      case '/profile':
        navigatorKey.currentState?.pushNamed('/profile', arguments: data);
        break;
      default:
        navigatorKey.currentState?.pushNamed('/home');
    }
  }
  
  /// Cập nhật badge count
  void _updateBadgeCount(int count) {
    setState(() {
      notificationCount = count;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notification Demo',
      navigatorKey: navigatorKey,
      home: HomeScreen(notificationCount: notificationCount),
      routes: {
        '/home': (context) => HomeScreen(notificationCount: notificationCount),
        '/message': (context) => MessageScreen(),
        '/order': (context) => OrderScreen(),
        '/promotion': (context) => PromotionScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}

/// Màn hình chính
class HomeScreen extends StatelessWidget {
  final int notificationCount;
  
  const HomeScreen({Key? key, required this.notificationCount}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Push Notification Demo'),
        actions: [
          // Icon notification với badge
          NotificationBadge(
            count: notificationCount,
            child: IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Xem danh sách notification
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationListScreen(),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Số thông báo chưa đọc: $notificationCount',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Test notification
                await NotificationService().showTestNotification(
                  title: 'Test Notification',
                  body: 'Đây là thông báo test',
                  route: '/message',
                  data: {'messageId': '123', 'senderId': 'user456'},
                );
              },
              child: Text('Gửi Test Notification'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Clear badge
                NotificationService().clearBadgeCount();
              },
              child: Text('Xóa Badge'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Màn hình tin nhắn
class MessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    return Scaffold(
      appBar: AppBar(title: Text('Tin nhắn')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Màn hình tin nhắn'),
            if (data != null) ...[
              SizedBox(height: 20),
              Text('Data từ notification:'),
              Text('Message ID: ${data['messageId']}'),
              Text('Sender ID: ${data['senderId']}'),
            ],
          ],
        ),
      ),
    );
  }
}

/// Màn hình đơn hàng
class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    return Scaffold(
      appBar: AppBar(title: Text('Đơn hàng')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Màn hình đơn hàng'),
            if (data != null) ...[
              SizedBox(height: 20),
              Text('Data từ notification:'),
              Text('Order ID: ${data['orderId']}'),
              Text('Status: ${data['status']}'),
            ],
          ],
        ),
      ),
    );
  }
}

/// Màn hình khuyến mãi
class PromotionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Khuyến mãi')),
      body: Center(child: Text('Màn hình khuyến mãi')),
    );
  }
}

/// Màn hình profile
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hồ sơ')),
      body: Center(child: Text('Màn hình hồ sơ')),
    );
  }
}

/// Màn hình danh sách notification
class NotificationListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: () {
              NotificationService().clearBadgeCount();
              Navigator.pop(context);
            },
            child: Text('Đánh dấu đã đọc', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5, // Demo data
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            title: Text('Thông báo ${index + 1}'),
            subtitle: Text('Nội dung thông báo số ${index + 1}'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Xử lý khi nhấn vào notification trong list
              NotificationService().clearBadgeCount();
            },
          );
        },
      ),
    );
  }
}