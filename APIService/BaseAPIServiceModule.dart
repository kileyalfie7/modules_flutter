import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Enum định nghĩa các loại HTTP method
enum HttpMethod { get, post, put, patch, delete }

/// Enum trạng thái cache
enum CacheStatus { fresh, stale, expired }

/// Class chứa thông tin response từ API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? headers;
  final bool fromCache;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.headers,
    this.fromCache = false,
  });

  /// Tạo response thành công
  factory ApiResponse.success(T data, {int? statusCode, Map<String, dynamic>? headers, bool fromCache = false}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      statusCode: statusCode,
      headers: headers,
      fromCache: fromCache,
    );
  }

  /// Tạo response lỗi
  factory ApiResponse.error(String message, {int? statusCode, Map<String, dynamic>? headers}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      headers: headers,
    );
  }
}

/// Class quản lý cache data
class CacheItem<T> {
  final T data;
  final DateTime timestamp;
  final Duration maxAge;

  CacheItem({
    required this.data,
    required this.timestamp,
    required this.maxAge,
  });

  /// Kiểm tra cache còn fresh không
  bool get isFresh {
    return DateTime.now().difference(timestamp) < maxAge;
  }

  /// Kiểm tra cache đã expired chưa
  bool get isExpired {
    return DateTime.now().difference(timestamp) > maxAge * 2;
  }

  /// Lấy trạng thái cache
  CacheStatus get status {
    final diff = DateTime.now().difference(timestamp);
    if (diff < maxAge) return CacheStatus.fresh;
    if (diff < maxAge * 2) return CacheStatus.stale;
    return CacheStatus.expired;
  }
}

/// Class quản lý token và refresh token
class TokenManager {
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  static SharedPreferences? _prefs;

  /// Khởi tạo SharedPreferences
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Lưu tokens
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiryTime,
  }) async {
    await initialize();
    await _prefs!.setString(_tokenKey, accessToken);
    await _prefs!.setString(_refreshTokenKey, refreshToken);
    if (expiryTime != null) {
      await _prefs!.setInt(_tokenExpiryKey, expiryTime.millisecondsSinceEpoch);
    }
  }

  /// Lấy access token
  static Future<String?> getAccessToken() async {
    await initialize();
    return _prefs!.getString(_tokenKey);
  }

  /// Lấy refresh token
  static Future<String?> getRefreshToken() async {
    await initialize();
    return _prefs!.getString(_refreshTokenKey);
  }

  /// Kiểm tra token có hết hạn không
  static Future<bool> isTokenExpired() async {
    await initialize();
    final expiryTimestamp = _prefs!.getInt(_tokenExpiryKey);
    if (expiryTimestamp == null) return false;
    
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    return DateTime.now().isAfter(expiryTime.subtract(Duration(minutes: 5))); // Check 5 phút trước khi hết hạn
  }

  /// Xóa tất cả tokens
  static Future<void> clearTokens() async {
    await initialize();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_refreshTokenKey);
    await _prefs!.remove(_tokenExpiryKey);
  }
}

/// Exception tùy chỉnh cho API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? response;

  ApiException(this.message, {this.statusCode, this.response});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Service chính để xử lý các API calls
class BaseApiService {
  late String _baseUrl;
  late String _refreshEndpoint;
  late Map<String, String> _defaultHeaders;
  late Duration _timeout;
  
  /// Cache memory cho dữ liệu
  final Map<String, CacheItem> _memoryCache = {};
  
  /// Callback functions
  Function()? onTokenExpired;
  Function(int statusCode)? onUnauthorized;
  Function()? onRefreshTokenExpired;
  
  /// Flag để tránh multiple refresh calls
  bool _isRefreshing = false;
  List<Function> _refreshQueue = [];

  BaseApiService({
    required String baseUrl,
    String refreshEndpoint = '/auth/refresh',
    Map<String, String>? defaultHeaders,
    Duration? timeout,
    this.onTokenExpired,
    this.onUnauthorized,
    this.onRefreshTokenExpired,
  }) {
    _baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    _refreshEndpoint = refreshEndpoint;
    _defaultHeaders = defaultHeaders ?? _getDefaultHeaders();
    _timeout = timeout ?? const Duration(seconds: 30);
    
    // Tự động load token khi khởi tạo
    _loadStoredToken();
  }

