// lib/core/utils/validators.dart
class Validators {
  // Regex patterns cho Việt Nam
  static final RegExp _phoneVN = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$');
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );
  static final RegExp _vietnameseText = RegExp(
    r'^[a-zA-ZàáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđĐ\s]+$'
  );
  static final RegExp _cccd = RegExp(r'^[0-9]{12}$');
  static final RegExp _cmnd = RegExp(r'^[0-9]{9}$|^[0-9]{12}$');
  static final RegExp _taxCode = RegExp(r'^[0-9]{10}$|^[0-9]{13}$');
  static final RegExp _bankAccount = RegExp(r'^[0-9]{6,19}$');
  
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email không được để trống';
    if (!_emailPattern.hasMatch(value)) return 'Email không hợp lệ';
    return null;
  }
  
  // Số điện thoại Việt Nam
  static String? phoneVN(String? value) {
    if (value == null || value.isEmpty) return 'Số điện thoại không được để trống';
    final phone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!_phoneVN.hasMatch(phone)) return 'Số điện thoại không hợp lệ';
    return null;
  }
  
  // Required field
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Trường này'} không được để trống';
    }
    return null;
  }
  
  // Minimum length
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.length < min) {
      return '${fieldName ?? 'Trường này'} phải có ít nhất $min ký tự';
    }
    return null;
  }
  
  // Maximum length
  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'Trường này'} không được quá $max ký tự';
    }
    return null;
  }
  
  // Mật khẩu mạnh
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mật khẩu không được để trống';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) return 'Mật khẩu phải có ít nhất 1 chữ cái';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Mật khẩu phải có ít nhất 1 số';
    return null;
  }
  
  // Xác nhận mật khẩu
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (value != originalPassword) return 'Mật khẩu xác nhận không khớp';
    return null;
  }
  
  // Số tiền (VNĐ)
  static String? money(String? value) {
    if (value == null || value.isEmpty) return 'Số tiền không được để trống';
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    final amount = double.tryParse(cleanValue);
    if (amount == null) return 'Số tiền không hợp lệ';
    if (amount < 0) return 'Số tiền không được âm';
    if (amount > 999999999999) return 'Số tiền quá lớn';
    return null;
  }
  
  // Số lượng
  static String? quantity(String? value) {
    if (value == null || value.isEmpty) return 'Số lượng không được để trống';
    final qty = int.tryParse(value);
    if (qty == null) return 'Số lượng phải là số nguyên';
    if (qty < 0) return 'Số lượng không được âm';
    if (qty > 999999) return 'Số lượng quá lớn';
    return null;
  }
  
  // CCCD/CMND
  static String? idCard(String? value) {
    if (value == null || value.isEmpty) return 'CCCD/CMND không được để trống';
    if (!_cmnd.hasMatch(value)) return 'CCCD/CMND không hợp lệ (9 hoặc 12 số)';
    return null;
  }
  
  // Mã số thuế
  static String? taxCode(String? value) {
    if (value == null || value.isEmpty) return 'Mã số thuế không được để trống';
    if (!_taxCode.hasMatch(value)) return 'Mã số thuế không hợp lệ (10 hoặc 13 số)';
    return null;
  }
  
  // Tên tiếng Việt
  static String? vietnameseName(String? value) {
    if (value == null || value.isEmpty) return 'Tên không được để trống';
    if (!_vietnameseText.hasMatch(value)) return 'Tên chỉ được chứa chữ cái tiếng Việt';
    if (value.length < 2) return 'Tên phải có ít nhất 2 ký tự';
    return null;
  }
  
  // Địa chỉ
  static String? address(String? value) {
    if (value == null || value.isEmpty) return 'Địa chỉ không được để trống';
    if (value.length < 10) return 'Địa chỉ quá ngắn';
    if (value.length > 200) return 'Địa chỉ quá dài';
    return null;
  }
  
  // Số tài khoản ngân hàng
  static String? bankAccount(String? value) {
    if (value == null || value.isEmpty) return 'Số tài khoản không được để trống';
    if (!_bankAccount.hasMatch(value)) return 'Số tài khoản không hợp lệ (6-19 số)';
    return null;
  }
  
  // Mã khách hàng/nhà cung cấp
  static String? customerCode(String? value) {
    if (value == null || value.isEmpty) return 'Mã không được để trống';
    if (value.length < 3) return 'Mã phải có ít nhất 3 ký tự';
    if (value.length > 20) return 'Mã không được quá 20 ký tự';
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) return 'Mã chỉ chứa chữ hoa và số';
    return null;
  }
  
  // Combo validation
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}

// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

class Formatters {
  // Number formatters
  static final NumberFormat _vnCurrency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  
  static final NumberFormat _vnNumber = NumberFormat('#,##0', 'vi_VN');
  static final NumberFormat _vnDecimal = NumberFormat('#,##0.##', 'vi_VN');
  static final NumberFormat _vnPercent = NumberFormat.percentPattern('vi_VN');
  
  // Date formatters
  static final DateFormat _vnDate = DateFormat('dd/MM/yyyy', 'vi_VN');
  static final DateFormat _vnDateTime = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
  static final DateFormat _vnTime = DateFormat('HH:mm', 'vi_VN');
  static final DateFormat _vnDateFull = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN');
  static final DateFormat _vnMonthYear = DateFormat('MM/yyyy', 'vi_VN');
  
  // Tiền tệ VNĐ
  static String currency(num? value) {
    if (value == null) return '0₫';
    return _vnCurrency.format(value);
  }
  
  // Tiền tệ ngắn gọn (K, M, B)
  static String currencyCompact(num? value) {
    if (value == null) return '0₫';
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}B₫';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M₫';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K₫';
    return '${value.toInt()}₫';
  }
  
  // Số nguyên
  static String number(num? value) {
    if (value == null) return '0';
    return _vnNumber.format(value);
  }
  
  // Số thập phân
  static String decimal(num? value, [int? decimalPlaces]) {
    if (value == null) return '0';
    if (decimalPlaces != null) {
      return NumberFormat('#,##0.${'0' * decimalPlaces}', 'vi_VN').format(value);
    }
    return _vnDecimal.format(value);
  }
  
  // Phần trăm
  static String percent(num? value) {
    if (value == null) return '0%';
    return _vnPercent.format(value / 100);
  }
  
  // Ngày tháng dd/MM/yyyy
  static String date(DateTime? date) {
    if (date == null) return '';
    return _vnDate.format(date);
  }
  
  // Ngày giờ dd/MM/yyyy HH:mm
  static String dateTime(DateTime? date) {
    if (date == null) return '';
    return _vnDateTime.format(date);
  }
  
  // Giờ HH:mm
  static String time(DateTime? date) {
    if (date == null) return '';
    return _vnTime.format(date);
  }
  
  // Ngày đầy đủ: Thứ hai, 15/03/2024
  static String dateFull(DateTime? date) {
    if (date == null) return '';
    return _vnDateFull.format(date);
  }
  
  // Tháng năm MM/yyyy
  static String monthYear(DateTime? date) {
    if (date == null) return '';
    return _vnMonthYear.format(date);
  }
  
  // Thời gian tương đối (vừa xong, 5 phút trước, etc.)
  static String timeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} năm trước';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} tháng trước';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
  
  // Số điện thoại format
  static String phone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
    }
    return phone;
  }
  
  // CCCD/CMND format
  static String idCard(String? id) {
    if (id == null || id.isEmpty) return '';
    if (id.length == 9) {
      return '${id.substring(0, 3)} ${id.substring(3, 6)} ${id.substring(6)}';
    }
    if (id.length == 12) {
      return '${id.substring(0, 3)} ${id.substring(3, 6)} ${id.substring(6, 9)} ${id.substring(9)}';
    }
    return id;
  }
  
  // Mã số thuế format
  static String taxCode(String? tax) {
    if (tax == null || tax.isEmpty) return '';
    if (tax.length == 10) {
      return '${tax.substring(0, 3)}-${tax.substring(3, 6)}-${tax.substring(6)}';
    }
    if (tax.length == 13) {
      return '${tax.substring(0, 3)}-${tax.substring(3, 6)}-${tax.substring(6, 9)}-${tax.substring(9)}';
    }
    return tax;
  }
  
  // Số tài khoản ngân hàng (ẩn bớt)
  static String bankAccountMasked(String? account) {
    if (account == null || account.isEmpty) return '';
    if (account.length < 6) return account;
    final start = account.substring(0, 3);
    final end = account.substring(account.length - 3);
    final middle = '*' * (account.length - 6);
    return '$start$middle$end';
  }
  
  // Trạng thái đơn hàng
  static String orderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending': return 'Chờ xử lý';
      case 'confirmed': return 'Đã xác nhận';
      case 'processing': return 'Đang xử lý';
      case 'shipping': return 'Đang giao';
      case 'delivered': return 'Đã giao';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      case 'returned': return 'Đã trả';
      default: return status ?? '';
    }
  }
  
  // Loại thanh toán
  static String paymentMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'cash': return 'Tiền mặt';
      case 'transfer': return 'Chuyển khoản';
      case 'card': return 'Thẻ';
      case 'cod': return 'COD';
      case 'credit': return 'Công nợ';
      default: return method ?? '';
    }
  }
  
  // Đơn vị tính
  static String unit(String? unit) {
    switch (unit?.toLowerCase()) {
      case 'pcs': case 'piece': return 'cái';
      case 'box': return 'hộp';
      case 'pack': return 'gói';
      case 'kg': return 'kg';
      case 'gram': return 'gram';
      case 'liter': return 'lít';
      case 'bottle': return 'chai';
      case 'can': return 'lon';
      case 'dozen': return 'tá';
      default: return unit ?? '';
    }
  }
}

