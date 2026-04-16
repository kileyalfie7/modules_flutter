import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Enum định nghĩa các loại quyền truy cập
enum PermissionType {
  camera,              // Quyền truy cập camera
  microphone,          // Quyền truy cập microphone
  storage,             // Quyền truy cập bộ nhớ
  location,            // Quyền truy cập vị trí
  contacts,            // Quyền truy cập danh bạ
  photos,              // Quyền truy cập thư viện ảnh
  notification,        // Quyền gửi thông báo
  locationWhenInUse,   // Quyền vị trí khi sử dụng app
  locationAlways,      // Quyền vị trí luôn luôn
}

/// Model chứa kết quả kiểm tra quyền
class PermissionResult {
  final PermissionType type;     // Loại quyền
  final PermissionStatus status; // Trạng thái quyền
  final String message;          // Thông báo mô tả

  PermissionResult({
    required this.type,
    required this.status,
    required this.message,
  });
}

/// Class chính quản lý quyền truy cập
class PermissionManager {
  /// Channel để giao tiếp với native code
  static const MethodChannel _channel = MethodChannel('permission_settings');

  /// Map ánh xạ các loại quyền với thư viện permission_handler
  static final Map<PermissionType, Permission> _permissionMap = {
    PermissionType.camera: Permission.camera,
    PermissionType.microphone: Permission.microphone,
    PermissionType.storage: Permission.storage,
    PermissionType.location: Permission.location,
    PermissionType.contacts: Permission.contacts,
    PermissionType.photos: Permission.photos,
    PermissionType.notification: Permission.notification,
    PermissionType.locationWhenInUse: Permission.locationWhenInUse,
    PermissionType.locationAlways: Permission.locationAlways,
  };

  /// Kiểm tra trạng thái quyền truy cập
  /// 
  /// [type] - Loại quyền cần kiểm tra
  /// Returns: PermissionResult chứa thông tin về quyền
  static Future<PermissionResult> checkPermission(PermissionType type) async {
    try {
      final permission = _permissionMap[type]!;
      final status = await permission.status;
      
      return PermissionResult(
        type: type,
        status: status,
        message: _getStatusMessage(status, type),
      );
    } catch (e) {
      return PermissionResult(
        type: type,
        status: PermissionStatus.denied,
        message: 'Lỗi kiểm tra quyền: $e',
      );
    }
  }

  /// Yêu cầu cấp quyền truy cập
  /// 
  /// [type] - Loại quyền cần yêu cầu
  /// Returns: PermissionResult chứa kết quả yêu cầu
  static Future<PermissionResult> requestPermission(PermissionType type) async {
    try {
      final permission = _permissionMap[type]!;
      final status = await permission.request();
      
      return PermissionResult(
        type: type,
        status: status,
        message: _getStatusMessage(status, type),
      );
    } catch (e) {
      return PermissionResult(
        type: type,
        status: PermissionStatus.denied,
        message: 'Lỗi yêu cầu quyền: $e',
      );
    }
  }

  /// Kiểm tra nhiều quyền cùng một lúc
  /// 
  /// [types] - Danh sách các loại quyền cần kiểm tra
  /// Returns: List<PermissionResult> chứa kết quả của tất cả quyền
  static Future<List<PermissionResult>> checkMultiplePermissions(
      List<PermissionType> types) async {
    List<PermissionResult> results = [];
    
    for (PermissionType type in types) {
      final result = await checkPermission(type);
      results.add(result);
    }
    
    return results;
  }

  /// Yêu cầu nhiều quyền cùng một lúc
  /// 
  /// [types] - Danh sách các loại quyền cần yêu cầu
  /// Returns: List<PermissionResult> chứa kết quả của tất cả quyền
  static Future<List<PermissionResult>> requestMultiplePermissions(
      List<PermissionType> types) async {
    try {
      Map<Permission, PermissionType> permissionTypeMap = {};
      List<Permission> permissions = [];
      
      // Tạo map và list cho việc request
      for (PermissionType type in types) {
        final permission = _permissionMap[type]!;
        permissions.add(permission);
        permissionTypeMap[permission] = type;
      }
      
      // Request tất cả quyền cùng lúc
      Map<Permission, PermissionStatus> statuses = await permissions.request();
      
      // Tạo kết quả từ response
      List<PermissionResult> results = [];
      statuses.forEach((permission, status) {
        final type = permissionTypeMap[permission]!;
        results.add(PermissionResult(
          type: type,
          status: status,
          message: _getStatusMessage(status, type),
        ));
      });
      
      return results;
    } catch (e) {
      return types.map((type) => PermissionResult(
        type: type,
        status: PermissionStatus.denied,
        message: 'Lỗi yêu cầu quyền: $e',
      )).toList();
    }
  }