  /// Load token đã lưu từ storage
  Future<void> _loadStoredToken() async {
    final token = await TokenManager.getAccessToken();
    if (token != null) {
      updateAuthToken(token);
    }
  }

  /// Lấy headers mặc định
  Map<String, String> _getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Cập nhật token authorization
  void updateAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }

  /// Xóa token authorization
  void clearAuthToken() {
    _defaultHeaders.remove('Authorization');
  }

  /// Refresh access token
  Future<bool> _refreshAccessToken() async {
    try {
      // Tránh multiple refresh calls
      if (_isRefreshing) {
        // Đợi refresh hiện tại hoàn thành
        await Future.delayed(Duration(milliseconds: 100));
        return _defaultHeaders.containsKey('Authorization');
      }

      _isRefreshing = true;
      
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) {
        throw ApiException('Không có refresh token');
      }

      final response = await http.post(
        Uri.parse(_buildUrl(_refreshEndpoint)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];
        
        // Tính thời gian hết hạn (thường server trả về expires_in tính bằng giây)
        DateTime? expiryTime;
        if (data['expires_in'] != null) {
          expiryTime = DateTime.now().add(Duration(seconds: data['expires_in']));
        }

        await TokenManager.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken ?? refreshToken,
          expiryTime: expiryTime,
        );

        updateAuthToken(newAccessToken);
        
        // Xử lý các request đang chờ
        for (var callback in _refreshQueue) {
          callback();
        }
        _refreshQueue.clear();
        
        _isRefreshing = false;
        return true;
      } else {
        throw ApiException('Refresh token failed', statusCode: response.statusCode);
      }
    } catch (e) {
      _isRefreshing = false;
      _refreshQueue.clear();
      
      // Refresh token hết hạn hoặc invalid
      await TokenManager.clearTokens();
      clearAuthToken();
      
      if (onRefreshTokenExpired != null) {
        onRefreshTokenExpired!();
      }
      
      return false;
    }
  }

  /// Tạo cache key từ endpoint và parameters
  String _generateCacheKey(String endpoint, Map<String, dynamic>? queryParams) {
    String key = endpoint;
    if (queryParams != null && queryParams.isNotEmpty) {
      final sortedParams = Map.fromEntries(
        queryParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
      );
      key += '?${Uri(queryParameters: sortedParams.map((k, v) => MapEntry(k, v.toString()))).query}';
    }
    return key;
  }

  /// Lưu data vào cache
  void _cacheData<T>(String key, T data, Duration maxAge) {
    _memoryCache[key] = CacheItem<T>(
      data: data,
      timestamp: DateTime.now(),
      maxAge: maxAge,
    );
  }

  /// Lấy data từ cache
  T? _getCachedData<T>(String key) {
    final item = _memoryCache[key];
    if (item == null) return null;
    
    final cacheItem = item as CacheItem<T>;
    
    // Xóa cache nếu đã expired
    if (cacheItem.isExpired) {
      _memoryCache.remove(key);
      return null;
    }
    
    return cacheItem.data;
  }

  /// Kiểm tra cache status
  CacheStatus? getCacheStatus(String key) {
    final item = _memoryCache[key];
    return item?.status;
  }

  /// Xóa cache theo key
  void invalidateCache(String key) {
    _memoryCache.remove(key);
  }

  /// Xóa tất cả cache
  void clearCache() {
    _memoryCache.clear();
  }

  /// Tạo URL đầy đủ từ endpoint
  String _buildUrl(String endpoint) {
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return endpoint;
    }
    
    String cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$_baseUrl/$cleanEndpoint';
  }

  /// Merge headers với headers mặc định
  Map<String, String> _mergeHeaders(Map<String, String>? customHeaders) {
    Map<String, String> headers = Map.from(_defaultHeaders);
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  /// Log request details (chỉ trong debug mode)
  void _logRequest(String method, String url, Map<String, String> headers, dynamic body) {
    if (kDebugMode) {
      print('🚀 API Request: $method $url');
      print('📋 Headers: $headers');
      if (body != null) {
        print('📦 Body: $body');
      }
    }
  }

  /// Log response details (chỉ trong debug mode)
  void _logResponse(String method, String url, int statusCode, String responseBody, {bool fromCache = false}) {
    if (kDebugMode) {
      String cacheInfo = fromCache ? ' (FROM CACHE)' : '';
      print('✅ API Response: $method $url - Status: $statusCode$cacheInfo');
      print('📨 Response: $responseBody');
    }
  }

  /// Log error details (chỉ trong debug mode)
  void _logError(String method, String url, dynamic error) {
    if (kDebugMode) {
      print('❌ API Error: $method $url - Error: $error');
    }
  }

  /// Xử lý response và parse JSON
  dynamic _handleResponse(http.Response response, String method, String url) {
    _logResponse(method, url, response.statusCode, response.body);

    // Xử lý các status code đặc biệt
    switch (response.statusCode) {
      case 401:
        throw ApiException(
          'Unauthorized - Token có thể đã hết hạn',
          statusCode: response.statusCode,
          response: _tryParseJson(response.body),
        );
      case 403:
        throw ApiException(
          'Forbidden - Không có quyền truy cập',
          statusCode: response.statusCode,
          response: _tryParseJson(response.body),
        );
      case 404:
        throw ApiException(
          'Not Found - Endpoint không tồn tại',
          statusCode: response.statusCode,
          response: _tryParseJson(response.body),
        );
      case 422:
        throw ApiException(
          'Validation Error - Dữ liệu không hợp lệ',
          statusCode: response.statusCode,
          response: _tryParseJson(response.body),
        );
      case 500:
        throw ApiException(
          'Internal Server Error - Lỗi máy chủ',
          statusCode: response.statusCode,
          response: _tryParseJson(response.body),
        );
    }

    // Kiểm tra status code thành công (200-299)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _tryParseJson(response.body);
    } else {
      // Các lỗi khác
      throw ApiException(
        'HTTP Error: ${response.statusCode}',
        statusCode: response.statusCode,
        response: _tryParseJson(response.body),
      );
    }
  }

  /// Thử parse JSON, trả về string nếu không parse được
  dynamic _tryParseJson(String responseBody) {
    try {
      return json.decode(responseBody);
    } catch (e) {
      return responseBody;
    }
  }

  /// Xử lý các exception khác nhau
  ApiException _handleException(dynamic error, String method, String url) {
    _logError(method, url, error);

    if (error is ApiException) {
      return error;
    } else if (error is SocketException) {
      return ApiException('Không có kết nối internet');
    } else if (error is http.ClientException) {
      return ApiException('Lỗi kết nối: ${error.message}');
    } else if (error is FormatException) {
      return ApiException('Lỗi format dữ liệu: ${error.message}');
    } else {
      return ApiException('Lỗi không xác định: ${error.toString()}');
    }
  }

  /// Generic method để thực hiện HTTP request với auto refresh token
  Future<ApiResponse<T>> _makeRequest<T>(
    HttpMethod method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
    Duration? cacheMaxAge,
    bool forceRefresh = false,
  }) async {
    try {
      String url = _buildUrl(endpoint);
      
      // Thêm query parameters nếu có
      if (queryParameters != null && queryParameters.isNotEmpty) {
        Uri uri = Uri.parse(url);
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...queryParameters.map((key, value) => MapEntry(key, value.toString())),
        });
        url = uri.toString();
      }

      // Kiểm tra cache cho GET requests
      if (method == HttpMethod.get && cacheMaxAge != null && !forceRefresh) {
        String cacheKey = _generateCacheKey(endpoint, queryParameters);
        T? cachedData = _getCachedData<T>(cacheKey);
        
        if (cachedData != null) {
          _logResponse(method.name.toUpperCase(), url, 200, 'Cached data', fromCache: true);
          return ApiResponse.success(cachedData, fromCache: true);
        }
      }

      // Kiểm tra và refresh token nếu cần
      if (await TokenManager.isTokenExpired()) {
        final refreshSuccess = await _refreshAccessToken();
        if (!refreshSuccess) {
          return ApiResponse.error('Token hết hạn và không thể refresh');
        }
      }

      return await _executeRequest<T>(
        method, url, endpoint,
        body: body,
        headers: headers,
        queryParameters: queryParameters,
        parser: parser,
        cacheMaxAge: cacheMaxAge,
      );

    } catch (error) {
      // Xử lý 401 error - thử refresh token
      if (error is ApiException && error.statusCode == 401) {
        final refreshSuccess = await _refreshAccessToken();
        if (refreshSuccess) {
          // Thử lại request sau khi refresh
          return await _executeRequest<T>(
            method, _buildUrl(endpoint), endpoint,
            body: body,
            headers: headers,
            queryParameters: queryParameters,
            parser: parser,
            cacheMaxAge: cacheMaxAge,
          );
        }
      }

      ApiException apiException = _handleException(error, method.name.toUpperCase(), endpoint);
      return ApiResponse.error(
        apiException.message,
        statusCode: apiException.statusCode,
      );
    }
  }

  /// Thực hiện HTTP request thực tế
  Future<ApiResponse<T>> _executeRequest<T>(
    HttpMethod method,
    String url,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
    Duration? cacheMaxAge,
  }) async {
    Map<String, String> requestHeaders = _mergeHeaders(headers);
    String? requestBody;

    // Prepare body nếu có
    if (body != null) {
      requestBody = json.encode(body);
    }

    _logRequest(method.name.toUpperCase(), url, requestHeaders, requestBody);

    http.Response response;

    // Thực hiện request theo method
    switch (method) {
      case HttpMethod.get:
        response = await http.get(
          Uri.parse(url), 
          headers: requestHeaders,
        ).timeout(_timeout);
        break;
      case HttpMethod.post:
        response = await http.post(
          Uri.parse(url),
          headers: requestHeaders,
          body: requestBody,
        ).timeout(_timeout);
        break;
      case HttpMethod.put:
        response = await http.put(
          Uri.parse(url),
          headers: requestHeaders,
          body: requestBody,
        ).timeout(_timeout);
        break;
      case HttpMethod.patch:
        response = await http.patch(
          Uri.parse(url),
          headers: requestHeaders,
          body: requestBody,
        ).timeout(_timeout);
        break;
      case HttpMethod.delete:
        response = await http.delete(
          Uri.parse(url),
          headers: requestHeaders,
          body: requestBody,
        ).timeout(_timeout);
        break;
    }

    // Xử lý response
    dynamic responseData = _handleResponse(response, method.name.toUpperCase(), url);
    
    // Parse data nếu có parser
    T? parsedData;
    if (parser != null && responseData != null) {
      parsedData = parser(responseData);
    } else {
      parsedData = responseData as T?;
    }

    // Cache data nếu là GET request và có cacheMaxAge
    if (method == HttpMethod.get && cacheMaxAge != null && parsedData != null) {
      String cacheKey = _generateCacheKey(endpoint, queryParameters);
      _cacheData(cacheKey, parsedData, cacheMaxAge);
    }

    return ApiResponse.success(
      parsedData as T,
      statusCode: response.statusCode,
      headers: response.headers.cast<String, dynamic>(),
    );
  }

  /// GET request với cache support
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
    Duration? cacheMaxAge,
    bool forceRefresh = false,
  }) {
    return _makeRequest<T>(
      HttpMethod.get,
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
      parser: parser,
      cacheMaxAge: cacheMaxAge,
      forceRefresh: forceRefresh,
    );
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) {
    return _makeRequest<T>(
      HttpMethod.post,
      endpoint,
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      parser: parser,
    );
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) {
    return _makeRequest<T>(
      HttpMethod.put,
      endpoint,
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      parser: parser,
    );
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) {
    return _makeRequest<T>(
      HttpMethod.patch,
      endpoint,
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      parser: parser,
    );
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) {
    return _makeRequest<T>(
      HttpMethod.delete,
      endpoint,
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      parser: parser,
    );
  }

  /// Upload file với multipart/form-data
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? fields,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) async {
    try {
      // Kiểm tra và refresh token nếu cần
      if (await TokenManager.isTokenExpired()) {
        final refreshSuccess = await _refreshAccessToken();
        if (!refreshSuccess) {
          return ApiResponse.error('Token hết hạn và không thể refresh');
        }
      }

      String url = _buildUrl(endpoint);
      Map<String, String> requestHeaders = _mergeHeaders(headers);
      
      // Xóa Content-Type để http tự động set cho multipart
      requestHeaders.remove('Content-Type');

      _logRequest('UPLOAD', url, requestHeaders, 'File: $filePath');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(requestHeaders);

      // Thêm file
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      // Thêm các fields khác nếu có
      if (fields != null) {
        request.fields.addAll(fields);
      }

      var streamedResponse = await request.send().timeout(_timeout);
      var response = await http.Response.fromStream(streamedResponse);

      dynamic responseData = _handleResponse(response, 'UPLOAD', url);
      
      T? parsedData;
      if (parser != null && responseData != null) {
        parsedData = parser(responseData);
      } else {
        parsedData = responseData as T?;
      }

      return ApiResponse.success(
        parsedData as T,
        statusCode: response.statusCode,
        headers: response.headers.cast<String, dynamic>(),
      );

    } catch (error) {
      ApiException apiException = _handleException(error, 'UPLOAD', endpoint);
      return ApiResponse.error(
        apiException.message,
        statusCode: apiException.statusCode,
      );
    }
  }
}