// lib/core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'formatters.dart';

// String Extensions
extension StringExtensions on String {
  // Kiểm tra chuỗi rỗng
  bool get isEmptyOrNull => isEmpty;
  bool get isNotEmptyOrNull => isNotEmpty;
  
  // Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  // Title case
  String get titleCase {  
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  // Loại bỏ dấu tiếng Việt
  String get removeVietnameseAccents {
    const vietnamese = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const replacement = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    
    String result = toLowerCase();
    for (int i = 0; i < vietnamese.length; i++) {
      result = result.replaceAll(vietnamese[i], replacement[i]);
    }
    return result.replaceAll('đ', 'd');
  }
  
  // Parse thành số
  double? get toDouble => double.tryParse(replaceAll(',', ''));
  int? get toInt => int.tryParse(replaceAll(',', ''));
  
  // Validate email
  bool get isValidEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  
  // Validate phone VN
  bool get isValidPhoneVN => RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$').hasMatch(replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  
  // Chỉ lấy số
  String get numbersOnly => replaceAll(RegExp(r'[^\d]'), '');
  
  // Chỉ lấy chữ và số
  String get alphanumericOnly => replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  
  // Truncate with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
  
  // Format as phone
  String get formatPhone => Formatters.phone(this);
  
  // Format as ID card
  String get formatIdCard => Formatters.idCard(this);
  
  // Format as tax code
  String get formatTaxCode => Formatters.taxCode(this);
}

// Nullable String Extensions
extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
  
  String get orEmpty => this ?? '';
  String orDefault(String defaultValue) => this ?? defaultValue;
}

// Number Extensions
extension NumberExtensions on num {
  String get toCurrency => Formatters.currency(this);
  String get toCurrencyCompact => Formatters.currencyCompact(this);
  String get toNumber => Formatters.number(this);
  String toDecimal([int? places]) => Formatters.decimal(this, places);
  String get toPercent => Formatters.percent(this);
  
  // Làm tròn VNĐ (bội số của 1000)
  int get roundToThousand => (this / 1000).round() * 1000;
  
  // Kiểm tra số dương
  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero => this == 0;
}

// DateTime Extensions
extension DateTimeExtensions on DateTime {
  String get toDateString => Formatters.date(this);
  String get toDateTimeString => Formatters.dateTime(this);
  String get toTimeString => Formatters.time(this);
  String get toFullDateString => Formatters.dateFull(this);
  String get toMonthYearString => Formatters.monthYear(this);
  String get timeAgo => Formatters.timeAgo(this);
  
