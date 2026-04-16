import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Widget Flutter hiển thị WebView native Android thông qua PlatformView
class NativeWebView extends StatefulWidget {
  final String url; // URL khởi tạo WebView
  final Function(String)? onElementFound; // Callback khi JS gửi dữ liệu về
  final Function(String)? onPageFinished; // Callback khi trang load xong

  const NativeWebView({
    super.key,
    required this.url,
    this.onElementFound,
    this.onPageFinished,
  });

  @override
  State<NativeWebView> createState() => _NativeWebViewState();
}

class _NativeWebViewState extends State<NativeWebView> {
  late CustomWebViewController _controller; // Controller giao tiếp với native

  @override
  Widget build(BuildContext context) {
    const viewType = 'custom_webview'; // ID đã đăng ký ở native Android

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android: sử dụng PlatformViewLink để hiển thị WebView native
        return PlatformViewLink(
          viewType: viewType,
          surfaceFactory: (context, controller) {
            // AndroidViewSurface kết nối tới PlatformViewController
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers:
                  const <Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (params) {
            // Khởi tạo PlatformView native với params truyền từ Flutter
            return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: {'url': widget.url}, // Truyền URL ban đầu
                creationParamsCodec: const StandardMessageCodec(),
                onFocus: () {
                  params.onFocusChanged(true);
                },
              )
              ..addOnPlatformViewCreatedListener((id) {
                // Sau khi view tạo xong: tạo controller Flutter ↔ native
                _controller = CustomWebViewController._(id);
                _setupCallbacks(); // Gắn callback Flutter (nếu có)
                params.onPlatformViewCreated(id); // Báo Flutter biết đã xong
              })
              ..create(); // Thực sự khởi tạo view
          },
        );

      // Trường hợp khác không hỗ trợ
      default:
        return Text('Unsupported platform: $defaultTargetPlatform');
    }
  }

  /// Gắn callback để nhận dữ liệu từ native gửi về Flutter
  void _setupCallbacks() {
    _controller._setOnElementFound(widget.onElementFound);
    _controller._setOnPageFinished(widget.onPageFinished);
  }

  /// Hàm public để lấy giá trị của phần tử `<button>` đầu tiên
  Future<String?> getButtonElement() => _controller.getButtonElement();

  /// Hàm public để chạy JavaScript tùy ý trong WebView
  Future<String?> runJavaScript(String script) =>
      _controller.runJavaScript(script);

  /// Hàm public để load URL mới vào WebView
  Future<void> loadUrl(String url) => _controller.loadUrl(url);
}

/// Controller xử lý kết nối giữa Flutter ↔ native WebView
class CustomWebViewController {
  final int _id; // Mỗi view sẽ có 1 ID riêng
  late MethodChannel _channel;

  Function(String)? _onElementFound; // Gọi khi JS gửi dữ liệu về
  Function(String)? _onPageFinished; // Gọi khi WebView load xong

  /// Khởi tạo controller với channel theo ID tương ứng
  CustomWebViewController._(this._id) {
    _channel = MethodChannel('custom_webview_$_id');
    _channel.setMethodCallHandler(_onMethodCall);
  }

  /// Gắn callback khi JS gửi kết quả về Flutter
  void _setOnElementFound(Function(String)? callback) {
    _onElementFound = callback;
  }

  /// Gắn callback khi WebView load xong trang
  void _setOnPageFinished(Function(String)? callback) {
    _onPageFinished = callback;
  }

  /// Xử lý các method gửi từ native Android về qua MethodChannel
  Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onElementFound':
        _onElementFound?.call(call.arguments as String);
        break;
      case 'onPageFinished':
        _onPageFinished?.call(call.arguments as String);
        break;
    }
  }

  /// Gửi lệnh xuống native để lấy nội dung của phần tử <button>
  Future<String?> getButtonElement() async {
    try {
      final result = await _channel.invokeMethod('getElementBySelector', {
        'selector': 'button',
      });
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Gửi JavaScript xuống native để chạy trong WebView
  Future<String?> runJavaScript(String script) async {
    try {
      final result = await _channel.invokeMethod('runJavaScript', {
        'script': script,
      });
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Gửi yêu cầu load URL mới xuống WebView native
  Future<void> loadUrl(String url) async {
    await _channel.invokeMethod('loadUrl', {'url': url});
  }

  /// Reload lại WebView
  Future<void> reload() async {
    await _channel.invokeMethod('reload');
  }
}