/// Singleton instance để sử dụng toàn app
class ApiService {
  static BaseApiService? _instance;
  
  /// Khởi tạo singleton
  static void initialize({
    required String baseUrl,
    String refreshEndpoint = '/auth/refresh',
    Map<String, String>? defaultHeaders,
    Duration? timeout,
    Function()? onTokenExpired,
    Function(int statusCode)? onUnauthorized,
    Function()? onRefreshTokenExpired,
  }) {
    _instance = BaseApiService(
      baseUrl: baseUrl,
      refreshEndpoint: refreshEndpoint,
      defaultHeaders: defaultHeaders,
      timeout: timeout,
      onTokenExpired: onTokenExpired,
      onUnauthorized: onUnauthorized,
      onRefreshTokenExpired: onRefreshTokenExpired,
    );
  }

  /// Lấy instance singleton
  static BaseApiService get instance {
    if (_instance == null) {
      throw Exception('ApiService chưa được khởi tạo. Hãy gọi ApiService.initialize() trước.');
    }
    return _instance!;
  }
}

// ============================================
// REPOSITORY LAYER (Giống như hooks trong React)
// ============================================

/// Base Repository class cho các API endpoint
abstract class BaseRepository {
  final BaseApiService _apiService = ApiService.instance;
  
  /// Cache duration mặc định
  Duration get defaultCacheTime => Duration(minutes: 5);
  