  // Kiểm tra
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
  
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
           isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
  
  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }
  
  // Utility methods
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
  DateTime get startOfMonth => DateTime(year, month, 1);
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);
  
  // Ngày trong tuần tiếng Việt
  String get weekdayVN {
    const weekdays = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];
    return weekdays[weekday % 7];
  }
  
  // Tháng tiếng Việt
  String get monthVN {
    const months = ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
                   'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
    return months[month - 1];
  }
}

// Nullable DateTime Extensions
extension NullableDateTimeExtensions on DateTime? {
  String get toDateStringOrEmpty => this?.toDateString ?? '';
  String get toDateTimeStringOrEmpty => this?.toDateTimeString ?? '';
  String get timeAgoOrEmpty => this?.timeAgo ?? '';
}

// List Extensions
extension ListExtensions<T> on List<T> {
  // Tìm phần tử an toàn
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
  
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  // Chia list thành chunks
  List<List<T>> chunk(int size) {
    List<List<T>> chunks = [];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
  
  // Lọc unique
  List<T> get unique => toSet().toList();
  
  // Tổng cho list số
  num get sum => fold<num>(0, (prev, curr) => prev + (curr as num));
  
  // Trung bình cho list số  
  double get average => isEmpty ? 0 : sum / length;
}

// Map Extensions
extension MapExtensions<K, V> on Map<K, V> {
  // Lấy value an toàn
  V? getOrNull(K key) => containsKey(key) ? this[key] : null;
  V getOrDefault(K key, V defaultValue) => this[key] ?? defaultValue;
  
  // Lọc map
  Map<K, V> whereKey(bool Function(K key) test) {
    return Map.fromEntries(entries.where((entry) => test(entry.key)));
  }
  
  Map<K, V> whereValue(bool Function(V value) test) {
    return Map.fromEntries(entries.where((entry) => test(entry.value)));
  }
}

// BuildContext Extensions
extension ContextExtensions on BuildContext {
  // Media Query shortcuts
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  double get statusBarHeight => MediaQuery.of(this).padding.top;
  double get bottomPadding => MediaQuery.of(this).padding.bottom;
  
  // Responsive helpers
  bool get isTablet => screenWidth >= 768;
  bool get isMobile => screenWidth < 768;
  bool get isLandscape => screenWidth > screenHeight;
  bool get isPortrait => screenHeight > screenWidth;
  
  // Navigation shortcuts
  void pop([dynamic result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Route<T> route) => Navigator.of(this).push(route);
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) => 
      Navigator.of(this).pushNamed(routeName, arguments: arguments);
  Future<T?> pushReplacement<T>(Route<T> route) => Navigator.of(this).pushReplacement(route);
  void pushNamedAndRemoveUntil(String routeName, bool Function(Route) predicate) =>
      Navigator.of(this).pushNamedAndRemoveUntil(routeName, predicate);
  
  // Snackbar shortcuts
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
  
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  // Focus shortcuts
  void unfocus() => FocusScope.of(this).unfocus();
  void nextFocus() => FocusScope.of(this).nextFocus();
  
  // Hide keyboard
  void hideKeyboard() => FocusScope.of(this).requestFocus(FocusNode());
}

// lib/core/utils/constants.dart
class Constants {
  // Các tỉnh thành Việt Nam
  static const List<String> vietnamProvinces = [
    'An Giang', 'Bà Rịa - Vũng Tàu', 'Bắc Giang', 'Bắc Kạn', 'Bạc Liêu',
    'Bắc Ninh', 'Bến Tre', 'Bình Định', 'Bình Dương', 'Bình Phước',
    'Bình Thuận', 'Cà Mau', 'Cao Bằng', 'Đắk Lắk', 'Đắk Nông',
    'Điện Biên', 'Đồng Nai', 'Đồng Tháp', 'Gia Lai', 'Hà Giang',
    'Hà Nam', 'Hà Tĩnh', 'Hải Dương', 'Hậu Giang', 'Hòa Bình',
    'Hưng Yên', 'Khánh Hòa', 'Kiên Giang', 'Kon Tum', 'Lai Châu',
    'Lâm Đồng', 'Lạng Sơn', 'Lào Cai', 'Long An', 'Nam Định',
    'Nghệ An', 'Ninh Bình', 'Ninh Thuận', 'Phú Thọ', 'Quảng Bình',
    'Quảng Nam', 'Quảng Ngãi', 'Quảng Ninh', 'Quảng Trị', 'Sóc Trăng',
    'Sơn La', 'Tây Ninh', 'Thái Bình', 'Thái Nguyên', 'Thanh Hóa',
    'Thừa Thiên Huế', 'Tiền Giang', 'Trà Vinh', 'Tuyên Quang', 'Vĩnh Long',
    'Vĩnh Phúc', 'Yên Bái', 'Phú Yên', 'Cần Thơ', 'Đà Nẵng',
    'Hải Phòng', 'Hà Nội', 'TP. Hồ Chí Minh'
  ];
  
