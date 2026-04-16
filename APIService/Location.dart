import 'dart:convert';
import 'package:base_getx/config/router/app_router.dart';
import 'package:base_getx/presentation/face/check_in_controller.dart';
import 'package:base_getx/presentation/face/widgets/face_id_scanning_circle.dart';
import 'package:base_getx/utils/widgets/app_bar.dart';
import 'package:face_checkin_library/face/face_check_in_page.dart';
import 'package:face_checkin_library/model/location/attendance_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Màn hình chấm công bằng nhận diện khuôn mặt với tính năng định vị
class FaceCheckInPage extends StatefulWidget {
  final bool? registerFace; // Có phải đang ở chế độ đăng ký khuôn mặt không
  final String? strListCompany; // Chuỗi JSON chứa danh sách vị trí công ty

  const FaceCheckInPage({super.key, this.registerFace, this.strListCompany});

  @override
  State<FaceCheckInPage> createState() => _FaceCheckInPageState();
}

class _FaceCheckInPageState extends State<FaceCheckInPage> {
  late final CheckInController _controller;

  // === Các biến quản lý vị trí ===
  final currentPosition = Rxn<Position>(); // Vị trí hiện tại
  final addressMap = ''.obs; // Địa chỉ dạng text
  final locations = <AttendanceLocation>[].obs; // Danh sách vị trí công ty
  final isLocationReady = false.obs; // Trạng thái đã sẵn sàng vị trí chưa
  late final MapController _mapController;

  //
  final listCompanyPosition = <AttendanceLocation>[];

  // Cache vị trí để tối ưu hiệu suất
  Position? _cachedPosition;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(CheckInController());
    _mapController = MapController();