  /// Stale time mặc định
  Duration get defaultStaleTime => Duration(minutes: 1);
}

/// Repository cho User API
class UserRepository extends BaseRepository {
  
  /// Lấy danh sách users với cache
  Future<ApiResponse<List<User>>> getUsers({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    return await _apiService.get<List<User>>(
      '/users',
      queryParameters: {'page': page, 'limit': limit},
      parser: (data) => (data['users'] as List).map((e) => User.fromJson(e)).toList(),
      cacheMaxAge: defaultCacheTime,
      forceRefresh: forceRefresh,
    );
  }

  /// Lấy thông tin user theo ID
  Future<ApiResponse<User>> getUserById(String userId, {bool forceRefresh = false}) async {
    return await _apiService.get<User>(
      '/users/$userId',
      parser: (data) => User.fromJson(data),
      cacheMaxAge: defaultCacheTime,
      forceRefresh: forceRefresh,
    );
  }

  /// Tạo user mới
  Future<ApiResponse<User>> createUser(Map<String, dynamic> userData) async {
    final response = await _apiService.post<User>(
      '/users',
      body: userData,
      parser: (data) => User.fromJson(data),
    );

    // Invalidate cache sau khi tạo mới
    if (response.success) {
      _apiService.invalidateCache('/users');
    }

    return response;
  }

  /// Cập nhật user
  Future<ApiResponse<User>> updateUser(String userId, Map<String, dynamic> userData) async {
    final response = await _apiService.put<User>(
      '/users/$userId',
      body: userData,
      parser: (data) => User.fromJson(data),
    );

    // Invalidate cache sau khi cập nhật
    if (response.success) {
      _apiService.invalidateCache('/users/$userId');
      _apiService.invalidateCache('/users');
    }

    return response;
  }

  /// Xóa user
  Future<ApiResponse<bool>> deleteUser(String userId) async {
    final response = await _apiService.delete<bool>(
      '/users/$userId',
      parser: (data) => data['success'] ?? true,
    );

    // Invalidate cache sau khi xóa
    if (response.success) {
      _apiService.invalidateCache('/users/$userId');
      _apiService.invalidateCache('/users');
    }

    return response;
  }
}

/// Repository cho Auth API
class AuthRepository extends BaseRepository {
  