  // Đầu số điện thoại Việt Nam
  static const Map<String, String> phoneCarriers = {
    '032': 'Viettel', '033': 'Viettel', '034': 'Viettel', '035': 'Viettel',
    '036': 'Viettel', '037': 'Viettel', '038': 'Viettel', '039': 'Viettel',
    '070': 'Mobifone', '076': 'Mobifone', '077': 'Mobifone', '078': 'Mobifone', '079': 'Mobifone',
    '081': 'Vinaphone', '082': 'Vinaphone', '083': 'Vinaphone', '084': 'Vinaphone', '085': 'Vinaphone',
    '086': 'Vietnamobile', '087': 'Vietnamobile', '089': 'Vietnamobile',
    '088': 'Gmobile',
  };
  
  // Ngân hàng Việt Nam
  static const List<Map<String, String>> vietnamBanks = [
    {'code': 'VCB', 'name': 'Vietcombank', 'fullName': 'Ngân hàng TMCP Ngoại thương Việt Nam'},
    {'code': 'TCB', 'name': 'Techcombank', 'fullName': 'Ngân hàng TMCP Kỹ thương Việt Nam'},
    {'code': 'CTG', 'name': 'VietinBank', 'fullName': 'Ngân hàng TMCP Công thương Việt Nam'},
    {'code': 'BIDV', 'name': 'BIDV', 'fullName': 'Ngân hàng TMCP Đầu tư và Phát triển Việt Nam'},
    {'code': 'ACB', 'name': 'ACB', 'fullName': 'Ngân hàng TMCP Á Châu'},
    {'code': 'VPB', 'name': 'VPBank', 'fullName': 'Ngân hàng TMCP Việt Nam Thịnh vượng'},
    {'code': 'TPB', 'name': 'TPBank', 'fullName': 'Ngân hàng TMCP Tiên Phong'},
    {'code': 'STB', 'name': 'Sacombank', 'fullName': 'Ngân hàng TMCP Sài Gòn Thương tín'},
    {'code': 'HDB', 'name': 'HDBank', 'fullName': 'Ngân hàng TMCP Phát triển TP.HCM'},
    {'code': 'VIB', 'name': 'VIB', 'fullName': 'Ngân hàng TMCP Quốc tế Việt Nam'},
    {'code': 'SHB', 'name': 'SHB', 'fullName': 'Ngân hàng TMCP Sài Gòn - Hà Nội'},
    {'code': 'EIB', 'name': 'Eximbank', 'fullName': 'Ngân hàng TMCP Xuất nhập khẩu Việt Nam'},
    {'code': 'MSB', 'name': 'MSB', 'fullName': 'Ngân hàng TMCP Hàng hải'},
    {'code': 'OCB', 'name': 'OCB', 'fullName': 'Ngân hàng TMCP Phương Đông'},
    {'code': 'MBB', 'name': 'MBBank', 'fullName': 'Ngân hàng TMCP Quân đội'},
    {'code': 'NAB', 'name': 'Nam A Bank', 'fullName': 'Ngân hàng TMCP Nam Á'},
    {'code': 'VAB', 'name': 'VietABank', 'fullName': 'Ngân hàng TMCP Việt Á'},
    {'code': 'NCB', 'name': 'NCB', 'fullName': 'Ngân hàng TMCP Quốc dân'},
    {'code': 'SCB', 'name': 'SCB', 'fullName': 'Ngân hàng TMCP Sài Gòn'},
    {'code': 'LPB', 'name': 'LienVietPostBank', 'fullName': 'Ngân hàng TMCP Bưu điện Liên Việt'},
  ];
  
