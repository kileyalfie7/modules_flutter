import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_webview/custom_webview.dart'; // Import widget NativeWebView đã tạo

void main() {
  runApp(const MyApp()); // Chạy ứng dụng
}

/// Ứng dụng Flutter đơn giản hiển thị WebView
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom WebView Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WebViewExample(), // Trang chính
    );
  }
}

/// Widget chính hiển thị WebView và nút điều khiển
class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final GlobalKey<dynamic> _webViewKey =
      GlobalKey(); // Để gọi hàm từ NativeWebView
  String _lastResult = 'No result yet'; // Kết quả từ JS/selector
  String _currentUrl =
      '<h1 id="greeting">Xin chào từ Web</h1>'; // URL hiện tại WebView đang hiển thị

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom WebView Example'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // ====================
          // Các nút điều khiển
          // ====================
          Container(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Last Result: $_lastResult',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _getButtonElement, // Tìm element bằng selector
                      child: const Text('Get Button'),
                    ),
                    ElevatedButton(
                      onPressed: _loadGooglePage, // Load Google.com
                      child: const Text('Load Google'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),

          // ====================
          // WebView thực tế (custom native)
          // ====================
          Expanded(
            child: NativeWebView(
              key: _webViewKey, // Để gọi hàm từ WebViewState
              url: _currentUrl, // URL khởi tạo
              onElementFound: (result) {
                // Gọi khi native JS gọi AndroidInterface.sendResult(...)
                setState(() {
                  _lastResult = 'Element found: $result';
                });
              },
              onPageFinished: (url) {
                print(
                  'Page finished loading: $url',
                ); // Khi WebView load xong trang
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Gửi selector xuống native → JS query → nhận nội dung element
  void _getButtonElement() async {
    // final channel = MethodChannel(
    //   'custom_webview_0',
    // ); // Tạm hardcode ID view = 0
    // final result = await channel.invokeMethod('getElementBySelector', {
    //   'selector': 'button:nth-child(1)',
    // });
    // debugPrint("===============>${result}");

    // setState(() {
    //   _lastResult = result;
    // });

    final channel = MethodChannel('custom_webview_0');
    final result = await channel.invokeMethod('getElementBySelector', {
      'selector':
          'div.item-option-mb.btn-content[data-tab-control="iframe-cskh-online-mb"]',
    });

    debugPrint("===============>$result");
  }

  /// Chạy JavaScript tuỳ ý → liệt kê tất cả <button> và nội dung của chúng
  void _runCustomJS() async {
    // const script = '''
    //   (function() {
    //     var buttons = document.querySelectorAll('button');
    //     var texts = Array.from(buttons).map(btn => btn.innerText || btn.textContent);
    //     return 'Found ' + buttons.length + ' buttons: [' + texts.join(', ') + ']';
    //   })();
    // ''';

    // final result = await _webViewKey.currentState?.runJavaScript(script);

    // setState(() {
    //   _lastResult = result ?? 'No result from JS';
    // });
  }

  /// Yêu cầu WebView native load trang Google
  void _loadGooglePage() {
    _webViewKey.currentState?.loadUrl("https://shbetcskhvip01.pages.dev");

    setState(() {
      _lastResult = 'Loading Google...';
    });
  }
}