  /// Đăng nhập
  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    final response = await _apiService.post<AuthResponse>(
      '/auth/login',
      body: {'email': email, 'password': password},
      parser: (data) => AuthResponse.fromJson(data),
    );

    // Lưu tokens sau khi đăng nhập thành công
    if (response.success && response.data != null) {
      await TokenManager.saveTokens(
        accessToken: response.data!.accessToken,
        refreshToken: response.data!.refreshToken,
        expiryTime: response.data!.expiryTime,
      );
      _apiService.updateAuthToken(response.data!.accessToken);
    }

    return response;
  }

  /// Đăng ký
  Future<ApiResponse<AuthResponse>> register(Map<String, dynamic> userData) async {
    return await _apiService.post<AuthResponse>(
      '/auth/register',
      body: userData,
      parser: (data) => AuthResponse.fromJson(data),
    );
  }

  /// Đăng xuất
  Future<ApiResponse<bool>> logout() async {
    final response = await _apiService.post<bool>(
      '/auth/logout',
      parser: (data) => data['success'] ?? true,
    );

    // Xóa tokens và cache sau khi đăng xuất
    await TokenManager.clearTokens();
    _apiService.clearAuthToken();
    _apiService.clearCache();

    return response;
  }

  /// Lấy thông tin profile hiện tại
  Future<ApiResponse<User>> getCurrentUser({bool forceRefresh = false}) async {
    return await _apiService.get<User>(
      '/auth/me',
      parser: (data) => User.fromJson(data),
      cacheMaxAge: defaultCacheTime,
      forceRefresh: forceRefresh,
    );
  }