  // Đơn vị tính thông dụng
  static const Map<String, String> commonUnits = {
    'pcs': 'cái',
    'piece': 'cái', 
    'box': 'hộp',
    'pack': 'gói',
    'bag': 'túi',
    'bottle': 'chai',
    'can': 'lon',
    'kg': 'kg',
    'gram': 'gram',
    'liter': 'lít',
    'ml': 'ml',
    'dozen': 'tá',
    'pair': 'đôi',
    'set': 'bộ',
    'roll': 'cuộn',
    'sheet': 'tờ',
    'meter': 'mét',
    'cm': 'cm',
    'inch': 'inch',
  };
  
  // Trạng thái đơn hàng
  static const Map<String, Map<String, dynamic>> orderStatuses = {
    'draft': {'label': 'Nháp', 'color': 0xFF9E9E9E},
    'pending': {'label': 'Chờ xử lý', 'color': 0xFFFF9800},
    'confirmed': {'label': 'Đã xác nhận', 'color': 0xFF2196F3},
    'processing': {'label': 'Đang xử lý', 'color': 0xFF9C27B0},
    'ready': {'label': 'Sẵn sàng', 'color': 0xFF4CAF50},
    'shipping': {'label': 'Đang giao', 'color': 0xFF00BCD4},
    'delivered': {'label': 'Đã giao', 'color': 0xFF8BC34A},
    'completed': {'label': 'Hoàn thành', 'color': 0xFF4CAF50},
    'cancelled': {'label': 'Đã hủy', 'color': 0xFFF44336},
    'returned': {'label': 'Đã trả', 'color': 0xFFE91E63},
    'refunded': {'label': 'Đã hoàn tiền', 'color': 0xFF795548},
  };
  
  // Phương thức thanh toán
  static const Map<String, Map<String, dynamic>> paymentMethods = {
    'cash': {'label': 'Tiền mặt', 'icon': 'money', 'color': 0xFF4CAF50},
    'transfer': {'label': 'Chuyển khoển', 'icon': 'bank', 'color': 0xFF2196F3},
    'card': {'label': 'Thẻ', 'icon': 'credit_card', 'color': 0xFF9C27B0},
    'cod': {'label': 'COD', 'icon': 'local_shipping', 'color': 0xFFFF9800},
    'credit': {'label': 'Công nợ', 'icon': 'schedule', 'color': 0xFFF44336},
    'ewallet': {'label': 'Ví điện tử', 'icon': 'account_balance_wallet', 'color': 0xFF00BCD4},
  };
  
  // Loại khách hàng
  static const Map<String, String> customerTypes = {
    'retail': 'Khách lẻ',
    'wholesale': 'Khách sỉ', 
    'distributor': 'Nhà phân phối',
    'agent': 'Đại lý',
    'vip': 'Khách VIP',
    'corporate': 'Doanh nghiệp',
  };
  
  // Khu vực kinh doanh
  static const Map<String, List<String>> businessRegions = {
    'Miền Bắc': [
      'Hà Nội', 'Hải Phòng', 'Quảng Ninh', 'Hải Dương', 'Hưng Yên',
      'Thái Bình', 'Nam Định', 'Ninh Bình', 'Hà Nam', 'Vĩnh Phúc',
      'Bắc Ninh', 'Bắc Giang', 'Lạng Sơn', 'Cao Bằng', 'Hà Giang',
      'Lào Cai', 'Yên Bái', 'Tuyên Quang', 'Thái Nguyên', 'Phú Thọ',
      'Lai Châu', 'Điện Biên', 'Sơn La', 'Hòa Bình', 'Bắc Kạn'
    ],
    'Miền Trung': [
      'Thanh Hóa', 'Nghệ An', 'Hà Tĩnh', 'Quảng Bình', 'Quảng Trị',
      'Thừa Thiên Huế', 'Đà Nẵng', 'Quảng Nam', 'Quảng Ngãi', 'Bình Định',
      'Phú Yên', 'Khánh Hòa', 'Ninh Thuận', 'Bình Thuận', 'Kon Tum',
      'Gia Lai', 'Đắk Lắk', 'Đắk Nông', 'Lâm Đồng'
    ],
    'Miền Nam': [
      'TP. Hồ Chí Minh', 'Bà Rịa - Vũng Tàu', 'Bình Dương', 'Bình Phước',
      'Tây Ninh', 'Long An', 'Đồng Nai', 'Tiền Giang', 'Bến Tre',
      'Vĩnh Long', 'Trà Vinh', 'Đồng Tháp', 'An Giang', 'Kiên Giang',
      'Cần Thơ', 'Hậu Giang', 'Sóc Trăng', 'Bạc Liêu', 'Cà Mau'
    ],
  };
  
