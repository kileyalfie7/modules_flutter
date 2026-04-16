// File: lib/main.dart

import 'package:flutter/material.dart';
import 'permission_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permission Manager Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PermissionDemoScreen(),
    );
  }
}

class PermissionDemoScreen extends StatefulWidget {
  const PermissionDemoScreen({Key? key}) : super(key: key);

  @override
  State<PermissionDemoScreen> createState() => _PermissionDemoScreenState();
}

class _PermissionDemoScreenState extends State<PermissionDemoScreen> {
  /// Danh sách các quyền cần thiết cho app
  final List<PermissionType> _requiredPermissions = [
    PermissionType.camera,
    PermissionType.microphone,
    PermissionType.storage,
    PermissionType.location,
    PermissionType.contacts,
    PermissionType.photos,
    PermissionType.notification,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Manager Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Quản lý quyền truy cập',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ứng dụng này demo cách quản lý quyền truy cập hoàn chỉnh trên iOS và Android.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Widget quản lý quyền chính
            PermissionWidget(
              permissions: _requiredPermissions,
              onAllPermissionsGranted: () {
                _showSuccessSnackBar('Tất cả quyền đã được cấp!');
              },
            ),

            const SizedBox(height: 24),

            // Các nút demo cho từng quyền cụ thể
            const Text(
              'Demo từng quyền cụ thể:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Grid buttons cho các quyền
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: _requiredPermissions.map((type) {
                return _buildPermissionButton(type);
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Nút demo xử lý quyền cao cấp
            const Text(
              'Tính năng nâng cao:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            _buildAdvancedButton(
              'Demo Camera với xử lý hoàn chỉnh',
              Icons.camera_alt,
              () => _demoCameraPermission(),
            ),

            const SizedBox(height: 12),

            _buildAdvancedButton(
              'Demo Location với rationale',
              Icons.location_on,
              () => _demoLocationPermission(),
            ),

            const SizedBox(height: 12),

            _buildAdvancedButton(
              'Kiểm tra tất cả quyền',
              Icons.checklist,
              () => _checkAllPermissions(),
            ),

            const SizedBox(height: 12),

            _buildAdvancedButton(
              'Mở cài đặt app',
              Icons.settings,
              () => PermissionManager.openAppSettings(),
            ),
          ],
        ),
      ),
    );
  }

  /// Tạo button cho từng quyền
  Widget _buildPermissionButton(PermissionType type) {
    return ElevatedButton.icon(
      onPressed: () => _handleSinglePermission(type),
      icon: _getPermissionIcon(type),
      label: Text(
        PermissionManager._getPermissionName(type),
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  /// Tạo button cho tính năng nâng cao
  Widget _buildAdvancedButton(String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  /// Xử lý quyền đơn lẻ
  Future<void> _handleSinglePermission(PermissionType type) async {
    await PermissionManager.handlePermission(
      context,
      type,
      onGranted: () {
        _showSuccessSnackBar('Đã cấp quyền ${PermissionManager._getPermissionName(type)}');
      },
      onDenied: () {
        _showErrorSnackBar('Quyền ${PermissionManager._getPermissionName(type)} bị từ chối');
      },
      rationaleMessage: _getRationaleMessage(type),
    );
  }

  /// Demo xử lý quyền camera hoàn chỉnh
  Future<void> _demoCameraPermission() async {
    // Kiểm tra trạng thái hiện tại
    final result = await PermissionManager.checkPermission(PermissionType.camera);
    
    if (result.status.isGranted) {
      _showSuccessSnackBar('Camera đã sẵn sàng sử dụng!');
      // Ở đây bạn có thể mở camera
      return;
    }

    // Xử lý với dialog tùy chỉnh
    await PermissionManager.handlePermission(
      context,
      PermissionType.camera,
      onGranted: () {
        _showSuccessSnackBar('Camera đã sẵn sàng! Bạn có thể chụp ảnh.');
        // Mở camera ở đây
      },
      onDenied: () {
        _showErrorSnackBar('Không thể sử dụng camera');
      },
      rationaleTitle: 'Cần quyền Camera',
      rationaleMessage: 'Ứng dụng cần quyền truy cập camera để bạn có thể chụp ảnh và quay video. '
          'Quyền này chỉ được sử dụng khi bạn chọn chức năng chụp ảnh.',
    );
  }

  /// Demo xử lý quyền location với rationale
  Future<void> _demoLocationPermission() async {
    await PermissionManager.handlePermission(
      context,
      PermissionType.location,
      onGranted: () {
        _showSuccessSnackBar('Có thể truy cập vị trí của bạn');
        // Lấy vị trí ở đây
      },
      onDenied: () {
        _showErrorSnackBar('Không thể truy cập vị trí');
      },
      rationaleTitle: 'Tại sao cần quyền vị trí?',
      rationaleMessage: 'Ứng dụng sử dụng vị trí của bạn để:\n'
          '• Hiển thị bản đồ xung quanh\n'
          '• Tìm dịch vụ gần bạn\n'
          '• Cung cấp thông tin thời tiết địa phương\n\n'
          'Thông tin vị trí sẽ được bảo mật và chỉ sử dụng trong ứng dụng.',
    );
  }

  /// Kiểm tra tất cả quyền và hiển thị kết quả
  Future<void> _checkAllPermissions() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final results = await PermissionManager.checkMultiplePermissions(_requiredPermissions);
    
    Navigator.of(context).pop(); // Đóng loading

    // Hiển thị kết quả trong dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trạng thái quyền'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return ListTile(
                leading: Icon(
                  result.status.isGranted ? Icons.check_circle : Icons.cancel,
                  color: result.status.isGranted ? Colors.green : Colors.red,
                ),
                title: Text(PermissionManager._getPermissionName(result.type)),
                subtitle: Text(result.message),
                dense: true,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị snackbar thành công
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Hiển thị snackbar lỗi
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Lấy icon cho từng loại quyền
  Icon _getPermissionIcon(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return const Icon(Icons.camera_alt, size: 18);
      case PermissionType.microphone:
        return const Icon(Icons.mic, size: 18);
      case PermissionType.storage:
        return const Icon(Icons.storage, size: 18);
      case PermissionType.location:
        return const Icon(Icons.location_on, size: 18);
      case PermissionType.contacts:
        return const Icon(Icons.contacts, size: 18);
      case PermissionType.photos:
        return const Icon(Icons.photo_library, size: 18);
      case PermissionType.notification:
        return const Icon(Icons.notifications, size: 18);
      default:
        return const Icon(Icons.security, size: 18);
    }
  }

  /// Lấy thông báo giải thích cho từng quyền
  String _getRationaleMessage(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return 'Ứng dụng cần quyền camera để chụp ảnh và quay video.';
      case PermissionType.microphone:
        return 'Ứng dụng cần quyền microphone để ghi âm và thực hiện cuộc gọi.';
      case PermissionType.storage:
        return 'Ứng dụng cần quyền truy cập bộ nhớ để lưu và đọc tệp tin.';
      case PermissionType.location:
        return 'Ứng dụng cần quyền vị trí để cung cấp dịch vụ định vị và bản đồ.';
      case PermissionType.contacts:
        return 'Ứng dụng cần quyền danh bạ để tìm kiếm và kết nối với bạn bè.';
      case PermissionType.photos:
        return 'Ứng dụng cần quyền thư viện ảnh để lưu và chọn hình ảnh.';
      case PermissionType.notification:
        return 'Ứng dụng cần quyền thông báo để gửi thông báo quan trọng đến bạn.';
      default:
        return 'Ứng dụng cần quyền này để hoạt động tốt nhất.';
    }
  }
}