  /// Mở trang cài đặt của ứng dụng (sử dụng native code)
  /// 
  /// Returns: true nếu mở thành công, false nếu thất bại
  static Future<bool> openAppSettings() async {
    try {
      final result = await _channel.invokeMethod('openAppSettings');
      return result ?? false;
    } catch (e) {
      print('Lỗi mở cài đặt: $e');
      return false;
    }
  }

  /// Kiểm tra xem có nên hiển thị dialog giải thích quyền không
  /// 
  /// [type] - Loại quyền cần kiểm tra
  /// Returns: true nếu nên hiển thị dialog giải thích
  static Future<bool> shouldShowRequestRationale(PermissionType type) async {
    try {
      final permission = _permissionMap[type]!;
      return await permission.shouldShowRequestRationale;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra xem quyền có bị từ chối vĩnh viễn không
  /// 
  /// [type] - Loại quyền cần kiểm tra
  /// Returns: true nếu quyền bị từ chối vĩnh viễn
  static Future<bool> isPermanentlyDenied(PermissionType type) async {
    try {
      final permission = _permissionMap[type]!;
      final status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      return false;
    }
  }

  /// Xử lý logic quyền truy cập hoàn chỉnh với tất cả các trường hợp
  /// 
  /// [context] - BuildContext để hiển thị dialog
  /// [type] - Loại quyền cần xử lý
  /// [onGranted] - Callback khi quyền được cấp
  /// [onDenied] - Callback khi quyền bị từ chối
  /// [rationaleTitle] - Tiêu đề dialog giải thích
  /// [rationaleMessage] - Nội dung dialog giải thích
  static Future<void> handlePermission(
    BuildContext context,
    PermissionType type, {
    VoidCallback? onGranted,
    VoidCallback? onDenied,
    String? rationaleTitle,
    String? rationaleMessage,
  }) async {
    
    // Bước 1: Kiểm tra trạng thái hiện tại
    final currentResult = await checkPermission(type);
    
    // Nếu đã có quyền, gọi callback và return
    if (currentResult.status.isGranted) {
      onGranted?.call();
      return;
    }
    
    // Bước 2: Kiểm tra xem có bị từ chối vĩnh viễn không
    if (currentResult.status.isPermanentlyDenied) {
      await _showPermanentlyDeniedDialog(context, type);
      onDenied?.call();
      return;
    }
    
    // Bước 3: Kiểm tra xem có nên hiển thị dialog giải thích không
    final shouldShowRationale = await shouldShowRequestRationale(type);
    
    if (shouldShowRationale && rationaleMessage != null) {
      // Hiển thị dialog giải thích trước khi request
      final shouldProceed = await _showRationaleDialog(
        context, 
        rationaleTitle ?? 'Cần quyền truy cập',
        rationaleMessage,
      );
      
      if (!shouldProceed) {
        onDenied?.call();
        return;
      }
    }
    
    // Bước 4: Request quyền
    final requestResult = await requestPermission(type);
    
    if (requestResult.status.isGranted) {
      onGranted?.call();
    } else if (requestResult.status.isPermanentlyDenied) {
      await _showPermanentlyDeniedDialog(context, type);
      onDenied?.call();
    } else {
      onDenied?.call();
    }
  }

  /// Hiển thị dialog giải thích tại sao cần quyền
  static Future<bool> _showRationaleDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Hiển thị dialog khi quyền bị từ chối vĩnh viễn
  static Future<void> _showPermanentlyDeniedDialog(
    BuildContext context,
    PermissionType type,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cần cấp quyền'),
          content: Text(
            'Quyền ${_getPermissionName(type)} đã bị từ chối. '
            'Vui lòng vào Cài đặt để cấp quyền cho ứng dụng.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Đi tới Cài đặt'),
            ),
          ],
        );
      },
    );
  }

  /// Lấy thông báo trạng thái dựa trên PermissionStatus
  static String _getStatusMessage(PermissionStatus status, PermissionType type) {
    final permissionName = _getPermissionName(type);
    
    switch (status) {
      case PermissionStatus.granted:
        return 'Đã cấp quyền $permissionName';
      case PermissionStatus.denied:
        return 'Quyền $permissionName bị từ chối';
      case PermissionStatus.restricted:
        return 'Quyền $permissionName bị hạn chế';
      case PermissionStatus.limited:
        return 'Quyền $permissionName bị giới hạn';
      case PermissionStatus.permanentlyDenied:
        return 'Quyền $permissionName bị từ chối vĩnh viễn';
      case PermissionStatus.provisional:
        return 'Quyền $permissionName tạm thời';
      default:
        return 'Trạng thái quyền $permissionName không xác định';
    }
  }

  /// Lấy tên quyền bằng tiếng Việt
  static String _getPermissionName(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return 'Camera';
      case PermissionType.microphone:
        return 'Microphone';
      case PermissionType.storage:
        return 'Bộ nhớ';
      case PermissionType.location:
        return 'Vị trí';
      case PermissionType.contacts:
        return 'Danh bạ';
      case PermissionType.photos:
        return 'Thư viện ảnh';
      case PermissionType.notification:
        return 'Thông báo';
      case PermissionType.locationWhenInUse:
        return 'Vị trí khi sử dụng';
      case PermissionType.locationAlways:
        return 'Vị trí luôn luôn';
      default:
        return 'Không xác định';
    }
  }
}