  // Regex patterns
  static const String phonePattern = r'^(0[3|5|7|8|9])[0-9]{8};
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,};
  static const String vietnamesePattern = r'^[a-zA-ZàáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđĐ\s]+;
  static const String numberPattern = r'^[0-9]+;
  static const String alphanumericPattern = r'^[a-zA-Z0-9]+;
  static const String vietnamesePhonePattern = r'^(0|\+84)[3|5|7|8|9][0-9]{8};
  
  // API Response codes
  static const Map<int, String> httpStatusMessages = {
    200: 'Thành công',
    201: 'Tạo mới thành công',
    400: 'Yêu cầu không hợp lệ',
    401: 'Chưa xác thực',
    403: 'Không có quyền truy cập',
    404: 'Không tìm thấy',
    422: 'Dữ liệu không hợp lệ',
    500: 'Lỗi máy chủ',
    502: 'Bad Gateway',
    503: 'Dịch vụ không khả dụng',
  };
  
  // App limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxOrderItems = 100;
  static const int maxCustomerNameLength = 100;
  static const int maxAddressLength = 200;
  static const int maxNoteLength = 500;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  
  // Date ranges for reports
  static const List<Map<String, dynamic>> reportDateRanges = [
    {'key': 'today', 'label': 'Hôm nay'},
    {'key': 'yesterday', 'label': 'Hôm qua'},
    {'key': 'this_week', 'label': 'Tuần này'},
    {'key': 'last_week', 'label': 'Tuần trước'},
    {'key': 'this_month', 'label': 'Tháng này'},
    {'key': 'last_month', 'label': 'Tháng trước'},
    {'key': 'this_quarter', 'label': 'Quý này'},
    {'key': 'last_quarter', 'label': 'Quý trước'},
    {'key': 'this_year', 'label': 'Năm nay'},
    {'key': 'last_year', 'label': 'Năm trước'},
    {'key': 'custom', 'label': 'Tùy chỉnh'},
  ];
  
  // Common error messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Lỗi kết nối mạng',
    'server_error': 'Lỗi máy chủ',
    'timeout_error': 'Hết thời gian chờ',
    'invalid_credentials': 'Thông tin đăng nhập không đúng',
    'access_denied': 'Không có quyền truy cập',
    'data_not_found': 'Không tìm thấy dữ liệu',
    'validation_error': 'Dữ liệu không hợp lệ',
    'duplicate_error': 'Dữ liệu đã tồn tại',
    'file_too_large': 'File quá lớn',
    'invalid_file_type': 'Loại file không được hỗ trợ',
    'camera_permission': 'Cần cấp quyền camera',
    'storage_permission': 'Cần cấp quyền truy cập bộ nhớ',
    'location_permission': 'Cần cấp quyền vị trí',
  };
  
  // Success messages
  static const Map<String, String> successMessages = {
    'save_success': 'Lưu thành công',
    'update_success': 'Cập nhật thành công',
    'delete_success': 'Xóa thành công',
    'create_success': 'Tạo mới thành công',
    'login_success': 'Đăng nhập thành công',
    'logout_success': 'Đăng xuất thành công',
    'sync_success': 'Đồng bộ thành công',
    'upload_success': 'Tải lên thành công',
    'send_success': 'Gửi thành công',
    'confirm_success': 'Xác nhận thành công',
  };
}