  /// Đổi mật khẩu
  Future<ApiResponse<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _apiService.put<bool>(
      '/auth/change-password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      parser: (data) => data['success'] ?? true,
    );
  }

  /// Quên mật khẩu
  Future<ApiResponse<bool>> forgotPassword(String email) async {
    return await _apiService.post<bool>(
      '/auth/forgot-password',
      body: {'email': email},
      parser: (data) => data['success'] ?? true,
    );
  }

  /// Reset mật khẩu
  Future<ApiResponse<bool>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return await _apiService.post<bool>(
      '/auth/reset-password',
      body: {
        'token': token,
        'new_password': newPassword,
      },
      parser: (data) => data['success'] ?? true,
    );
  }
}

/// Repository cho Product API
class ProductRepository extends BaseRepository {
  
  /// Lấy danh sách sản phẩm với filter và pagination
  Future<ApiResponse<ProductListResponse>> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? searchQuery,
    String? sortBy,
    bool forceRefresh = false,
  }) async {
    Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };

    if (category != null) queryParams['category'] = category;
    if (searchQuery != null) queryParams['search'] = searchQuery;
    if (sortBy != null) queryParams['sort'] = sortBy;

    return await _apiService.get<ProductListResponse>(
      '/products',
      queryParameters: queryParams,
      parser: (data) => ProductListResponse.fromJson(data),
      cacheMaxAge: defaultCacheTime,
      forceRefresh: forceRefresh,
    );
  }

  /// Lấy chi tiết sản phẩm
  Future<ApiResponse<Product>> getProductById(String productId, {bool forceRefresh = false}) async {
    return await _apiService.get<Product>(
      '/products/$productId',
      parser: (data) => Product.fromJson(data),
      cacheMaxAge: Duration(minutes: 10), // Cache lâu hơn cho chi tiết sản phẩm
      forceRefresh: forceRefresh,
    );
  }

  /// Lấy sản phẩm liên quan
  Future<ApiResponse<List<Product>>> getRelatedProducts(String productId, {bool forceRefresh = false}) async {
    return await _apiService.get<List<Product>>(
      '/products/$productId/related',
      parser: (data) => (data as List).map((e) => Product.fromJson(e)).toList(),
      cacheMaxAge: Duration(minutes: 15),
      forceRefresh: forceRefresh,
    );
  }

  /// Tạo sản phẩm mới (Admin only)
  Future<ApiResponse<Product>> createProduct(Map<String, dynamic> productData) async {
    final response = await _apiService.post<Product>(
      '/products',
      body: productData,
      parser: (data) => Product.fromJson(data),
    );

    // Invalidate cache sau khi tạo mới
    if (response.success) {
      _apiService.invalidateCache('/products');
    }

    return response;
  }
}