/// Widget UI để hiển thị và quản lý quyền
class PermissionWidget extends StatefulWidget {
  final List<PermissionType> permissions;
  final VoidCallback? onAllPermissionsGranted;

  const PermissionWidget({
    Key? key,
    required this.permissions,
    this.onAllPermissionsGranted,
  }) : super(key: key);

  @override
  State<PermissionWidget> createState() => _PermissionWidgetState();
}

class _PermissionWidgetState extends State<PermissionWidget> {
  List<PermissionResult> _permissionResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  /// Kiểm tra tất cả quyền
  Future<void> _checkAllPermissions() async {
    setState(() => _isLoading = true);
    
    final results = await PermissionManager.checkMultiplePermissions(widget.permissions);
    
    setState(() {
      _permissionResults = results;
      _isLoading = false;
    });
    
    _checkIfAllGranted();
  }

  /// Yêu cầu tất cả quyền
  Future<void> _requestAllPermissions() async {
    setState(() => _isLoading = true);
    
    final results = await PermissionManager.requestMultiplePermissions(widget.permissions);
    
    setState(() {
      _permissionResults = results;
      _isLoading = false;
    });
    
    _checkIfAllGranted();
  }

  /// Kiểm tra xem tất cả quyền đã được cấp chưa
  void _checkIfAllGranted() {
    final allGranted = _permissionResults.every((result) => result.status.isGranted);
    if (allGranted && widget.onAllPermissionsGranted != null) {
      widget.onAllPermissionsGranted!();
    }
  }

  /// Xử lý yêu cầu quyền cụ thể
  Future<void> _handleSpecificPermission(PermissionType type) async {
    await PermissionManager.handlePermission(
      context,
      type,
      onGranted: () {
        _checkAllPermissions();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cấp quyền ${PermissionManager._getPermissionName(type)}')),
        );
      },
      onDenied: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quyền ${PermissionManager._getPermissionName(type)} bị từ chối')),
        );
      },
      rationaleMessage: 'Ứng dụng cần quyền ${PermissionManager._getPermissionName(type)} để hoạt động tốt nhất.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quyền truy cập ứng dụng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // Hiển thị danh sách quyền
              ..._permissionResults.map((result) => _buildPermissionTile(result)),
              
              const SizedBox(height: 16),
              
              // Nút hành động
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _requestAllPermissions,
                      child: const Text('Yêu cầu tất cả quyền'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _checkAllPermissions,
                      child: const Text('Kiểm tra lại'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Nút mở cài đặt
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => PermissionManager.openAppSettings(),
                  icon: const Icon(Icons.settings),
                  label: const Text('Mở cài đặt ứng dụng'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Tạo tile cho từng quyền
  Widget _buildPermissionTile(PermissionResult result) {
    IconData icon;
    Color color;
    
    // Xác định icon và màu dựa trên trạng thái
    switch (result.status) {
      case PermissionStatus.granted:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }
    
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(PermissionManager._getPermissionName(result.type)),
      subtitle: Text(result.message),
      trailing: result.status.isDenied || result.status.isPermanentlyDenied
          ? TextButton(
              onPressed: () => _handleSpecificPermission(result.type),
              child: const Text('Cấp quyền'),
            )
          : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}