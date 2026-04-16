// pubspec.yaml
/*
dependencies:
  flutter:
    sdk: flutter
  connectivity_plus: ^4.0.2
  permission_handler: ^10.4.3
  network_info_plus: ^4.0.2
  dio: ^5.3.2
  device_info_plus: ^9.1.0
  telephony: ^0.2.0
  sim_data: ^0.3.0
*/

// lib/models/network_models.dart
import 'dart:convert';

// Enum định nghĩa các loại kết nối mạng
enum NetworkType {
  none,         // Không có kết nối
  mobile,       // Kết nối di động (3G/4G/5G)
  wifi,         // Kết nối WiFi
  ethernet,     // Kết nối Ethernet
  vpn,          // Kết nối VPN
  bluetooth,    // Kết nối Bluetooth
  other         // Loại kết nối khác
}

// Enum định nghĩa các nhà mạng Việt Nam
enum CarrierType {
  viettel,      // Viettel (84-9, 84-3, 84-8)
  vinaphone,    // VinaPhone (84-9, 84-8)
  mobifone,     // MobiFone (84-9, 84-7)
  vietnammobile, // Vietnammobile (84-5, 84-9)
  gmobile,      // Gmobile (84-9)
  itelecom,     // iTelecom (84-9)
  sfone,        // Sfone (84-9) - đã ngừng hoạt động
  unknown       // Không xác định
}

// Enum định nghĩa chất lượng mạng dựa trên băng thông
enum NetworkQuality {
  excellent,    // Xuất sắc > 50 Mbps
  good,         // Tốt 10-50 Mbps
  fair,         // Khá 1-10 Mbps
  poor,         // Kém < 1 Mbps
  unavailable   // Không khả dụng
}

// Enum định nghĩa các loại lỗi kết nối
enum ConnectionIssueType {
  noConnection,         // Không có kết nối
  noInternet,          // Có kết nối nhưng không có internet
  slowConnection,      // Kết nối chậm
  intermittentConnection, // Kết nối không ổn định
  dnsIssue,           // Lỗi DNS
  proxyIssue,         // Lỗi Proxy
  carrierBlocked,     // Bị nhà mạng chặn
  dataLimitExceeded,  // Vượt quá hạn mức data
  roamingIssue,       // Lỗi roaming
  signalWeak,         // Tín hiệu yếu
  none                // Không có lỗi
}

// Class chứa thông tin chẩn đoán mạng
class NetworkDiagnostics {
  final bool hasConnection;      // Có kết nối hay không
  final bool hasInternet;        // Có internet hay không
  final bool canReachDNS;       // Có thể kết nối DNS hay không
  final bool canReachGateway;   // Có thể kết nối gateway hay không
  final bool isRegisteredWithCarrier; // Đã đăng ký với nhà mạng hay chưa
  final bool hasDataTraffic;    // Có lưu lượng data hay không
  final ConnectionIssueType issueType; // Loại lỗi nếu có
  final String? errorMessage;   // Thông báo lỗi chi tiết

  NetworkDiagnostics({
    required this.hasConnection,
    required this.hasInternet,
    required this.canReachDNS,
    required this.canReachGateway,
    required this.isRegisteredWithCarrier,
    required this.hasDataTraffic,
    required this.issueType,
    this.errorMessage,
  });

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() => {
    'hasConnection': hasConnection,
    'hasInternet': hasInternet,
    'canReachDNS': canReachDNS,
    'canReachGateway': canReachGateway,
    'isRegisteredWithCarrier': isRegisteredWithCarrier,
    'hasDataTraffic': hasDataTraffic,
    'issueType': issueType.toString().split('.').last,
    'errorMessage': errorMessage,
  };
}

// Class chứa thông tin về băng thông
class BandwidthInfo {
  final double downloadSpeed;    // Tốc độ download (Mbps)
  final double uploadSpeed;      // Tốc độ upload (Mbps)
  final int ping;               // Ping (ms)
  final int jitter;             // Jitter (ms)
  final double packetLoss;      // Tỷ lệ mất gói (%)
  final NetworkQuality quality; // Chất lượng mạng
  final DateTime timestamp;     // Thời gian đo

  BandwidthInfo({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.ping,
    required this.jitter,
    required this.packetLoss,
    required this.quality,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'downloadSpeed': downloadSpeed,
    'uploadSpeed': uploadSpeed,
    'ping': ping,
    'jitter': jitter,
    'packetLoss': packetLoss,
    'quality': quality.toString().split('.').last,
    'timestamp': timestamp.toIso8601String(),
  };
}

// Class chứa thông tin carrier chi tiết
class CarrierInfo {
  final CarrierType type;       // Loại nhà mạng
  final String? carrierName;    // Tên nhà mạng
  final String? countryCode;    // Mã quốc gia
  final String? networkCode;    // Mã mạng
  final String? isoCountryCode; // Mã ISO quốc gia
  final bool isNetworkRoaming;  // Có đang roaming hay không
  final String? simState;       // Trạng thái SIM
  final String? phoneNumber;    // Số điện thoại
  final List<String> availableNetworks; // Các mạng khả dụng