    _init();
  }

  /// Khởi tạo ứng dụng - kiểm tra quyền và load vị trí
  void _init() async {
    // Kiểm tra quyền truy cập vị trí
    final granted = await _checkLocationPermission();
    if (!granted) return _showDeniedDialog();

    // Khởi tạo các dịch vụ liên quan đến vị trí
    await _initializeLocation();

    setState(() {});
    fetchAttendanceLocations(widget.strListCompany ?? '');
  }

  Future<void> fetchAttendanceLocations(String strCompany) async {
    locations.value = await loadCompanyLocations(strCompany);
    listCompanyPosition.addAll(locations);
  }

  Future<List<AttendanceLocation>> loadCompanyLocations(String strCompany) async {
    final jsonString = strCompany;
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => AttendanceLocation.fromJson(e)).toList();
  }

  /// Khởi tạo tất cả dịch vụ liên quan đến vị trí
  Future<void> _initializeLocation() async {
    try {
      EasyLoading.show(status: 'Đang lấy vị trí...');

      // Chạy song song 2 tác vụ để tối ưu thời gian:
      // 1. Lấy vị trí GPS chính xác
      // 2. Load danh sách vị trí công ty từ JSON
      final results = await Future.wait([_getAverageLocation(), _loadCompanyLocations()]);

      // Lưu vị trí vào cache và cập nhật UI
      _cachedPosition = results[0] as Position;
      currentPosition.value = _cachedPosition;

      // Chuyển đổi tọa độ thành địa chỉ (chạy nền, không block UI)
      _getAddressFromPosition(_cachedPosition!);

      // Đánh dấu đã sẵn sàng
      isLocationReady.value = true;
    } catch (e) {
      _showErrorDialog('Lỗi khi lấy vị trí: ${e.toString()}');
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Lấy vị trí GPS chính xác bằng cách tính trung bình từ 3 lần đo
  /// Phương pháp này giúp giảm sai số GPS
  Future<Position> _getAverageLocation() async {
    final positions = <Position>[];

    // Lấy GPS 3 lần để tính trung bình
    for (int i = 0; i < 3; i++) {
      try {
        // Sử dụng độ chính xác cao nhất với timeout 10 giây
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
          timeLimit: const Duration(seconds: 10),
        );
        positions.add(position);

        // Nghỉ 300ms giữa các lần đo để GPS ổn định
        if (i < 2) await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        // Nếu GPS độ chính xác cao thất bại, dùng độ chính xác trung bình
        try {
          final fallbackPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 5),
          );
          positions.add(fallbackPosition);
        } catch (fallbackError) {
          print('Lỗi GPS fallback: $fallbackError');
        }
      }
    }

    if (positions.isEmpty) {
      throw Exception('Không thể lấy vị trí GPS');
    }

    // Tính toán vị trí trung bình để giảm sai số
    final lat = positions.map((e) => e.latitude).reduce((a, b) => a + b) / positions.length;
    final lng = positions.map((e) => e.longitude).reduce((a, b) => a + b) / positions.length;
    final accuracy = positions.map((e) => e.accuracy).reduce((a, b) => a + b) / positions.length;

    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: accuracy,
      altitude: positions.first.altitude,
      altitudeAccuracy: positions.first.altitudeAccuracy,
      heading: positions.first.heading,
      speed: positions.first.speed,
      speedAccuracy: positions.first.speedAccuracy,
      headingAccuracy: positions.first.headingAccuracy,
    );
  }

  /// Load danh sách vị trí công ty từ chuỗi JSON
  Future<void> _loadCompanyLocations() async {
    try {
      if (widget.strListCompany?.isNotEmpty == true) {
        // Parse JSON thành danh sách đối tượng AttendanceLocation
        final jsonList = jsonDecode(widget.strListCompany!) as List<dynamic>;
        final companyLocations = jsonList.map((e) => AttendanceLocation.fromJson(e)).toList();

        locations.assignAll(companyLocations);
        print('Đã load ${companyLocations.length} vị trí công ty');
      }
    } catch (e) {
      print('Lỗi khi load danh sách công ty: $e');
    }
  }

  /// Chuyển đổi tọa độ GPS thành địa chỉ có thể đọc được (Reverse Geocoding)
  Future<void> _getAddressFromPosition(Position position) async {
    try {
      // Gọi API reverse geocoding để lấy thông tin địa chỉ
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Ghép các thành phần địa chỉ lại với nhau
        final addressComponents = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((component) => component?.isNotEmpty == true);

        addressMap.value = addressComponents.join(', ');
      }
    } catch (e) {
      print('Lỗi khi lấy địa chỉ: $e');
      addressMap.value = 'Không thể xác định địa chỉ';
    }
  }

  /// Tìm vị trí công ty gần nhất trong bán kính cho phép
  AttendanceLocation? findNearestLocation({double maxDistance = 200.0}) {
    final current = currentPosition.value;
    if (current == null || locations.isEmpty) return null;

    double minDistance = double.infinity;
    AttendanceLocation? nearestLocation;

    // Duyệt qua tất cả vị trí công ty để tìm vị trí gần nhất
    for (final location in locations) {
      // Tính khoảng cách theo đường chim bay (haversine formula)
      final distance = Geolocator.distanceBetween(current.latitude, current.longitude, location.lat, location.long);

      // Chỉ chấp nhận vị trí trong bán kính cho phép
      if (distance < minDistance && distance <= maxDistance) {
        minDistance = distance;
        nearestLocation = location;
      }
    }

    return nearestLocation;
  }

  /// Lấy vị trí hiện tại (ưu tiên dùng cache nếu còn fresh)
  Future<Position> getCurrentPosition({bool forceRefresh = false}) async {
    // Kiểm tra cache có còn mới không (trong vòng 5 phút)
    if (!forceRefresh && _cachedPosition != null) {
      final cacheAge = DateTime.now().difference(_cachedPosition!.timestamp);
      if (cacheAge.inMinutes < 5) {
        print('Sử dụng vị trí từ cache (${cacheAge.inSeconds}s tuổi)');
        return _cachedPosition!;
      }
    }

    print('Làm mới vị trí GPS...');
    // Cache hết hạn hoặc bị force refresh - lấy vị trí mới
    final newPosition = await _getAverageLocation();
    _cachedPosition = newPosition;
    currentPosition.value = newPosition;

    // Cập nhật địa chỉ ở background
    _getAddressFromPosition(newPosition);

    return newPosition;
  }

  /// Kiểm tra có đang ở trong khu vực cho phép chấm công không
  bool isWithinCheckInArea({double maxDistance = 200.0}) {
    return findNearestLocation(maxDistance: maxDistance) != null;
  }

  /// Lấy khoảng cách tới vị trí công ty gần nhất
  double? getDistanceToNearestLocation() {
    final current = currentPosition.value;
    if (current == null || locations.isEmpty) return null;

    double minDistance = double.infinity;

    for (final location in locations) {
      final distance = Geolocator.distanceBetween(current.latitude, current.longitude, location.lat, location.long);

      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance == double.infinity ? null : minDistance;
  }

  /// Kiểm tra quyền truy cập vị trí và dịch vụ GPS
  Future<bool> _checkLocationPermission() async {
    try {
      // Kiểm tra dịch vụ GPS có được bật không
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return false;
      }

      // Kiểm tra quyền truy cập vị trí
      var permission = await Geolocator.checkPermission();

      // Nếu chưa có quyền thì yêu cầu quyền
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Nếu quyền bị từ chối vĩnh viễn
      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedForeverDialog();
        return false;
      }

      // Chấp nhận nếu có quyền luôn luôn hoặc khi sử dụng app
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (e) {
      _showErrorDialog('Lỗi kiểm tra quyền vị trí: ${e.toString()}');
      return false;
    }
  }

  /// Hiển thị dialog thông báo dịch vụ GPS chưa bật
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Dịch vụ vị trí chưa bật'),
        content: const Text('Vui lòng bật dịch vụ GPS trong cài đặt thiết bị để sử dụng tính năng chấm công.'),
        actions: [
          TextButton(onPressed: () => _goBack(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Mở cài đặt GPS của hệ thống
              await Geolocator.openLocationSettings();
            },
            child: const Text('Mở cài đặt'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị dialog khi quyền vị trí bị từ chối vĩnh viễn
  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Quyền vị trí bị từ chối'),
        content: const Text(
          'Bạn đã từ chối quyền vị trí vĩnh viễn. '
          'Vui lòng vào cài đặt ứng dụng và cấp quyền truy cập vị trí.',
        ),
        actions: [
          TextButton(onPressed: () => _goBack(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Mở cài đặt ứng dụng
              await Geolocator.openAppSettings();
            },
            child: const Text('Mở cài đặt'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị dialog từ chối quyền vị trí thông thường
  void _showDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Không có quyền vị trí'),
        content: const Text('Vui lòng cấp quyền truy cập vị trí để sử dụng tính năng chấm công.'),
        actions: [TextButton(onPressed: () => _goBack(), child: const Text('Đóng'))],
      ),
    );
  }

  /// Hiển thị dialog lỗi với thông báo tùy chỉnh
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Đóng'))],
      ),
    );
  }

  /// Quay lại màn hình chính
  void _goBack() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  /// Xử lý khi người dùng bấm nút chấm công/đăng ký
  Future<void> _handleFaceAction() async {
    try {
      // Đảm bảo có vị trí trước khi thực hiện
      final position = await getCurrentPosition();

      if (widget.registerFace == true) {
        // Logic đăng ký khuôn mặt
        print('Bắt đầu đăng ký khuôn mặt tại: ${position.latitude}, ${position.longitude}');
        // Gọi controller để xử lý đăng ký
      } else {
        // Logic chấm công
        print('Bắt đầu chấm công tại: ${position.latitude}, ${position.longitude}');

        // Kiểm tra có trong khu vực chấm công không
        if (!isWithinCheckInArea()) {
          final distance = getDistanceToNearestLocation();
          _showErrorDialog(
            'Bạn đang ở ngoài khu vực chấm công.\n'
            '${distance != null ? "Khoảng cách: ${distance.toStringAsFixed(0)}m" : ""}\n'
            'Vui lòng di chuyển đến gần văn phòng hơn.',
          );
          return;
        }

        // Gọi controller để xử lý chấm công
        EasyLoading.show(maskType: EasyLoadingMaskType.black, dismissOnTap: false);
        // await _controller.checkInFaceId(crop, position, context);
        EasyLoading.dismiss();
      }
    } catch (e) {
      EasyLoading.dismiss();
      _showErrorDialog('Lỗi: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    // Dọn dẹp resources khi widget bị hủy
    currentPosition.close();
    addressMap.close();
    locations.close();
    isLocationReady.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("companyPointscompanyPoints$companyPoints");
    print("_cachedPosition_cachedPosition$_cachedPosition");

    return Scaffold(
      // App bar với nút lịch sử chấm công
      appBar: customAppBar(
        widget.registerFace == true ? 'Đăng ký khuôn mặt' : 'Chấm công',
        actions: [
          InkWell(
            onTap: () => Get.toNamed(Routes.attendanceHistory),
            child: Container(margin: const EdgeInsets.symmetric(horizontal: 16), child: const Icon(Icons.history)),
          ),
        ],
      ),

      body: Obx(() {
        return Column(
          children: [
            // === KHU VỰC NHẬN DIỆN KHUÔN MẶT ===
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: const Center(
                child: FaceIDScanningCircle(strokeWidth: 3, duration: Duration(seconds: 5), enableCamera: true),
              ),
            ),
            // === CARD THÔNG TIN VỊ TRÍ HIỆN TẠI ===
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue.shade700),
                      const Text('Vị trí hiện tại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Địa chỉ
                  Text(
                    addressMap.value.isEmpty ? 'Đang lấy địa chỉ...' : addressMap.value,
                    style: const TextStyle(fontSize: 14),
                  ),

                  // Thông tin chi tiết GPS
                  if (currentPosition.value != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tọa độ: ${currentPosition.value!.latitude.toStringAsFixed(6)}, '
                      '${currentPosition.value!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      'Độ chính xác: ${currentPosition.value!.accuracy.toStringAsFixed(1)}m',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),

            // === CARD TRẠNG THÁI KHU VỰC CHẤM CÔNG ===
            // if (locations.isNotEmpty) ...[
            //   Container(
            //     margin: const EdgeInsets.symmetric(horizontal: 16),
            //     padding: const EdgeInsets.all(16),
            //     decoration: BoxDecoration(
            //       color: isWithinCheckInArea() ? Colors.green.shade50 : Colors.orange.shade50,
            //       borderRadius: BorderRadius.circular(12),
            //       border: Border.all(
            //         color: isWithinCheckInArea() ? Colors.green.shade200 : Colors.orange.shade200,
            //       ),
            //     ),
            //     child: Row(
            //       children: [
            //         // Icon trạng thái
            //         Icon(
            //           isWithinCheckInArea() ? Icons.check_circle : Icons.warning,
            //           color: isWithinCheckInArea() ? Colors.green.shade700 : Colors.orange.shade700,
            //         ),
            //         const SizedBox(width: 8),

            //         // Thông tin trạng thái
            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 isWithinCheckInArea() ? 'Trong khu vực chấm công' : 'Ngoài khu vực chấm công',
            //                 style: TextStyle(
            //                   fontSize: 14,
            //                   fontWeight: FontWeight.bold,
            //                   color: isWithinCheckInArea() ? Colors.green.shade700 : Colors.orange.shade700,
            //                 ),
            //               ),

            //               // Hiển thị khoảng cách
            //               if (getDistanceToNearestLocation() != null) ...[
            //                 Text(
            //                   'Khoảng cách: ${getDistanceToNearestLocation()!.toStringAsFixed(0)}m',
            //                   style: const TextStyle(fontSize: 12),
            //                 ),
            //               ],
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            //   const SizedBox(height: 16),
            // ],
            SizedBox(
              width: 250,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(() {
                  final pos = currentPosition.value;
                  if (pos == null) return const SizedBox.shrink();
                  return _buildMapPreview(pos);
                }),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMapPreview(Position pos) {
    // Danh sách điểm công ty hợp lệ
    final companyPoints = listCompanyPosition.whereType<AttendanceLocation>().toList();

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(pos.latitude, pos.longitude), // Thay 'center' bằng 'initialCenter'
              initialZoom: 15.0, // Thay 'zoom' bằng 'initialZoom'
              minZoom: 8,
              maxZoom: 18, // Tăng maxZoom để có thể zoom gần hơn
              interactionOptions: const InteractionOptions(
                // Thay 'interactiveFlags' bằng 'interactionOptions'
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              // Circle Layer
              CircleLayer(
                circles: [
                  ...companyPoints.map((e) {
                    return CircleMarker(
                      point: LatLng(e.lat, e.long),
                      radius: (e.epsilon ?? 100).toDouble(), // Đảm bảo là double
                      useRadiusInMeter: true,
                      color: Colors.green.withOpacity(0.1),
                      borderStrokeWidth: 2,
                      borderColor: Colors.green,
                    );
                  }),
                ],
              ),

              // Marker Layer
              MarkerLayer(
                markers: [
                  // Vị trí hiện tại
                  Marker(
                    point: LatLng(pos.latitude, pos.longitude),
                    width: 30,
                    height: 30,
                    alignment: Alignment.center, // Căn giữa marker
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.my_location, color: Colors.white, size: 16),
                    ),
                  ),

                  // Các vị trí công ty
                  ...companyPoints.map(
                    (e) => Marker(
                      point: LatLng(e.lat, e.long),
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: const Icon(Icons.business, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Nút refresh
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () {
              _refreshCurrentLocation();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: const Icon(Icons.refresh, size: 18, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  void _refreshCurrentLocation() async {
    try {
      // Logic để refresh vị trí hiện tại
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      currentPosition.value = position;

      // Di chuyển map đến vị trí mới
      _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
    } catch (e) {
      print('Error refreshing location: $e');
    }
  }
}