/// Repository cho Order API
class OrderRepository extends BaseRepository {
  
  /// Lấy danh sách đơn hàng của user
  Future<ApiResponse<List<Order>>> getUserOrders({
    int page = 1,
    int limit = 10,
    String? status,
    bool forceRefresh = false,
  }) async {
    Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;

    return await _apiService.get<List<Order>>(
      '/orders',
      queryParameters: queryParams,
      parser: (data) => (data['orders'] as List).map((e) => Order.fromJson(e)).toList(),
      cacheMaxAge: Duration(minutes: 2), // Cache ngắn cho orders
      forceRefresh: forceRefresh,
    );
  }

  /// Lấy chi tiết đơn hàng
  Future<ApiResponse<Order>> getOrderById(String orderId, {bool forceRefresh = false}) async {
    return await _apiService.get<Order>(
      '/orders/$orderId',
      parser: (data) => Order.fromJson(data),
      cacheMaxAge: Duration(minutes: 5),
      forceRefresh: forceRefresh,
    );
  }

  /// Tạo đơn hàng mới
  Future<ApiResponse<Order>> createOrder(Map<String, dynamic> orderData) async {
    final response = await _apiService.post<Order>(
      '/orders',
      body: orderData,
      parser: (data) => Order.fromJson(data),
    );

    // Invalidate cache sau khi tạo đơn hàng
    if (response.success) {
      _apiService.invalidateCache('/orders');
    }

    return response;
  }

  /// Hủy đơn hàng
  Future<ApiResponse<bool>> cancelOrder(String orderId) async {
    final response = await _apiService.put<bool>(
      '/orders/$orderId/cancel',
      parser: (data) => data['success'] ?? true,
    );

    // Invalidate cache sau khi hủy
    if (response.success) {
      _apiService.invalidateCache('/orders/$orderId');
      _apiService.invalidateCache('/orders');
    }

    return response;
  }
}

/// Repository cho File Upload
class FileRepository extends BaseRepository {
  
  /// Upload single file
  Future<ApiResponse<FileUploadResponse>> uploadFile(
    String filePath, {
    String folder = 'uploads',
    Map<String, String>? metadata,
  }) async {
    Map<String, String> fields = {'folder': folder};
    if (metadata != null) {
      fields.addAll(metadata);
    }

    return await _apiService.uploadFile<FileUploadResponse>(
      '/files/upload',
      filePath,
      fields: fields,
      parser: (data) => FileUploadResponse.fromJson(data),
    );
  }