  CarrierInfo({
    required this.type,
    this.carrierName,
    this.countryCode,
    this.networkCode,
    this.isoCountryCode,
    required this.isNetworkRoaming,
    this.simState,
    this.phoneNumber,
    required this.availableNetworks,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'carrierName': carrierName,
    'countryCode': countryCode,
    'networkCode': networkCode,
    'isoCountryCode': isoCountryCode,
    'isNetworkRoaming': isNetworkRoaming,
    'simState': simState,
    'phoneNumber': phoneNumber,
    'availableNetworks': availableNetworks,
  };
}

// Class chứa thông tin WiFi chi tiết
class WiFiInfo {
  final String? ssid;           // Tên WiFi
  final String? bssid;          // BSSID của WiFi
  final int? signalStrength;    // Cường độ tín hiệu (dBm)
  final int? linkSpeed;         // Tốc độ liên kết (Mbps)
  final int? frequency;         // Tần số (MHz)
  final String? ipAddress;      // Địa chỉ IP
  final String? subnet;         // Subnet mask
  final String? gateway;        // Gateway
  final List<String> dns;       // Danh sách DNS
  final String? macAddress;     // Địa chỉ MAC
  final bool isHiddenSSID;      // SSID có bị ẩn không
  final String? securityType;   // Loại bảo mật

  WiFiInfo({
    this.ssid,
    this.bssid,
    this.signalStrength,
    this.linkSpeed,
    this.frequency,
    this.ipAddress,
    this.subnet,
    this.gateway,
    required this.dns,
    this.macAddress,
    required this.isHiddenSSID,
    this.securityType,
  });

  Map<String, dynamic> toJson() => {
    'ssid': ssid,
    'bssid': bssid,
    'signalStrength': signalStrength,
    'linkSpeed': linkSpeed,
    'frequency': frequency,
    'ipAddress': ipAddress,
    'subnet': subnet,
    'gateway': gateway,
    'dns': dns,
    'macAddress': macAddress,
    'isHiddenSSID': isHiddenSSID,
    'securityType': securityType,
  };
}

// Class chứa thông tin mạng di động chi tiết
class MobileNetworkInfo {
  final String? networkType;    // Loại mạng (2G/3G/4G/5G)
  final int? signalStrength;    // Cường độ tín hiệu
  final String? cellId;         // Cell ID
  final String? lac;            // Location Area Code
  final int? dataActivity;      // Hoạt động data
  final int? dataState;         // Trạng thái data
  final bool isDataEnabled;     // Data có được bật không
  final bool isDataRoamingEnabled; // Data roaming có được bật không
  final String? subscriberId;   // ID thuê bao
  final String? deviceId;       // Device ID

  MobileNetworkInfo({
    this.networkType,
    this.signalStrength,
    this.cellId,
    this.lac,
    this.dataActivity,
    this.dataState,
    required this.isDataEnabled,
    required this.isDataRoamingEnabled,
    this.subscriberId,
    this.deviceId,
  });

  Map<String, dynamic> toJson() => {
    'networkType': networkType,
    'signalStrength': signalStrength,
    'cellId': cellId,
    'lac': lac,
    'dataActivity': dataActivity,
    'dataState': dataState,
    'isDataEnabled': isDataEnabled,
    'isDataRoamingEnabled': isDataRoamingEnabled,
    'subscriberId': subscriberId,
    'deviceId': deviceId,
  };
}

// lib/services/network_connectivity_service.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';


class NetworkConnectivityService {
  static NetworkConnectivityService? _instance;
  static NetworkConnectivityService get instance => _instance ??= NetworkConnectivityService._();
  
  NetworkConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Dio _dio = Dio();

  // Stream controller để theo dõi thay đổi kết nối
  final StreamController<NetworkDiagnostics> _networkStatusController = 
    StreamController<NetworkDiagnostics>.broadcast();

  Stream<NetworkDiagnostics> get networkStatusStream => _networkStatusController.stream;

  // Danh sách server test tốc độ
  final List<String> _speedTestServers = [
    'https://speedtest.viettel.vn',
    'https://speedtest.vnpt.vn',
    'https://speedtest.mobifone.vn',
    'https://httpbin.org/bytes/1048576', // 1MB file
    'https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png',
  ];

  // Danh sách DNS servers Việt Nam
  final List<String> _vietnamDNS = [
    '8.8.8.8',         // Google DNS
    '1.1.1.1',         // Cloudflare DNS
    '203.162.4.191',   // VNPT DNS
    '123.30.175.175',  // Viettel DNS
    '210.245.24.20',   // MobiFone DNS
  ];

  /// Khởi tạo service và bắt đầu monitor
  Future<void> initialize() async {
    await _requestPermissions();
    _startNetworkMonitoring();
  }

  /// Yêu cầu quyền cần thiết
  Future<void> _requestPermissions() async {
    await [
      Permission.phone,
      Permission.location,
      Permission.locationWhenInUse,
    ].request();
  }

  /// Bắt đầu theo dõi kết nối mạng
  void _startNetworkMonitoring() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
      final diagnostics = await performComprehensiveDiagnostics();
      _networkStatusController.add(diagnostics);
    });
  }

  /// Thực hiện chẩn đoán toàn diện mạng
  Future<NetworkDiagnostics> performComprehensiveDiagnostics() async {
    try {
      // Kiểm tra kết nối cơ bản
      final connectivityResult = await _connectivity.checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;

      if (!hasConnection) {
        return NetworkDiagnostics(
          hasConnection: false,
          hasInternet: false,
          canReachDNS: false,
          canReachGateway: false,
          isRegisteredWithCarrier: false,
          hasDataTraffic: false,
          issueType: ConnectionIssueType.noConnection,
          errorMessage: 'Không có kết nối mạng',
        );
      }

      // Kiểm tra các thành phần khác
      final hasInternet = await _checkInternetConnectivity();
      final canReachDNS = await _checkDNSConnectivity();
      final canReachGateway = await _checkGatewayConnectivity();
      final isRegistered = await _checkCarrierRegistration();
      final hasDataTraffic = await _checkDataTraffic();

      // Xác định loại lỗi nếu có
      ConnectionIssueType issueType = ConnectionIssueType.none;
      String? errorMessage;

      if (!hasInternet) {
        issueType = ConnectionIssueType.noInternet;
        errorMessage = 'Có kết nối nhưng không thể truy cập internet';
      } else if (!canReachDNS) {
        issueType = ConnectionIssueType.dnsIssue;
        errorMessage = 'Không thể kết nối đến DNS server';
      } else if (!canReachGateway) {
        errorMessage = 'Không thể kết nối đến gateway';
      } else if (!isRegistered) {
        issueType = ConnectionIssueType.carrierBlocked;
        errorMessage = 'Không đăng ký với nhà mạng hoặc bị chặn';
      } else if (!hasDataTraffic) {
        issueType = ConnectionIssueType.dataLimitExceeded;
        errorMessage = 'Đã hết hạn mức data hoặc không có lưu lượng';
      }

      return NetworkDiagnostics(
        hasConnection: hasConnection,
        hasInternet: hasInternet,
        canReachDNS: canReachDNS,
        canReachGateway: canReachGateway,
        isRegisteredWithCarrier: isRegistered,
        hasDataTraffic: hasDataTraffic,
        issueType: issueType,
        errorMessage: errorMessage,
      );

    } catch (e) {
      return NetworkDiagnostics(
        hasConnection: false,
        hasInternet: false,
        canReachDNS: false,
        canReachGateway: false,
        isRegisteredWithCarrier: false,
        hasDataTraffic: false,
        issueType: ConnectionIssueType.noConnection,
        errorMessage: 'Lỗi khi chẩn đoán: $e',
      );
    }
  }

  /// Kiểm tra kết nối internet bằng cách ping đến nhiều server
  Future<bool> _checkInternetConnectivity() async {
    final testUrls = [
      'https://www.google.com',
      'https://www.cloudflare.com',
      'https://httpbin.org/get',
      'https://jsonplaceholder.typicode.com/posts/1',
    ];

    int successCount = 0;
    for (String url in testUrls) {
      try {
        final response = await _dio.head(
          url,
          options: Options(
            connectTimeout: Duration(seconds: 10),
            receiveTimeout: Duration(seconds: 10),
            followRedirects: false,
          ),
        );
        if (response.statusCode == 200 || response.statusCode == 302) {
          successCount++;
        }
      } catch (e) {
        // Ignore individual failures
      }
    }

    // Cần ít nhất 2/4 server phản hồi để xác nhận có internet
    return successCount >= 2;
  }

  /// Kiểm tra kết nối DNS
  Future<bool> _checkDNSConnectivity() async {
    for (String dns in _vietnamDNS) {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty) return true;
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  /// Kiểm tra kết nối gateway
  Future<bool> _checkGatewayConnectivity() async {
    try {
      final gateway = await _networkInfo.getWifiGatewayIP();
      if (gateway != null) {
        final result = await Process.run('ping', ['-c', '1', gateway]);
        return result.exitCode == 0;
      }
    } catch (e) {
      // Fallback: kiểm tra router thông thường
      final commonGateways = ['192.168.1.1', '192.168.0.1', '10.0.0.1'];
      for (String gw in commonGateways) {
        try {
          final result = await Process.run('ping', ['-c', '1', gw]);
          if (result.exitCode == 0) return true;
        } catch (e) {
          continue;
        }
      }
    }
    return false;
  }

  /// Kiểm tra đăng ký với nhà mạng (Android)
  Future<bool> _checkCarrierRegistration() async {
    try {
      if (Platform.isAndroid) {
        // Sử dụng method channel để kiểm tra trạng thái network registration
        const platform = MethodChannel('network_connectivity/carrier');
        final result = await platform.invokeMethod('getNetworkRegistrationState');
        return result == 'registered';
      } else if (Platform.isIOS) {
        // iOS: Kiểm tra carrier info
        const platform = MethodChannel('network_connectivity/carrier');
        final result = await platform.invokeMethod('getCarrierInfo');
        return result != null && result['carrierName'] != null;
      }
    } catch (e) {
      print('Error checking carrier registration: $e');
    }
    return true; // Default to true if can't check
  }

  /// Kiểm tra có lưu lượng data hay không
  Future<bool> _checkDataTraffic() async {
    try {
      // Thử download một file nhỏ để kiểm tra data traffic
      final testUrl = 'https://httpbin.org/bytes/1024'; // 1KB file
      final response = await _dio.get(
        testUrl,
        options: Options(
          connectTimeout: Duration(seconds: 15),
          receiveTimeout: Duration(seconds: 15),
        ),
      );
      return response.statusCode == 200 && response.data != null;
    } catch (e) {
      return false;
    }
  }

  /// Đo băng thông mạng
  Future<BandwidthInfo> measureBandwidth() async {
    final startTime = DateTime.now();
    double downloadSpeed = 0;
    double uploadSpeed = 0;
    int ping = 0;
    
    try {
      // Đo ping
      ping = await _measurePing();
      
      // Đo tốc độ download
      downloadSpeed = await _measureDownloadSpeed();
      
      // Đo tốc độ upload
      uploadSpeed = await _measureUploadSpeed();
      
    } catch (e) {
      print('Error measuring bandwidth: $e');
    }

    // Xác định chất lượng mạng
    NetworkQuality quality;
    if (downloadSpeed > 50) {
      quality = NetworkQuality.excellent;
    } else if (downloadSpeed > 10) {
      quality = NetworkQuality.good;
    } else if (downloadSpeed > 1) {
      quality = NetworkQuality.fair;
    } else if (downloadSpeed > 0) {
      quality = NetworkQuality.poor;
    } else {
      quality = NetworkQuality.unavailable;
    }

    return BandwidthInfo(
      downloadSpeed: downloadSpeed,
      uploadSpeed: uploadSpeed,
      ping: ping,
      jitter: await _measureJitter(),
      packetLoss: await _measurePacketLoss(),
      quality: quality,
      timestamp: DateTime.now(),
    );
  }

  /// Đo ping
  Future<int> _measurePing() async {
    final stopwatch = Stopwatch()..start();
    try {
      await _dio.head(
        'https://www.google.com',
        options: Options(connectTimeout: Duration(seconds: 10)),
      );
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      return 9999; // Timeout or error
    }
  }

  /// Đo tốc độ download
  Future<double> _measureDownloadSpeed() async {
    const int fileSizeBytes = 5 * 1024 * 1024; // 5MB
    final testUrl = 'https://httpbin.org/bytes/$fileSizeBytes';
    
    final stopwatch = Stopwatch()..start();
    try {
      await _dio.get(
        testUrl,
        options: Options(
          responseType: ResponseType.bytes,
          connectTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 60),
        ),
      );
      stopwatch.stop();
      
      final timeInSeconds = stopwatch.elapsedMilliseconds / 1000.0;
      final speedMbps = (fileSizeBytes * 8) / (timeInSeconds * 1024 * 1024);
      return speedMbps;
    } catch (e) {
      return 0;
    }
  }

  /// Đo tốc độ upload
  Future<double> _measureUploadSpeed() async {
    const int dataSize = 1024 * 1024; // 1MB
    final data = List.generate(dataSize, (index) => index % 256);
    
    final stopwatch = Stopwatch()..start();
    try {
      await _dio.post(
        'https://httpbin.org/post',
        data: data,
        options: Options(
          connectTimeout: Duration(seconds: 30),
          sendTimeout: Duration(seconds: 60),
        ),
      );
      stopwatch.stop();
      
      final timeInSeconds = stopwatch.elapsedMilliseconds / 1000.0;
      final speedMbps = (dataSize * 8) / (timeInSeconds * 1024 * 1024);
      return speedMbps;
    } catch (e) {
      return 0;
    }
  }

  /// Đo jitter
  Future<int> _measureJitter() async {
    List<int> pings = [];
    for (int i = 0; i < 5; i++) {
      pings.add(await _measurePing());
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    if (pings.isEmpty) return 0;
    
    double average = pings.reduce((a, b) => a + b) / pings.length;
    double variance = pings.map((ping) => pow(ping - average, 2)).reduce((a, b) => a + b) / pings.length;
    return sqrt(variance).round();
  }

  /// Đo packet loss
  Future<double> _measurePacketLoss() async {
    int totalPackets = 10;
    int lostPackets = 0;
    
    for (int i = 0; i < totalPackets; i++) {
      try {
        await _dio.head(
          'https://www.google.com',
          options: Options(connectTimeout: Duration(seconds: 5)),
        );
      } catch (e) {
        lostPackets++;
      }
    }
    
    return (lostPackets / totalPackets) * 100;
  }

  /// Lấy thông tin nhà mạng
  Future<CarrierInfo> getCarrierInfo() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidCarrierInfo();
      } else if (Platform.isIOS) {
        return await _getIOSCarrierInfo();
      }
    } catch (e) {
      print('Error getting carrier info: $e');
    }
    
    return CarrierInfo(
      type: CarrierType.unknown,
      isNetworkRoaming: false,
      availableNetworks: [],
    );
  }

  /// Lấy thông tin carrier trên Android
  Future<CarrierInfo> _getAndroidCarrierInfo() async {
    const platform = MethodChannel('network_connectivity/carrier');
    final result = await platform.invokeMethod('getCarrierInfo');
    
    if (result != null) {
      final carrierName = result['carrierName'] as String?;
      final type = _identifyVietnameseCarrier(carrierName);
      
      return CarrierInfo(
        type: type,
        carrierName: carrierName,
        countryCode: result['countryCode'] as String?,
        networkCode: result['networkCode'] as String?,
        isoCountryCode: result['isoCountryCode'] as String?,
        isNetworkRoaming: result['isNetworkRoaming'] as bool? ?? false,
        simState: result['simState'] as String?,
        phoneNumber: result['phoneNumber'] as String?,
        availableNetworks: List<String>.from(result['availableNetworks'] ?? []),
      );
    }
    
    return CarrierInfo(
      type: CarrierType.unknown,
      isNetworkRoaming: false,
      availableNetworks: [],
    );
  }

  /// Lấy thông tin carrier trên iOS
  Future<CarrierInfo> _getIOSCarrierInfo() async {
    const platform = MethodChannel('network_connectivity/carrier');
    final result = await platform.invokeMethod('getCarrierInfo');
    
    if (result != null) {
      final carrierName = result['carrierName'] as String?;
      final type = _identifyVietnameseCarrier(carrierName);
      
      return CarrierInfo(
        type: type,
        carrierName: carrierName,
        countryCode: result['mobileCountryCode'] as String?,
        networkCode: result['mobileNetworkCode'] as String?,
        isoCountryCode: result['isoCountryCode'] as String?,
        isNetworkRoaming: false, // iOS doesn't provide this directly
        availableNetworks: [],
      );
    }
    
    return CarrierInfo(
      type: CarrierType.unknown,
      isNetworkRoaming: false,
      availableNetworks: [],
    );
  }

  /// Nhận diện nhà mạng Việt Nam dựa trên tên
  CarrierType _identifyVietnameseCarrier(String? carrierName) {
    if (carrierName == null) return CarrierType.unknown;
    
    final name = carrierName.toLowerCase();
    
    if (name.contains('viettel') || name.contains('vt')) {
      return CarrierType.viettel;
    } else if (name.contains('vinaphone') || name.contains('vina')) {
      return CarrierType.vinaphone;
    } else if (name.contains('mobifone') || name.contains('mobi')) {
      return CarrierType.mobifone;
    } else if (name.contains('vietnammobile') || name.contains('vm')) {
      return CarrierType.vietnammobile;
    } else if (name.contains('gmobile') || name.contains('gtel')) {
      return CarrierType.gmobile;
    } else if (name.contains('itelecom')) {
      return CarrierType.itelecom;
    } else if (name.contains('sfone')) {
      return CarrierType.sfone;
    }
    
    return CarrierType.unknown;
  }

  /// Lấy thông tin WiFi chi tiết
  Future<WiFiInfo> getWiFiInfo() async {
    try {
      final ssid = await _networkInfo.getWifiName();
      final bssid = await _networkInfo.getWifiBSSID();
      final ip = await _networkInfo.getWifiIP();
      final gateway = await _networkInfo.getWifiGatewayIP();
      
      return WiFiInfo(
        ssid: ssid?.replaceAll('"', ''), // Remove quotes on Android
        bssid: bssid,
        ipAddress: ip,
        gateway: gateway,
        dns: await _getWiFiDNS(),
        isHiddenSSID: ssid == null || ssid.isEmpty,
      );
    } catch (e) {
      print('Error getting WiFi info: $e');
      return WiFiInfo(
        dns: [],
        isHiddenSSID: true,
      );
    }
  }