  /// Upload multiple files
  Future<List<ApiResponse<FileUploadResponse>>> uploadFiles(
    List<String> filePaths, {
    String folder = 'uploads',
    Map<String, String>? metadata,
  }) async {
    List<ApiResponse<FileUploadResponse>> results = [];
    
    for (String filePath in filePaths) {
      final result = await uploadFile(filePath, folder: folder, metadata: metadata);
      results.add(result);
    }
    
    return results;
  }

  /// Xóa file
  Future<ApiResponse<bool>> deleteFile(String fileId) async {
    return await _apiService.delete<bool>(
      '/files/$fileId',
      parser: (data) => data['success'] ?? true,
    );
  }
}

// ============================================
// MODEL CLASSES
// ============================================

/// Model cho User
class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Model cho Auth Response
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;
  final DateTime? expiryTime;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.expiryTime,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    DateTime? expiry;
    if (json['expires_in'] != null) {
      expiry = DateTime.now().add(Duration(seconds: json['expires_in']));
    }

    return AuthResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: User.fromJson(json['user']),
      expiryTime: expiry,
    );
  }
}

/// Model cho Product
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String category;
  final int stock;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.category,
    required this.stock,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      category: json['category'],
      stock: json['stock'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Model cho Product List Response
class ProductListResponse {
  final List<Product> products;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  ProductListResponse({
    required this.products,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      products: (json['products'] as List).map((e) => Product.fromJson(e)).toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['total_pages'],
    );
  }
}

/// Model cho Order
class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Model cho Order Item
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}

/// Model cho File Upload Response
class FileUploadResponse {
  final String id;
  final String filename;
  final String url;
  final String mimeType;
  final int size;

  FileUploadResponse({
    required this.id,
    required this.filename,
    required this.url,
    required this.mimeType,
    required this.size,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      id: json['id'],
      filename: json['filename'],
      url: json['url'],
      mimeType: json['mime_type'],
      size: json['size'],
    );
  }
}

// ============================================
// SERVICE LOCATOR (Dependency Injection)
// ============================================

/// Service locator để quản lý các repository instances
class ServiceLocator {
  static final Map<Type, dynamic> _services = {};

  /// Đăng ký service
  static void register<T>(T service) {
    _services[T] = service;
  }

  /// Lấy service
  static T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service của type $T chưa được đăng ký');
    }
    return service as T;
  }

  /// Kiểm tra service đã được đăng ký chưa
  static bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Xóa service
  static void unregister<T>() {
    _services.remove(T);
  }

  /// Xóa tất cả services
  static void clear() {
    _services.clear();
  }
}

// ============================================
// REPOSITORY MANAGER (Giống như hooks)
// ============================================

/// Manager class để dễ dàng truy cập các repository
class RepositoryManager {
  static UserRepository? _userRepository;
  static AuthRepository? _authRepository;
  static ProductRepository? _productRepository;
  static OrderRepository? _orderRepository;
  static FileRepository? _fileRepository;

  /// User Repository
  static UserRepository get user {
    _userRepository ??= UserRepository();
    return _userRepository!;
  }

  /// Auth Repository
  static AuthRepository get auth {
    _authRepository ??= AuthRepository();
    return _authRepository!;
  }

  /// Product Repository
  static ProductRepository get product {
    _productRepository ??= ProductRepository();
    return _productRepository!;
  }

  /// Order Repository
  static OrderRepository get order {
    _orderRepository ??= OrderRepository();
    return _orderRepository!;
  }

  /// File Repository
  static FileRepository get file {
    _fileRepository ??= FileRepository();
    return _fileRepository!;
  }

  /// Clear tất cả repository instances
  static void clear() {
    _userRepository = null;
    _authRepository = null;
    _productRepository = null;
    _orderRepository = null;
    _fileRepository = null;
  }
}