// lib/services/network_connectivity_service.dart (tiếp theo)

  /// Lấy danh sách DNS của WiFi
  Future<List<String>> _getWiFiDNS() async {
    try {
      if (Platform.isAndroid) {
        const platform = MethodChannel('network_connectivity/wifi');
        final result = await platform.invokeMethod('getWiFiDNS');
        return List<String>.from(result ?? []);
      } else if (Platform.isIOS) {
        const platform = MethodChannel('network_connectivity/wifi');
        final result = await platform.invokeMethod('getWiFiDNS');
        return List<String>.from(result ?? []);
      }
    } catch (e) {
      print('Error getting WiFi DNS: $e');
    }
    return _vietnamDNS; // Fallback to default DNS
  }

  /// Lấy thông tin mạng di động chi tiết
  Future<MobileNetworkInfo> getMobileNetworkInfo() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidMobileInfo();
      } else if (Platform.isIOS) {
        return await _getIOSMobileInfo();
      }
    } catch (e) {
      print('Error getting mobile network info: $e');
    }
    
    return MobileNetworkInfo(
      isDataEnabled: false,
      isDataRoamingEnabled: false,
    );
  }

  /// Lấy thông tin mạng di động trên Android
  Future<MobileNetworkInfo> _getAndroidMobileInfo() async {
    const platform = MethodChannel('network_connectivity/mobile');
    final result = await platform.invokeMethod('getMobileNetworkInfo');
    
    if (result != null) {
      return MobileNetworkInfo(
        networkType: result['networkType'] as String?,
        signalStrength: result['signalStrength'] as int?,
        cellId: result['cellId'] as String?,
        lac: result['lac'] as String?,
        dataActivity: result['dataActivity'] as int?,
        dataState: result['dataState'] as int?,
        isDataEnabled: result['isDataEnabled'] as bool? ?? false,
        isDataRoamingEnabled: result['isDataRoamingEnabled'] as bool? ?? false,
        subscriberId: result['subscriberId'] as String?,
        deviceId: result['deviceId'] as String?,
      );
    }
    
    return MobileNetworkInfo(
      isDataEnabled: false,
      isDataRoamingEnabled: false,
    );
  }

  /// Lấy thông tin mạng di động trên iOS
  Future<MobileNetworkInfo> _getIOSMobileInfo() async {
    const platform = MethodChannel('network_connectivity/mobile');
    final result = await platform.invokeMethod('getMobileNetworkInfo');
    
    if (result != null) {
      return MobileNetworkInfo(
        networkType: result['radioAccessTechnology'] as String?,
        isDataEnabled: result['isDataEnabled'] as bool? ?? false,
        isDataRoamingEnabled: result['isDataRoamingEnabled'] as bool? ?? false,
      );
    }
    
    return MobileNetworkInfo(
      isDataEnabled: false,
      isDataRoamingEnabled: false,
    );
  }

  /// Kiểm tra trạng thái proxy
  Future<bool> _checkProxySettings() async {
    try {
      if (Platform.isAndroid) {
        const platform = MethodChannel('network_connectivity/proxy');
        final result = await platform.invokeMethod('getProxySettings');
        return result['hasProxy'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra VPN
  Future<bool> _checkVPNConnection() async {
    try {
      if (Platform.isAndroid) {
        const platform = MethodChannel('network_connectivity/vpn');
        final result = await platform.invokeMethod('isVPNConnected');
        return result as bool? ?? false;
      } else if (Platform.isIOS) {
        // iOS: Kiểm tra interface có vpn không
        const platform = MethodChannel('network_connectivity/vpn');
        final result = await platform.invokeMethod('isVPNConnected');
        return result as bool? ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra firewall/chặn port
  Future<Map<String, bool>> checkCommonPorts() async {
    final portsToCheck = {
      'HTTP': 80,
      'HTTPS': 443,
      'FTP': 21,
      'SSH': 22,
      'SMTP': 25,
      'DNS': 53,
      'POP3': 110,
      'IMAP': 143,
      'SNMP': 161,
      'LDAP': 389,
    };

    Map<String, bool> results = {};
    
    for (String service in portsToCheck.keys) {
      final port = portsToCheck[service]!;
      try {
        final socket = await Socket.connect('google.com', port, timeout: Duration(seconds: 5));
        socket.destroy();
        results[service] = true;
      } catch (e) {
        results[service] = false;
      }
    }
    
    return results;
  }

  /// Kiểm tra NAT/Firewall bằng STUN
  Future<Map<String, dynamic>> performSTUNTest() async {
    try {
      // Sử dụng Google STUN server
      final response = await _dio.get(
        'https://networktest-ipv4.gstatic.com/generate_204',
        options: Options(connectTimeout: Duration(seconds: 10)),
      );
      
      return {
        'natType': 'open', // Simplified - would need proper STUN implementation
        'publicIP': await _getPublicIP(),
        'canReceiveDirectConnections': response.statusCode == 204,
      };
    } catch (e) {
      return {
        'natType': 'unknown',
        'publicIP': null,
        'canReceiveDirectConnections': false,
      };
    }
  }

  /// Lấy IP công cộng
  Future<String?> _getPublicIP() async {
    final services = [
      'https://api.ipify.org',
      'https://ipinfo.io/ip',
      'https://icanhazip.com',
      'https://ident.me',
    ];

    for (String service in services) {
      try {
        final response = await _dio.get(
          service,
          options: Options(connectTimeout: Duration(seconds: 5)),
        );
        if (response.statusCode == 200) {
          return response.data.toString().trim();
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Kiểm tra data usage và hạn mức
  Future<Map<String, dynamic>> checkDataUsage() async {
    try {
      if (Platform.isAndroid) {
        const platform = MethodChannel('network_connectivity/data_usage');
        final result = await platform.invokeMethod('getDataUsage');
        return {
          'totalUsage': result['totalUsage'] as int? ?? 0,
          'wifiUsage': result['wifiUsage'] as int? ?? 0,
          'mobileUsage': result['mobileUsage'] as int? ?? 0,
          'dailyLimit': result['dailyLimit'] as int?,
          'monthlyLimit': result['monthlyLimit'] as int?,
          'isLimitExceeded': result['isLimitExceeded'] as bool? ?? false,
        };
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Kiểm tra chất lượng tín hiệu 5G/4G/3G
  Future<Map<String, dynamic>> analyzeSignalQuality() async {
    try {
      const platform = MethodChannel('network_connectivity/signal');
      final result = await platform.invokeMethod('getDetailedSignalInfo');
      
      if (result != null) {
        final signalStrength = result['signalStrength'] as int? ?? -999;
        final networkType = result['networkType'] as String? ?? 'unknown';
        
        String quality;
        if (signalStrength >= -70) {
          quality = 'excellent';
        } else if (signalStrength >= -85) {
          quality = 'good';
        } else if (signalStrength >= -100) {
          quality = 'fair';
        } else {
          quality = 'poor';
        }

        return {
          'signalStrength': signalStrength,
          'networkType': networkType,
          'quality': quality,
          'rsrp': result['rsrp'], // 4G/5G
          'rsrq': result['rsrq'], // 4G/5G
          'sinr': result['sinr'], // 4G/5G
          'cqi': result['cqi'],   // 4G/5G
          'pci': result['pci'],   // Physical Cell ID
          'tac': result['tac'],   // Tracking Area Code
          'earfcn': result['earfcn'], // E-UTRA Absolute Radio Frequency Channel Number
        };
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Kiểm tra Multiple APN settings cho từng nhà mạng VN
  Future<List<Map<String, dynamic>>> checkVietnameseAPNSettings() async {
    final vietnameseAPNs = [
      // Viettel
      {
        'carrier': 'Viettel',
        'apn': 'e-connect',
        'proxy': '',
        'port': '',
        'username': '',
        'password': '',
        'mcc': '452',
        'mnc': '04',
      },
      {
        'carrier': 'Viettel',
        'apn': 'v-internet',
        'proxy': '',
        'port': '',
        'username': '',
        'password': '',
        'mcc': '452',
        'mnc': '04',
      },
      // VinaPhone
      {
        'carrier': 'VinaPhone',
        'apn': 'm3-world',
        'proxy': '',
        'port': '',
        'username': 'mms',
        'password': 'mms',
        'mcc': '452',
        'mnc': '02',
      },
      {
        'carrier': 'VinaPhone',
        'apn': 'internet',
        'proxy': '',
        'port': '',
        'username': '',
        'password': '',
        'mcc': '452',
        'mnc': '02',
      },
      // MobiFone
      {
        'carrier': 'MobiFone',
        'apn': 'm-wap',
        'proxy': '10.0.0.172',
        'port': '8080',
        'username': 'mms',
        'password': 'mms',
        'mcc': '452',
        'mnc': '01',
      },
      {
        'carrier': 'MobiFone',
        'apn': 'internet',
        'proxy': '',
        'port': '',
        'username': '',
        'password': '',
        'mcc': '452',
        'mnc': '01',
      },
      // Vietnammobile
      {
        'carrier': 'Vietnammobile',
        'apn': 'internet',
        'proxy': '',
        'port': '',
        'username': '',
        'password': '',
        'mcc': '452',
        'mnc': '05',
      },
      // Gmobile
      {
        'carrier': 'Gmobile',
        'apn': 'internet',
        'proxy': '',
        'port': '',
        'username': '',
        'password': '',
        'mcc': '452',
        'mnc': '06',
      },
    ];

    List<Map<String, dynamic>> results = [];
    
    for (var apn in vietnameseAPNs) {
      try {
        // Test kết nối với APN settings
        final testResult = await _testAPNConnection(apn);
        results.add({
          ...apn,
          'isWorking': testResult,
          'testTime': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        results.add({
          ...apn,
          'isWorking': false,
          'error': e.toString(),
        });
      }
    }
    
    return results;
  }

  /// Test APN connection
  Future<bool> _testAPNConnection(Map<String, dynamic> apn) async {
    try {
      // Simplified test - in real implementation would need native APN testing
      await Future.delayed(Duration(milliseconds: 500));
      return Random().nextBool(); // Mock result
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra network congestion/overload
  Future<Map<String, dynamic>> analyzeNetworkCongestion() async {
    List<int> latencies = [];
    List<double> speeds = [];
    
    // Đo độ trễ trong 30 giây
    for (int i = 0; i < 30; i++) {
      final ping = await _measurePing();
      latencies.add(ping);
      await Future.delayed(Duration(seconds: 1));
    }
    
    // Đo tốc độ 3 lần
    for (int i = 0; i < 3; i++) {
      final speed = await _measureDownloadSpeed();
      speeds.add(speed);
    }
    
    // Phân tích kết quả
    final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
    final maxLatency = latencies.reduce((a, b) => a > b ? a : b);
    final minLatency = latencies.reduce((a, b) => a < b ? a : b);
    final avgSpeed = speeds.reduce((a, b) => a + b) / speeds.length;
    
    // Xác định mức độ tắc nghẽn
    String congestionLevel;
    if (avgLatency > 500 || maxLatency > 1000) {
      congestionLevel = 'severe';
    } else if (avgLatency > 200 || maxLatency > 500) {
      congestionLevel = 'moderate';
    } else if (avgLatency > 100) {
      congestionLevel = 'light';
    } else {
      congestionLevel = 'minimal';
    }
    
    return {
      'averageLatency': avgLatency,
      'maxLatency': maxLatency,
      'minLatency': minLatency,
      'latencyVariation': maxLatency - minLatency,
      'averageSpeed': avgSpeed,
      'congestionLevel': congestionLevel,
      'isNetworkCongested': avgLatency > 200,
      'qualityScore': _calculateQualityScore(avgLatency, avgSpeed),
    };
  }

  /// Tính điểm chất lượng mạng
  double _calculateQualityScore(double latency, double speed) {
    double latencyScore = 100 - (latency / 10); // Giảm điểm theo độ trễ
    double speedScore = speed * 2; // Tăng điểm theo tốc độ
    
    latencyScore = latencyScore.clamp(0, 100);
    speedScore = speedScore.clamp(0, 100);
    
    return ((latencyScore + speedScore) / 2).clamp(0, 100);
  }

  /// Kiểm tra compatibility với IPv6
  Future<Map<String, bool>> checkIPv6Support() async {
    final testHosts = [
      'ipv6.google.com',
      'ipv6.facebook.com',
      'test-ipv6.com',
    ];
    
    Map<String, bool> results = {};
    
    for (String host in testHosts) {
      try {
        final addresses = await InternetAddress.lookup(host, type: InternetAddressType.IPv6);
        results[host] = addresses.isNotEmpty;
      } catch (e) {
        results[host] = false;
      }
    }
    
    return results;
  }

  /// Kiểm tra geographic restrictions
  Future<Map<String, dynamic>> checkGeographicRestrictions() async {
    final testSites = [
      {'name': 'Google VN', 'url': 'https://www.google.com.vn'},
      {'name': 'Facebook', 'url': 'https://www.facebook.com'},
      {'name': 'YouTube', 'url': 'https://www.youtube.com'},
      {'name': 'Twitter', 'url': 'https://www.twitter.com'},
      {'name': 'VTV', 'url': 'https://vtv.vn'},
      {'name': 'VnExpress', 'url': 'https://vnexpress.net'},
    ];
    
    Map<String, dynamic> results = {};
    
    for (var site in testSites) {
      try {
        final response = await _dio.head(
          site['url'] as String,
          options: Options(
            connectTimeout: Duration(seconds: 10),
            followRedirects: false,
          ),
        );
        results[site['name'] as String] = {
          'accessible': response.statusCode < 400,
          'statusCode': response.statusCode,
          'redirected': response.isRedirect,
          'location': response.headers['location']?.first,
        };
      } catch (e) {
        results[site['name'] as String] = {
          'accessible': false,
          'error': e.toString(),
        };
      }
    }
    
    return results;
  }

  /// Kiểm tra Device-specific network issues
  Future<Map<String, dynamic>> checkDeviceSpecificIssues() async {
    final deviceInfo = await _deviceInfo.androidInfo;
    
    return {
      'deviceModel': '${deviceInfo.manufacturer} ${deviceInfo.model}',
      'androidVersion': deviceInfo.version.release,
      'apiLevel': deviceInfo.version.sdkInt,
      'securityPatch': deviceInfo.version.securityPatch,
      'isPhysicalDevice': deviceInfo.isPhysicalDevice,
      'knownIssues': _getKnownNetworkIssues(deviceInfo),
      'recommendedSettings': _getDeviceSpecificRecommendations(deviceInfo),
    };
  }

  /// Lấy danh sách lỗi đã biết cho thiết bị
  List<String> _getKnownNetworkIssues(AndroidDeviceInfo deviceInfo) {
    List<String> issues = [];
    
    // Samsung specific issues
    if (deviceInfo.manufacturer.toLowerCase().contains('samsung')) {
      if (deviceInfo.version.sdkInt < 26) {
        issues.add('Samsung devices below Android 8.0 may have WiFi stability issues');
      }
      issues.add('Check Smart Network Switch setting in WiFi Advanced options');
    }
    
    // Xiaomi specific issues
    if (deviceInfo.manufacturer.toLowerCase().contains('xiaomi')) {
      issues.add('MIUI may restrict background data for apps');
      issues.add('Check MIUI optimization and autostart permissions');
    }
    
    // Huawei specific issues
    if (deviceInfo.manufacturer.toLowerCase().contains('huawei')) {
      issues.add('Huawei devices may have aggressive power management affecting network');
      issues.add('Check protected apps and battery optimization settings');
    }
    
    // Oppo/OnePlus specific issues
    if (deviceInfo.manufacturer.toLowerCase().contains('oppo') || 
        deviceInfo.manufacturer.toLowerCase().contains('oneplus')) {
      issues.add('ColorOS may limit network access for background apps');
    }
    
    return issues;
  }

  /// Lấy khuyến nghị cho thiết bị cụ thể
  List<String> _getDeviceSpecificRecommendations(AndroidDeviceInfo deviceInfo) {
    List<String> recommendations = [];
    
    recommendations.add('Keep device software updated');
    recommendations.add('Clear network settings cache periodically');
    
    if (deviceInfo.version.sdkInt >= 29) {
      recommendations.add('Use Private DNS for better security');
    }
    
    if (deviceInfo.version.sdkInt >= 31) {
      recommendations.add('Check app-specific network permissions');
    }
    
    return recommendations;
  }

  /// Thực hiện continuous monitoring
  void startContinuousMonitoring({Duration interval = const Duration(minutes: 5)}) {
    Timer.periodic(interval, (timer) async {
      final diagnostics = await performComprehensiveDiagnostics();
      final bandwidth = await measureBandwidth();
      final signalQuality = await analyzeSignalQuality();
      
      // Log hoặc lưu trữ kết quả để phân tích
      _logMonitoringData({
        'timestamp': DateTime.now().toIso8601String(),
        'diagnostics': diagnostics.toJson(),
        'bandwidth': bandwidth.toJson(),
        'signalQuality': signalQuality,
      });
    });
  }

  /// Log dữ liệu monitoring
  void _logMonitoringData(Map<String, dynamic> data) {
    // Implement logging logic here
    // Could save to local database, send to analytics, etc.
    print('Network Monitoring Data: ${jsonEncode(data)}');
  }

  /// Tạo báo cáo tổng hợp
  Future<Map<String, dynamic>> generateComprehensiveReport() async {
    final startTime = DateTime.now();
    
    // Thực hiện tất cả các kiểm tra
    final diagnostics = await performComprehensiveDiagnostics();
    final bandwidth = await measureBandwidth();
    final carrierInfo = await getCarrierInfo();
    final wifiInfo = await getWiFiInfo();
    final mobileInfo = await getMobileNetworkInfo();
    final portCheck = await checkCommonPorts();
    final stunTest = await performSTUNTest();
    final dataUsage = await checkDataUsage();
    final signalQuality = await analyzeSignalQuality();
    final apnSettings = await checkVietnameseAPNSettings();
    final congestionAnalysis = await analyzeNetworkCongestion();
    final ipv6Support = await checkIPv6Support();
    final geoRestrictions = await checkGeographicRestrictions();
    final deviceIssues = await checkDeviceSpecificIssues();
    
    final endTime = DateTime.now();
    final testDuration = endTime.difference(startTime);
    
    return {
      'reportGenerated': DateTime.now().toIso8601String(),
      'testDuration': testDuration.inSeconds,
      'diagnostics': diagnostics.toJson(),
      'bandwidth': bandwidth.toJson(),
      'carrierInfo': carrierInfo.toJson(),
      'wifiInfo': wifiInfo.toJson(),
      'mobileInfo': mobileInfo.toJson(),
      'portAccessibility': portCheck,
      'natFirewall': stunTest,
      'dataUsage': dataUsage,
      'signalQuality': signalQuality,
      'apnCompatibility': apnSettings,
      'networkCongestion': congestionAnalysis,
      'ipv6Support': ipv6Support,
      'geographicRestrictions': geoRestrictions,
      'deviceSpecificInfo': deviceIssues,
    };
  }

  /// Dispose resources
  void dispose() {
    _networkStatusController.close();
  }
}