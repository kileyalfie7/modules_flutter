# Flutter & OOP – Từ Cơ Bản Đến Nâng Cao (Cập nhật 2026)

## 1. Giới thiệu về Flutter

### Flutter là gì?

Flutter là UI framework mã nguồn mở của Google, cho phép xây dựng ứng dụng đa nền tảng (iOS, Android, Web, Desktop, Embedded) từ một codebase duy nhất bằng ngôn ngữ Dart.

**Đặc điểm nổi bật năm 2026:**
- **Hot Reload/Restart siêu nhanh**: Xem thay đổi UI ngay lập tức mà không mất state
- **Native Performance**: Biên dịch thành mã máy ARM/x64, không qua bridge như React Native
- **Impeller Rendering Engine**: Engine render mới thay thế Skia, loại bỏ shader jank
- **Widget-based Architecture**: Mọi thứ đều là Widget, dễ tái sử dụng và compose
- **Declarative UI**: UI phản ánh state hiện tại, tư duy giống React/SwiftUI
- **Single codebase**: iOS, Android, Web, Windows, macOS, Linux từ 1 codebase
- **Rich ecosystem**: 50,000+ packages trên pub.dev

**Lợi thế so với các framework khác năm 2026:**

| Tiêu chí | Flutter | React Native | Kotlin Multiplatform | Native |
|---|---|---|---|---|
| Performance | Gần native (Impeller) | Tốt (có bridge overhead) | Native 100% | Native 100% |
| Dev Speed | Rất nhanh (Hot Reload) | Nhanh | Trung bình | Chậm (2 codebase) |
| UI Consistency | 100% pixel-perfect | Phụ thuộc native component | Khác nhau | Khác nhau |
| Learning Curve | Trung bình (Dart) | Dễ (nếu biết React/JS) | Khó (Kotlin) | Khó (2 ngôn ngữ) |
| Community 2026 | Rất lớn, tăng mạnh | Rất lớn, ổn định | Đang tăng | Lớn nhưng tách biệt |
| Maintenance | 1 codebase | 1 codebase | Shared logic | 2 codebase |
| Web support | Tốt (CanvasKit/HTML) | Hạn chế | Không | Không |


### Kiến trúc cốt lõi: Widget Tree vs Element Tree vs Render Tree

Flutter dùng **3 cây song song** để quản lý UI. Đây là kiến thức nền tảng quan trọng nhất để hiểu Flutter hoạt động như thế nào.

#### Widget Tree (Configuration Tree)

Widget Tree là cây mô tả **cấu hình UI** – chỉ là blueprint, không phải UI thực tế.

```dart
// Widget Tree
Scaffold(
  appBar: AppBar(title: Text('Demo')),
  body: Center(
    child: Column(
      children: [
        Text('Hello'),
        ElevatedButton(onPressed: () {}, child: Text('Click')),
      ],
    ),
  ),
)
```

**Đặc điểm:**
- **Immutable**: Widget không thể thay đổi sau khi tạo
- **Lightweight**: Chỉ lưu configuration, rất nhẹ (vài bytes)
- **Rebuild thường xuyên**: Mỗi lần `setState()`, Widget Tree rebuild hoàn toàn
- **Cheap to create**: Tạo Widget rất nhanh vì chỉ là Dart object nhỏ

#### Element Tree (Lifecycle Tree)

Element Tree quản lý **lifecycle và state** của Widget. Là cầu nối giữa Widget và RenderObject.

```dart
// Flutter tự động tạo Element cho mỗi Widget
// StatefulElement  → giữ State object
// StatelessElement → quản lý StatelessWidget
// RenderObjectElement → kết nối với RenderObject

// BuildContext chính là Element!
Widget build(BuildContext context) {
  // context ở đây là Element của widget này
  return Container();
}
```

**Đặc điểm:**
- **Mutable**: Element có thể cập nhật mà không cần tạo mới
- **Long-lived**: Tồn tại lâu hơn Widget, không rebuild mỗi frame
- **Holds State**: `StatefulElement` giữ `State` object
- **IS BuildContext**: Element chính là `BuildContext`

#### Render Tree (Painting Tree)

Render Tree là cây thực sự **vẽ UI lên màn hình**. Mỗi node là một `RenderObject`.

```dart
// RenderObject thực hiện layout, paint, hit-testing
class MyRenderBox extends RenderBox {
  @override
  void performLayout() {
    size = constraints.biggest; // Tính toán kích thước
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(
      offset & size,
      Paint()..color = Colors.blue,
    );
  }
}
```

**Đặc điểm:**
- **Mutable**: RenderObject cập nhật trực tiếp
- **Expensive**: Tạo và layout RenderObject tốn kém
- **Persistent**: Tồn tại lâu, chỉ update khi cần
- **Handles layout & painting**: Thực hiện layout constraints và vẽ pixels

#### Mối quan hệ và Flow hoạt động

```
User Code (Widget – immutable config)
         ↓  createElement()
Element Tree (lifecycle, state, BuildContext)
         ↓  createRenderObject()
Render Tree (layout, paint, hit-test)
         ↓
Screen Pixels
```

**Khi `setState()` được gọi:**

```dart
setState(() { counter++; });

// Bước 1: Widget Tree rebuild hoàn toàn (tạo Widget objects mới)
// Bước 2: Element Tree so sánh Widget cũ vs mới:
//   - Cùng runtimeType + key → update Element (tái sử dụng)
//   - Khác runtimeType     → unmount Element cũ, mount Element mới
// Bước 3: Render Tree chỉ update nếu cần (markNeedsPaint / markNeedsLayout)
```

**Ví dụ minh họa tái sử dụng Element:**

```dart
// Trường hợp 1: Flutter TÁI SỬ DỤNG Element
// Trước setState: Text('Hello')
// Sau  setState: Text('World')
// → Cùng runtimeType (Text), Element được update, không tạo mới

// Trường hợp 2: Flutter TẠO MỚI Element
// Trước setState: Text('Hello')
// Sau  setState: Icon(Icons.star)
// → Khác runtimeType, Element cũ bị unmount, tạo Element mới
```

**Tại sao lập trình viên cần hiểu 3 cây này?**

```dart
// 1. PERFORMANCE: const tái sử dụng Widget và Element
// ❌ BAD
Widget build(BuildContext context) {
  return Column(children: [
    Text('Static text'),   // Rebuild mỗi lần setState
    Icon(Icons.star),      // Rebuild mỗi lần setState
  ]);
}

// ✅ GOOD
Widget build(BuildContext context) {
  return Column(children: const [
    Text('Static text'),   // Không rebuild, tái sử dụng
    Icon(Icons.star),      // Không rebuild, tái sử dụng
  ]);
}

// 2. DEBUG: Hiểu BuildContext để tránh lỗi
// ❌ BAD: context chưa có Scaffold
@override
Widget build(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(...); // Lỗi!
  return Scaffold(...);
}

// ✅ GOOD: Dùng Builder để lấy context bên trong Scaffold
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Builder(
      builder: (innerContext) {
        return ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(innerContext).showSnackBar(...),
          child: Text('Show'),
        );
      },
    ),
  );
}

// 3. KEY: Giúp Element Tree nhận diện đúng Widget
// Khi reorder list items, dùng Key để giữ state đúng chỗ
ListView(children: items.map((item) =>
  ItemWidget(key: ValueKey(item.id), item: item)
).toList())
```


### Flutter 2026: Impeller Rendering Engine

#### Impeller là gì?

**Impeller** là rendering engine thế hệ mới của Flutter, được thiết kế từ đầu để thay thế Skia và giải quyết vấn đề **shader compilation jank** – nguyên nhân chính gây giật lag trên Flutter trước đây.

**Vấn đề của Skia:**
- Skia compile shader **tại runtime** → frame đầu tiên render một hiệu ứng mới bị giật (jank)
- Thiết kế cho desktop, không tối ưu cho mobile GPU
- Không tận dụng được Metal (iOS) và Vulkan (Android) hiệu quả

#### Cách hoạt động

```
Skia (cũ):
App chạy → Gặp hiệu ứng mới → Compile shader (16-150ms JANK!) → Render smooth

Impeller (mới):
Build time → Precompile tất cả shaders → App chạy → Render smooth ngay từ frame 1
```

**Kiến trúc Impeller:**
1. **Precompiled shaders**: Tất cả shaders được compile tại build time, không có runtime compilation
2. **Explicit rendering pipeline**: Không có hidden state, dễ debug và predict
3. **Modern GPU APIs**: Metal trên iOS/macOS, Vulkan trên Android, DirectX trên Windows

#### Status trên các nền tảng (2026)

| Platform | Status | Default | API Backend |
|---|---|---|---|
| iOS | ✅ Stable | ✅ Yes (từ Flutter 3.10) | Metal |
| macOS | ✅ Stable | ✅ Yes | Metal |
| Android | ✅ Stable | ✅ Yes (từ Flutter 3.16) | Vulkan / OpenGL ES |
| Windows | ✅ Stable | ✅ Yes (từ Flutter 3.19) | DirectX 11 |
| Linux | 🚧 Preview | ❌ No | Vulkan |
| Web | ❌ Not supported | ❌ No (dùng CanvasKit/Skia) | WebGL |

#### Enable / Migrate từ Skia

```bash
# iOS/macOS/Android/Windows: Impeller là DEFAULT, không cần config

# Kiểm tra Impeller có đang chạy không
flutter run --verbose 2>&1 | grep -i impeller

# Tắt Impeller (không khuyến nghị, chỉ để debug)
flutter run --no-enable-impeller

# Bật Impeller trên Linux (preview)
flutter run --enable-impeller
```

```dart
// Kiểm tra runtime
import 'dart:ui' as ui;

void checkRenderer() {
  // Chỉ available trên Flutter 3.10+
  debugPrint('Using Impeller: ${ui.Impeller.enabled}');
}
```

**Migration checklist từ Skia sang Impeller:**
1. ✅ Update Flutter lên phiên bản mới nhất (`flutter upgrade`)
2. ✅ Test trên **device thật** (simulator không phản ánh đúng GPU performance)
3. ✅ Kiểm tra custom `CustomPainter` – một số shader phức tạp cần điều chỉnh
4. ✅ Kiểm tra `dart:ui` Canvas API – hầu hết tương thích
5. ✅ Profile với Flutter DevTools → Performance tab
6. ✅ Test trên cả low-end và high-end devices

#### So sánh Performance Skia vs Impeller

| Metric | Skia | Impeller | Cải thiện |
|---|---|---|---|
| Shader compilation jank | 16–150ms | 0ms | ✅ 100% |
| Average frame time | ~8.5ms | ~7ms | ✅ ~18% |
| 99th percentile frame | ~45ms | ~12ms | ✅ ~73% |
| GPU memory usage | ~120MB | ~95MB | ✅ ~21% |
| App startup time | ~850ms | ~720ms | ✅ ~15% |
| First meaningful paint | Chậm hơn | Nhanh hơn | ✅ |

> **Lưu ý**: Impeller tốt hơn Skia trên hầu hết trường hợp. Web vẫn dùng CanvasKit (Skia-based). Skia sẽ bị deprecated trong tương lai.

### Tại sao Flutter rất phù hợp với lập trình OOP

```dart
// 1. Everything is an Object – Mọi thứ đều là object
Widget button = ElevatedButton(onPressed: () {}, child: Text('OK'));
Color color = Colors.blue; // Color là object
Duration d = Duration(seconds: 1); // Duration là object

// 2. Composition over Inheritance – Flutter khuyến khích compose
Widget ui = Scaffold(
  body: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        UserAvatar(url: user.avatar),  // Reusable widget
        UserInfo(user: user),          // Reusable widget
      ],
    ),
  ),
);

// 3. Encapsulation – Đóng gói logic và UI
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(child: _buildContent());
  }

  Widget _buildContent() => ListTile(
    title: Text(product.name),
    subtitle: Text('\$${product.price}'),
  );
}

// 4. Polymorphism – Đa hình qua Widget hierarchy
abstract class BaseScreen extends StatelessWidget {
  String get title;
  Widget buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: buildBody(context),
    );
  }
}

class HomeScreen extends BaseScreen {
  @override
  String get title => 'Home';

  @override
  Widget buildBody(BuildContext context) => Center(child: Text('Home'));
}

// 5. Abstraction – Repository pattern
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
}
```

---

## 2. OOP trong Flutter (Dart OOP áp dụng thực tế)

### Class và Object trong Flutter

```dart
// Định nghĩa class
class User {
  final String id;
  final String name;
  final String email;
  int _loginCount = 0; // private field

  User({required this.id, required this.name, required this.email});

  // Getter
  int get loginCount => _loginCount;

  // Method
  void login() {
    _loginCount++;
    print('$name logged in. Total: $_loginCount');
  }

  // Override toString
  @override
  String toString() => 'User(id: $id, name: $name)';
}

// Tạo object
void main() {
  final user = User(id: '1', name: 'John', email: 'john@example.com');
  user.login();
  print(user); // User(id: 1, name: John)
}
```

**Widget là class trong Flutter:**
```dart
class PriceTag extends StatelessWidget {
  final double price;
  final String currency;
  final TextStyle? style;

  const PriceTag({
    required this.price,
    this.currency = 'USD',
    this.style,
  });

  String get formattedPrice => '$currency ${price.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Text(
      formattedPrice,
      style: style ?? Theme.of(context).textTheme.titleMedium,
    );
  }
}

// Sử dụng
PriceTag(price: 29.99)
PriceTag(price: 99.0, currency: 'VND', style: TextStyle(color: Colors.red))
```

### Constructor

#### Const Constructor

```dart
class AppColors {
  static const primary = Color(0xFF6200EE);
  static const secondary = Color(0xFF03DAC6);
}

// Const constructor – compile-time constant
class Spacing extends StatelessWidget {
  final double size;
  const Spacing(this.size);

  @override
  Widget build(BuildContext context) => SizedBox(height: size, width: size);
}

// ✅ Dùng const để Flutter tái sử dụng Widget instance
const Spacing(16)  // Luôn cùng 1 instance nếu size giống nhau
```

**Quy tắc const constructor:**
- Tất cả fields phải là `final`
- Không có logic trong constructor body
- Không gọi non-const constructor trong initializer

#### Named Constructor

```dart
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const ApiResponse._({this.data, this.error, required this.isSuccess});

  factory ApiResponse.success(T data) =>
      ApiResponse._(data: data, isSuccess: true);

  factory ApiResponse.failure(String error) =>
      ApiResponse._(error: error, isSuccess: false);

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json['success'] == true) {
      return ApiResponse.success(fromJson(json['data']));
    }
    return ApiResponse.failure(json['message'] ?? 'Unknown error');
  }
}

// Sử dụng
final response = ApiResponse.success(user);
final error = ApiResponse.failure('Network error');
```

#### Factory Constructor

```dart
// Singleton pattern
class AppConfig {
  static AppConfig? _instance;
  final String baseUrl;
  final bool isDev;

  AppConfig._({required this.baseUrl, required this.isDev});

  factory AppConfig.getInstance() {
    _instance ??= AppConfig._(
      baseUrl: 'https://api.example.com',
      isDev: false,
    );
    return _instance!;
  }
}

// Factory trả về subclass
abstract class Logger {
  void log(String message);

  factory Logger(String type) {
    return switch (type) {
      'console' => ConsoleLogger(),
      'file'    => FileLogger(),
      _         => throw ArgumentError('Unknown logger type: $type'),
    };
  }
}

class ConsoleLogger implements Logger {
  @override
  void log(String message) => print('[CONSOLE] $message');
}

class FileLogger implements Logger {
  @override
  void log(String message) => print('[FILE] $message');
}
```


### Inheritance (extends)

```dart
// Base Widget class
class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final double borderRadius;

  const BaseCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

// Kế thừa và mở rộng
class ElevatedCard extends BaseCard {
  final double elevation;

  const ElevatedCard({
    required Widget child,
    this.elevation = 8,
  }) : super(child: child);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      child: super.build(context), // Gọi parent build
    );
  }
}

class ClickableCard extends BaseCard {
  final VoidCallback onTap;

  const ClickableCard({
    required Widget child,
    required this.onTap,
  }) : super(child: child);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: super.build(context),
    );
  }
}
```

> **Best practice**: Trong Flutter, ưu tiên **composition** hơn inheritance cho Widget. Dùng inheritance khi có logic chung thực sự cần tái sử dụng (BaseScreen, BaseRepository...).

### Implements (Interface)

```dart
// Mọi class trong Dart đều là implicit interface
abstract class Cacheable {
  String get cacheKey;
  Duration get cacheDuration;
  Map<String, dynamic> toJson();
}

abstract class Serializable {
  Map<String, dynamic> toJson();
  // factory fromJson(...) – không thể định nghĩa trong interface
}

// Implements nhiều interfaces
class UserModel implements Cacheable, Serializable {
  final String id;
  final String name;

  const UserModel({required this.id, required this.name});

  @override
  String get cacheKey => 'user_$id';

  @override
  Duration get cacheDuration => const Duration(hours: 1);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: json['id'], name: json['name']);
}
```

**Repository Pattern với Interface:**
```dart
// Interface
abstract class UserRepository {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUserById(String id);
  Future<void> createUser(UserModel user);
  Future<void> deleteUser(String id);
}

// Remote implementation
class RemoteUserRepository implements UserRepository {
  final DioClient _client;
  RemoteUserRepository(this._client);

  @override
  Future<List<UserModel>> getUsers() async {
    final res = await _client.get('/users');
    return (res.data as List).map((e) => UserModel.fromJson(e)).toList();
  }

  @override
  Future<UserModel> getUserById(String id) async {
    final res = await _client.get('/users/$id');
    return UserModel.fromJson(res.data);
  }

  @override
  Future<void> createUser(UserModel user) =>
      _client.post('/users', data: user.toJson());

  @override
  Future<void> deleteUser(String id) => _client.delete('/users/$id');
}

// Mock implementation cho testing
class MockUserRepository implements UserRepository {
  final List<UserModel> _users = [];

  @override
  Future<List<UserModel>> getUsers() async => _users;

  @override
  Future<UserModel> getUserById(String id) async =>
      _users.firstWhere((u) => u.id == id);

  @override
  Future<void> createUser(UserModel user) async => _users.add(user);

  @override
  Future<void> deleteUser(String id) async =>
      _users.removeWhere((u) => u.id == id);
}
```

### Mixins (with, on)

```dart
// Mixin cơ bản
mixin Loggable {
  String get logTag => runtimeType.toString();

  void logInfo(String msg) => debugPrint('[$logTag] INFO: $msg');
  void logError(String msg) => debugPrint('[$logTag] ERROR: $msg');
}

mixin Validatable {
  List<String> validate();
  bool get isValid => validate().isEmpty;
}

// Mixin với `on` – chỉ dùng được với class cụ thể
mixin LoadingMixin on State {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  Future<T> withLoading<T>(Future<T> Function() action) async {
    setLoading(true);
    try {
      return await action();
    } finally {
      setLoading(false);
    }
  }
}

// Sử dụng trong StatefulWidget
class UserListScreen extends StatefulWidget {
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with LoadingMixin, Loggable {
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    await withLoading(() async {
      logInfo('Loading users...');
      users = await userRepository.getUsers();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const CircularProgressIndicator();
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (_, i) => ListTile(title: Text(users[i].name)),
    );
  }
}
```

**Mixins phổ biến trong Flutter:**

```dart
// 1. AutomaticKeepAliveClientMixin – Giữ state khi switch tab
class MyTabContent extends StatefulWidget {
  @override
  State<MyTabContent> createState() => _MyTabContentState();
}

class _MyTabContentState extends State<MyTabContent>
    with AutomaticKeepAliveClientMixin {
  int counter = 0;

  @override
  bool get wantKeepAlive => true; // Bắt buộc

  @override
  Widget build(BuildContext context) {
    super.build(context); // Bắt buộc gọi super
    return Column(children: [
      Text('Counter: $counter'),
      ElevatedButton(
        onPressed: () => setState(() => counter++),
        child: const Text('Increment'),
      ),
    ]);
  }
}

// 2. SingleTickerProviderStateMixin – 1 AnimationController
class FadeWidget extends StatefulWidget {
  @override
  State<FadeWidget> createState() => _FadeWidgetState();
}

class _FadeWidgetState extends State<FadeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, // this là TickerProvider
    duration: const Duration(milliseconds: 500),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const Text('Fading text'),
    );
  }
}

// 3. TickerProviderStateMixin – Nhiều AnimationController
class MultiAnimWidget extends StatefulWidget {
  @override
  State<MultiAnimWidget> createState() => _MultiAnimWidgetState();
}

class _MultiAnimWidgetState extends State<MultiAnimWidget>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 300),
  );
  late final AnimationController _slideController = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 500),
  );

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container();
}
```

### Extension Methods

```dart
// Extension cho BuildContext – cực kỳ phổ biến trong Flutter
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? colorScheme.error : null,
    ));
  }

  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
    MaterialPageRoute(builder: (_) => page),
  );

  void pop<T>([T? result]) => Navigator.of(this).pop(result);
}

// Extension cho String
extension StringX on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  bool get isEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  bool get isPhoneNumber =>
      RegExp(r'^\+?[0-9]{10,13}$').hasMatch(this);

  String truncate(int maxLength, {String ellipsis = '...'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';
}

// Extension cho DateTime
extension DateTimeX on DateTime {
  String get formatted => '$day/$month/$year';
  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }
}

// Extension cho List
extension ListX<T> on List<T> {
  List<T> get unique => toSet().toList();
  T? get firstOrNull => isEmpty ? null : first;
  List<List<T>> chunked(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size).clamp(0, length)));
    }
    return chunks;
  }
}

// Sử dụng trong Widget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        'hello world'.capitalize,
        style: context.textTheme.headlineMedium,
      ),
      ElevatedButton(
        onPressed: () => context.showSnackbar('Saved!'),
        child: Text('Save'),
      ),
    ]);
  }
}
```


### Class Modifiers (Dart 3+)

Dart 3 giới thiệu **class modifiers** để kiểm soát chặt chẽ hơn cách class được sử dụng.

```dart
// 1. final class – Không thể extend, implement, mixin bên ngoài library
final class DatabaseConfig {
  final String host;
  final int port;
  const DatabaseConfig({required this.host, required this.port});
}
// ❌ class MyConfig extends DatabaseConfig {} // Error ngoài library

// 2. base class – Có thể extend nhưng KHÔNG thể implement bên ngoài library
base class BaseService {
  void init() => debugPrint('Service initialized');
}
base class UserService extends BaseService {
  void getUser() {}
}
// ❌ class MockService implements BaseService {} // Error ngoài library

// 3. interface class – Chỉ có thể implement, KHÔNG thể extend bên ngoài library
interface class Printable {
  void print() {}
}
class Document implements Printable {
  @override
  void print() => debugPrint('Printing document');
}
// ❌ class MyPrintable extends Printable {} // Error ngoài library

// 4. sealed class – Không thể extend/implement bên ngoài library
// Tất cả subclass phải trong cùng library → exhaustive switch
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// Exhaustive switch – compiler biết tất cả cases
Widget buildAuthUI(AuthState state) {
  return switch (state) {
    AuthInitial()  => const LoginScreen(),
    AuthLoading()  => const CircularProgressIndicator(),
    AuthSuccess(user: final u) => HomeScreen(user: u),
    AuthFailure(message: final m) => ErrorWidget(m),
    // Không cần default! Compiler kiểm tra đủ cases
  };
}

// 5. abstract interface – Kết hợp abstract + interface
abstract interface class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);
}

// 6. mixin class – Có thể dùng như cả mixin lẫn class
mixin class Disposable {
  final List<StreamSubscription> _subscriptions = [];

  void addSubscription(StreamSubscription sub) => _subscriptions.add(sub);

  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }
}
```

### Bảng so sánh: abstract class vs interface vs mixin

| Tiêu chí | abstract class | interface (class) | mixin |
|---|---|---|---|
| Có thể có implementation | ✅ Có | ✅ Có | ✅ Có |
| Có thể có constructor | ✅ Có | ✅ Có | ❌ Không |
| Có thể extend | ✅ Có (1 class) | ❌ Không (ngoài lib) | ❌ Không |
| Có thể implement | ✅ Có | ✅ Có | ✅ Có |
| Có thể dùng với `with` | ❌ Không | ❌ Không | ✅ Có |
| Số lượng | 1 (single inheritance) | Nhiều | Nhiều |
| Mục đích chính | Base class có logic chung | Định nghĩa contract | Tái sử dụng code |
| Khi nào dùng | Có shared implementation | Chỉ cần contract/interface | Thêm behavior vào nhiều class |

### Bảng so sánh: extends vs implements vs with

| | extends | implements | with |
|---|---|---|---|
| Keyword | `extends` | `implements` | `with` |
| Số lượng | 1 | Nhiều | Nhiều |
| Kế thừa implementation | ✅ Có | ❌ Không (phải override tất cả) | ✅ Có |
| Kế thừa constructor | ✅ Có (qua super) | ❌ Không | ❌ Không |
| Dùng với | class, abstract class | class, abstract class, interface | mixin, mixin class |
| Mục đích | IS-A relationship | Contract/Interface | HAS-A behavior |
| Ví dụ Flutter | `StatelessWidget extends Widget` | `implements UserRepository` | `with SingleTickerProviderStateMixin` |

### Encapsulation, Polymorphism, Abstraction

```dart
// ENCAPSULATION – Ẩn implementation, expose interface
class CartService {
  final List<CartItem> _items = []; // private
  double _discount = 0; // private

  // Public API
  List<CartItem> get items => List.unmodifiable(_items);
  double get total => _items.fold(0, (sum, item) => sum + item.price) * (1 - _discount);
  int get itemCount => _items.length;

  void addItem(CartItem item) {
    final existing = _items.indexWhere((i) => i.id == item.id);
    if (existing >= 0) {
      _items[existing] = _items[existing].copyWith(
        quantity: _items[existing].quantity + 1,
      );
    } else {
      _items.add(item);
    }
  }

  void applyDiscount(String code) {
    _discount = _validateCoupon(code); // private method
  }

  double _validateCoupon(String code) {
    return switch (code) {
      'SAVE10' => 0.10,
      'SAVE20' => 0.20,
      _ => 0,
    };
  }
}

// POLYMORPHISM – Đa hình
abstract class PaymentMethod {
  String get name;
  Future<PaymentResult> processPayment(double amount);
}

class CreditCardPayment extends PaymentMethod {
  @override
  String get name => 'Credit Card';

  @override
  Future<PaymentResult> processPayment(double amount) async {
    // Xử lý credit card
    return PaymentResult.success('CC-${DateTime.now().millisecondsSinceEpoch}');
  }
}

class MoMoPayment extends PaymentMethod {
  @override
  String get name => 'MoMo';

  @override
  Future<PaymentResult> processPayment(double amount) async {
    // Xử lý MoMo
    return PaymentResult.success('MM-${DateTime.now().millisecondsSinceEpoch}');
  }
}

// Sử dụng polymorphism
class CheckoutService {
  Future<void> checkout(PaymentMethod method, double amount) async {
    final result = await method.processPayment(amount); // Đa hình
    if (result.isSuccess) {
      print('Payment via ${method.name} successful: ${result.transactionId}');
    }
  }
}

// ABSTRACTION – Ẩn complexity
abstract class NotificationService {
  Future<void> sendPushNotification(String userId, String message);
  Future<void> sendEmail(String email, String subject, String body);
}

// User chỉ cần biết interface, không cần biết implementation
class FirebaseNotificationService implements NotificationService {
  @override
  Future<void> sendPushNotification(String userId, String message) async {
    // Firebase FCM logic ẩn bên trong
  }

  @override
  Future<void> sendEmail(String email, String subject, String body) async {
    // SendGrid/SMTP logic ẩn bên trong
  }
}
```

### Best Practices OOP khi viết Widget, Model và Service

```dart
// ✅ WIDGET: Nhỏ, focused, const-friendly
// ❌ BAD: Widget quá lớn, làm nhiều việc
class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        // 200 dòng code UI...
      ]),
    );
  }
}

// ✅ GOOD: Tách nhỏ thành các widget riêng
class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const UserAvatarSection(),
        const UserInfoSection(),
        const UserStatsSection(),
        const UserActionsSection(),
      ]),
    );
  }
}

// ✅ MODEL: Immutable, copyWith, fromJson/toJson
class ProductModel {
  final String id;
  final String name;
  final double price;
  final int stock;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
  }) => ProductModel(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
    stock: stock ?? this.stock,
  );

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    stock: json['stock'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'stock': stock,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ✅ SERVICE: Single responsibility, dependency injection
class OrderService {
  final OrderRepository _orderRepo;
  final PaymentService _paymentService;
  final NotificationService _notificationService;

  const OrderService({
    required OrderRepository orderRepo,
    required PaymentService paymentService,
    required NotificationService notificationService,
  }) : _orderRepo = orderRepo,
       _paymentService = paymentService,
       _notificationService = notificationService;

  Future<Order> placeOrder(Cart cart, PaymentMethod payment) async {
    final order = await _orderRepo.createOrder(cart);
    await _paymentService.processPayment(order.total, payment);
    await _notificationService.sendOrderConfirmation(order);
    return order;
  }
}
```


---

## 3. Cơ bản Flutter

### Widget là gì?

Widget là **đơn vị cơ bản nhất** của Flutter UI. Mọi thứ trong Flutter đều là Widget: layout, text, button, padding, animation, gesture handler...

**Bảng so sánh StatelessWidget vs StatefulWidget:**

| Tiêu chí | StatelessWidget | StatefulWidget |
|---|---|---|
| State | Không có state nội bộ | Có State object riêng |
| Rebuild | Chỉ khi parent rebuild | Khi parent rebuild HOẶC setState() |
| Performance | Tốt hơn (ít overhead) | Có overhead của State |
| Khi dùng | UI chỉ phụ thuộc vào input | UI thay đổi theo thời gian |
| Lifecycle | build() | initState, build, didUpdateWidget, dispose |
| Ví dụ | Text, Icon, Card, Avatar | Counter, Form, Animation, Timer |
| const | ✅ Có thể dùng const | ❌ Không thể const |

```dart
// StatelessWidget – UI chỉ phụ thuộc vào props
class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const UserAvatar({required this.imageUrl, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: NetworkImage(imageUrl),
    );
  }
}

// StatefulWidget – UI thay đổi theo thời gian
class LikeButton extends StatefulWidget {
  final int initialCount;
  const LikeButton({this.initialCount = 0});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late int _count;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount; // Truy cập widget props qua widget.
  }

  @override
  void didUpdateWidget(LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCount != widget.initialCount) {
      _count = widget.initialCount;
    }
  }

  void _toggle() {
    setState(() {
      _isLiked = !_isLiked;
      _count += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Row(children: [
        Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : Colors.grey),
        const SizedBox(width: 4),
        Text('$_count'),
      ]),
    );
  }

  @override
  void dispose() {
    // Cleanup: cancel timers, close streams, dispose controllers
    super.dispose();
  }
}
```

**StatefulWidget Lifecycle:**
```
Constructor → createState()
                    ↓
              initState()      ← Khởi tạo, subscribe streams
                    ↓
              didChangeDependencies() ← InheritedWidget thay đổi
                    ↓
              build()          ← Vẽ UI
                    ↓
              didUpdateWidget() ← Parent rebuild với props mới
                    ↓
              setState() → build() ← Lặp lại
                    ↓
              deactivate()     ← Widget bị remove khỏi tree
                    ↓
              dispose()        ← Cleanup, cancel subscriptions
```

### BuildContext và cách hoạt động

```dart
// BuildContext là Element – vị trí của Widget trong Widget Tree
// Dùng để:
// 1. Truy cập InheritedWidget (Theme, MediaQuery, Navigator...)
// 2. Tìm ancestor widget
// 3. Hiển thị dialogs, snackbars

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Truy cập Theme
    final theme = Theme.of(context);

    // Truy cập MediaQuery
    final size = MediaQuery.sizeOf(context); // Flutter 3.10+ dùng sizeOf thay of

    // Truy cập Navigator
    final navigator = Navigator.of(context);

    return Container();
  }
}

// ⚠️ PITFALL: Dùng context sau async gap
class _MyState extends State<MyWidget> {
  Future<void> _doSomething() async {
    await Future.delayed(Duration(seconds: 1));

    // ❌ BAD: context có thể không còn valid
    Navigator.of(context).pop();

    // ✅ GOOD: Kiểm tra mounted trước
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Container();
}
```

### Các Widget cơ bản

```dart
// Container – Box model widget
Container(
  width: 200,
  height: 100,
  margin: const EdgeInsets.all(8),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.blueAccent, width: 2),
    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
    gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
  ),
  child: const Text('Hello', style: TextStyle(color: Colors.white)),
)

// Row – Horizontal layout
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const Icon(Icons.star),
    const Expanded(child: Text('Title')), // Chiếm không gian còn lại
    const SizedBox(width: 8),
    ElevatedButton(onPressed: () {}, child: const Text('Action')),
  ],
)

// Column – Vertical layout
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    const Text('Title'),
    const SizedBox(height: 16),
    const Flexible(child: Text('Flexible takes available space')),
    const Expanded(child: Text('Expanded fills remaining space')),
  ],
)

// Stack – Overlay layout
Stack(
  alignment: Alignment.center,
  children: [
    Image.network('https://example.com/image.jpg'),
    Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    ),
    const Positioned(
      top: 8,
      left: 8,
      child: Chip(label: Text('NEW')),
    ),
  ],
)

// Expanded vs Flexible
Row(children: [
  Expanded(flex: 2, child: Container(color: Colors.red)),    // 2/3 width
  Expanded(flex: 1, child: Container(color: Colors.blue)),   // 1/3 width
  Flexible(child: Container(color: Colors.green)),           // Tối đa available space
])

// SizedBox – Spacing và fixed size
const SizedBox(height: 16)  // Vertical spacing
const SizedBox(width: 8)    // Horizontal spacing
const SizedBox(height: 200, width: 200, child: Text('Fixed size'))
const SizedBox.expand(child: Text('Fill parent'))
```

### Material Design vs Cupertino

```dart
// Material Design (Android-style, cross-platform)
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true, // Material 3 là default từ Flutter 3.16+
  ),
  home: Scaffold(
    appBar: AppBar(title: const Text('Material')),
    body: Column(children: [
      ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
      FilledButton(onPressed: () {}, child: const Text('Filled')),
      OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
      TextButton(onPressed: () {}, child: const Text('Text')),
    ]),
    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    ),
  ),
)

// Cupertino (iOS-style)
CupertinoApp(
  home: CupertinoPageScaffold(
    navigationBar: const CupertinoNavigationBar(middle: Text('Cupertino')),
    child: Column(children: [
      CupertinoButton(onPressed: () {}, child: const Text('Button')),
      CupertinoButton.filled(onPressed: () {}, child: const Text('Filled')),
      const CupertinoActivityIndicator(),
      CupertinoSwitch(value: true, onChanged: (_) {}),
    ]),
  ),
)

// Platform-adaptive widget
Widget buildButton(BuildContext context) {
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return CupertinoButton(onPressed: () {}, child: const Text('iOS Button'));
  }
  return ElevatedButton(onPressed: () {}, child: const Text('Android Button'));
}
```

### GestureDetector và InkWell

```dart
// GestureDetector – Detect mọi loại gesture
GestureDetector(
  onTap: () => print('Tapped'),
  onDoubleTap: () => print('Double tapped'),
  onLongPress: () => print('Long pressed'),
  onPanUpdate: (details) => print('Dragging: ${details.delta}'),
  onScaleUpdate: (details) => print('Scaling: ${details.scale}'),
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
    child: const Center(child: Text('Gesture')),
  ),
)

// InkWell – Material ripple effect
InkWell(
  onTap: () => print('Tapped with ripple'),
  borderRadius: BorderRadius.circular(8),
  splashColor: Colors.blue.withOpacity(0.3),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: const Text('Tap me'),
  ),
)

// Ink – Dùng khi InkWell nằm trong Container có decoration
Ink(
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
  ),
  child: InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(8),
    child: const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Ink + InkWell', style: TextStyle(color: Colors.white)),
    ),
  ),
)
```

### Navigation

#### Navigator 1.0 (Imperative)

```dart
// Push – Đến màn hình mới
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const DetailScreen()),
);

// Push với result
final result = await Navigator.of(context).push<String>(
  MaterialPageRoute(builder: (_) => const InputScreen()),
);
print('Result: $result');

// Pop với result
Navigator.of(context).pop('User input result');

// Push và xóa tất cả stack
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const HomeScreen()),
  (route) => false, // Xóa tất cả
);

// Named routes
Navigator.of(context).pushNamed('/detail', arguments: {'id': '123'});

// Nhận arguments
final args = ModalRoute.of(context)!.settings.arguments as Map;
```

#### Navigator 2.0 (Declarative) – Cơ bản

```dart
// Navigator 2.0 dùng Router widget
// Trong thực tế, dùng GoRouter thay vì implement thủ công
// Xem phần GoRouter ở Section 5 để biết chi tiết
```

---

## 4. Trung cấp Flutter

### List và ListView chi tiết

#### Các loại ListView

```dart
// 1. ListView – Đơn giản, render TẤT CẢ items ngay lập tức
// ⚠️ Chỉ dùng khi số lượng items ÍT (< 20)
ListView(
  padding: const EdgeInsets.all(16),
  children: [
    ListTile(title: Text('Item 1')),
    ListTile(title: Text('Item 2')),
    // ...
  ],
)

// 2. ListView.builder – Lazy loading, chỉ render items visible
// ✅ Dùng cho danh sách dài
ListView.builder(
  itemCount: items.length,
  itemExtent: 72, // ✅ Performance: fixed height giúp Flutter tính scroll position nhanh
  itemBuilder: (context, index) {
    final item = items[index];
    return ListTile(
      key: ValueKey(item.id), // ✅ Luôn dùng key
      title: Text(item.name),
      subtitle: Text(item.description),
    );
  },
)

// 3. ListView.separated – Có separator giữa items
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (context, index) => const Divider(height: 1),
  itemBuilder: (context, index) => ListTile(
    title: Text(items[index].name),
  ),
)

// 4. ListView.custom – Tùy chỉnh hoàn toàn với SliverChildDelegate
ListView.custom(
  childrenDelegate: SliverChildBuilderDelegate(
    (context, index) => ListTile(title: Text('Item $index')),
    childCount: 100,
    findChildIndexCallback: (key) {
      // Giúp Flutter tìm lại item sau khi reorder
      final valueKey = key as ValueKey<String>;
      return items.indexWhere((item) => item.id == valueKey.value);
    },
  ),
)
```

**Bảng so sánh các loại ListView:**

| | ListView | ListView.builder | ListView.separated | ListView.custom |
|---|---|---|---|---|
| Lazy loading | ❌ Không | ✅ Có | ✅ Có | ✅ Có |
| Separator | ❌ Không | ❌ Không | ✅ Built-in | ✅ Custom |
| Performance | Kém (nhiều items) | Tốt | Tốt | Tốt nhất |
| Khi dùng | < 20 items | Danh sách dài | Cần separator | Cần tùy chỉnh cao |

#### Infinite Scrolling và Pagination

```dart
class InfiniteListScreen extends StatefulWidget {
  @override
  State<InfiniteListScreen> createState() => _InfiniteListScreenState();
}

class _InfiniteListScreenState extends State<InfiniteListScreen> {
  final List<Product> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Trigger load khi còn 200px đến cuối
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final newItems = await productRepository.getProducts(
        page: _page,
        pageSize: _pageSize,
      );
      setState(() {
        _items.addAll(newItems);
        _page++;
        _hasMore = newItems.length == _pageSize;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _page = 1;
      _hasMore = true;
    });
    await _loadMore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemExtent: 80,
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return ProductTile(
            key: ValueKey(_items[index].id),
            product: _items[index],
          );
        },
      ),
    );
  }
}
```

#### Performance Optimization cho ListView lớn

```dart
// 1. itemExtent – Fixed height items (QUAN TRỌNG NHẤT)
ListView.builder(
  itemExtent: 72.0, // Flutter không cần layout từng item để tính scroll
  itemBuilder: (_, i) => ItemWidget(item: items[i]),
)

// 2. prototypeItem – Khi height không fixed nhưng có prototype
ListView.builder(
  prototypeItem: const ItemWidget(item: dummyItem),
  itemBuilder: (_, i) => ItemWidget(item: items[i]),
)

// 3. cacheExtent – Số pixels render trước/sau viewport
ListView.builder(
  cacheExtent: 500, // Render thêm 500px ngoài viewport
  itemBuilder: (_, i) => ItemWidget(item: items[i]),
)

// 4. const constructor cho items không thay đổi
ListView.builder(
  itemBuilder: (_, i) => const StaticItem(), // const nếu không có dynamic data
)

// 5. RepaintBoundary – Isolate repaint cho items phức tạp
ListView.builder(
  itemBuilder: (_, i) => RepaintBoundary(
    child: ComplexItemWidget(item: items[i]),
  ),
)

// 6. addAutomaticKeepAlives: false – Tắt keep alive nếu không cần
ListView.builder(
  addAutomaticKeepAlives: false,
  addRepaintBoundaries: false, // Tắt nếu items đơn giản
  itemBuilder: (_, i) => SimpleItem(item: items[i]),
)
```

### GridView

```dart
// GridView.count – Số cột cố định
GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
  childAspectRatio: 0.75,
  padding: const EdgeInsets.all(16),
  children: products.map((p) => ProductCard(product: p)).toList(),
)

// GridView.builder – Lazy loading (khuyến nghị)
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 0.75,
  ),
  itemCount: products.length,
  itemBuilder: (context, index) => ProductCard(
    key: ValueKey(products[index].id),
    product: products[index],
  ),
)

// GridView.extent – Chiều rộng tối đa mỗi item
GridView.extent(
  maxCrossAxisExtent: 200, // Mỗi item tối đa 200px wide
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
  children: items.map((i) => ItemCard(item: i)).toList(),
)
```

### Form, TextFormField, Validation, FocusNode

```dart
class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Process login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Email is required';
            if (!value.isEmail) return 'Invalid email format';
            return null;
          },
          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Password is required';
            if (value.length < 8) return 'Password must be at least 8 characters';
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submit,
            child: const Text('Login'),
          ),
        ),
      ]),
    );
  }
}
```

### FutureBuilder & StreamBuilder

```dart
// FutureBuilder – Xử lý async data
FutureBuilder<List<Product>>(
  future: productRepository.getProducts(),
  builder: (context, snapshot) {
    return switch (snapshot.connectionState) {
      ConnectionState.waiting => const Center(child: CircularProgressIndicator()),
      ConnectionState.done when snapshot.hasError =>
        Center(child: Text('Error: ${snapshot.error}')),
      ConnectionState.done when snapshot.hasData =>
        ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (_, i) => ProductTile(product: snapshot.data![i]),
        ),
      _ => const SizedBox.shrink(),
    };
  },
)

// StreamBuilder – Xử lý real-time data
StreamBuilder<List<Message>>(
  stream: chatRepository.messagesStream(chatId),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    final messages = snapshot.data ?? [];
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (_, i) => MessageBubble(message: messages[i]),
    );
  },
)
```

### Theme & ThemeData (Dynamic Theme)

```dart
// Định nghĩa theme
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6200EE),
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16, height: 1.5),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6200EE),
      brightness: Brightness.dark,
    ),
  );
}

// Dynamic theme với Provider/Riverpod
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// MaterialApp với dynamic theme
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeNotifier.themeMode,
  home: const HomeScreen(),
)
```

### Responsive UI

```dart
// MediaQuery – Thông tin màn hình
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context); // Flutter 3.10+: sizeOf thay vì of
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.width >= 768;

    return isTablet
        ? _buildTabletLayout(context)
        : _buildPhoneLayout(context);
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(children: [
      const SizedBox(width: 300, child: SidebarWidget()),
      const Expanded(child: ContentWidget()),
    ]);
  }

  Widget _buildPhoneLayout(BuildContext context) {
    return const ContentWidget();
  }
}

// LayoutBuilder – Responsive dựa trên parent constraints
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= 1200) {
      return const DesktopLayout();
    } else if (constraints.maxWidth >= 768) {
      return const TabletLayout();
    }
    return const MobileLayout();
  },
)

// OrientationBuilder – Responsive theo orientation
OrientationBuilder(
  builder: (context, orientation) {
    return GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
      children: items.map((i) => ItemCard(item: i)).toList(),
    );
  },
)
```

### Animation cơ bản

```dart
// Implicit animations – Đơn giản nhất
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: _isExpanded ? 200 : 100,
  height: _isExpanded ? 200 : 100,
  color: _isExpanded ? Colors.blue : Colors.red,
  child: const Text('Animated'),
)

AnimatedOpacity(
  duration: const Duration(milliseconds: 300),
  opacity: _isVisible ? 1.0 : 0.0,
  child: const Text('Fading'),
)

AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: Text('$_counter', key: ValueKey(_counter)), // Key bắt buộc
)

// AnimatedBuilder – Explicit animation
class RotatingWidget extends StatefulWidget {
  @override
  State<RotatingWidget> createState() => _RotatingWidgetState();
}

class _RotatingWidgetState extends State<RotatingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  late final Animation<double> _rotation = Tween<double>(
    begin: 0,
    end: 2 * 3.14159,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, child) => Transform.rotate(
        angle: _rotation.value,
        child: child,
      ),
      child: const Icon(Icons.refresh, size: 48), // child không rebuild
    );
  }
}
```


---

## 5. Nâng cao Flutter

### Widget Key – Phần sâu

#### Widget Key là gì và vai trò quan trọng

**Key** giúp Flutter **nhận diện và phân biệt** các Widget trong Element Tree. Khi Widget Tree rebuild, Flutter dùng Key để quyết định Element nào tương ứng với Widget nào.

**Khi nào cần Key:**
- Reorder items trong list
- Thêm/xóa items ở đầu/giữa list
- Giữ state của Widget khi vị trí thay đổi
- GlobalKey để truy cập State từ bên ngoài

```dart
// Vấn đề khi không có Key
class ColorBox extends StatefulWidget {
  final Color color;
  const ColorBox({required this.color});

  @override
  State<ColorBox> createState() => _ColorBoxState();
}

class _ColorBoxState extends State<ColorBox> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => counter++),
      child: Container(
        color: widget.color,
        child: Text('$counter'),
      ),
    );
  }
}

// ❌ BUG: Swap 2 boxes → counter không đi theo box
// Flutter match by position, không phải by identity
Row(children: [
  if (showBlue) ColorBox(color: Colors.blue),
  ColorBox(color: Colors.red),
])

// ✅ FIX: Dùng Key
Row(children: [
  if (showBlue) ColorBox(key: const ValueKey('blue'), color: Colors.blue),
  ColorBox(key: const ValueKey('red'), color: Colors.red),
])
```

#### Các loại Key

```dart
// 1. ValueKey – Dùng giá trị để identify (phổ biến nhất)
ListView.builder(
  itemBuilder: (_, i) => ListTile(
    key: ValueKey(items[i].id), // String, int, enum...
    title: Text(items[i].name),
  ),
)

// 2. ObjectKey – Dùng object identity
ListView.builder(
  itemBuilder: (_, i) => ListTile(
    key: ObjectKey(items[i]), // Dùng object reference
    title: Text(items[i].name),
  ),
)

// 3. UniqueKey – Luôn unique, force rebuild
// ⚠️ Dùng cẩn thận: tạo mới mỗi lần build → luôn rebuild
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: Image.network(
    imageUrl,
    key: UniqueKey(), // Force rebuild khi URL thay đổi
  ),
)

// 4. GlobalKey – Truy cập State và RenderObject từ bên ngoài
final formKey = GlobalKey<FormState>();
final scaffoldKey = GlobalKey<ScaffoldState>();

// Validate form từ bên ngoài
formKey.currentState?.validate();

// Mở drawer từ bên ngoài
scaffoldKey.currentState?.openDrawer();

// Lấy RenderBox để tính position
final renderBox = myKey.currentContext?.findRenderObject() as RenderBox?;
final position = renderBox?.localToGlobal(Offset.zero);
```

**Bảng so sánh các loại Key:**

| Key | Dựa trên | Unique? | Performance | Khi dùng |
|---|---|---|---|---|
| ValueKey | Giá trị (id, string) | Trong cùng parent | Tốt | List items có id |
| ObjectKey | Object reference | Trong cùng parent | Tốt | Object không có id |
| UniqueKey | Random | Luôn unique | Kém (force rebuild) | Force rebuild |
| GlobalKey | Global registry | Toàn app | Kém (global lookup) | Truy cập State/RenderObject |
| PageStorageKey | Giá trị | Trong PageStorage | Tốt | Lưu scroll position |

#### Common pitfalls khi dùng Key

```dart
// ❌ PITFALL 1: Tạo Key trong build() → mỗi lần rebuild tạo Key mới
Widget build(BuildContext context) {
  return ListView.builder(
    itemBuilder: (_, i) => ItemWidget(
      key: UniqueKey(), // ❌ Tạo mới mỗi lần build!
    ),
  );
}

// ✅ FIX: Dùng ValueKey với stable identifier
key: ValueKey(items[i].id)

// ❌ PITFALL 2: GlobalKey tạo trong build()
Widget build(BuildContext context) {
  final key = GlobalKey(); // ❌ Tạo mới mỗi lần!
  return Form(key: key);
}

// ✅ FIX: Khai báo GlobalKey là field của State
class _MyState extends State<MyWidget> {
  final _formKey = GlobalKey<FormState>(); // ✅ Tạo 1 lần

  @override
  Widget build(BuildContext context) => Form(key: _formKey);
}

// ❌ PITFALL 3: Dùng GlobalKey quá nhiều → performance issue
// GlobalKey có overhead vì phải lookup trong global registry
// ✅ Ưu tiên ValueKey/ObjectKey, chỉ dùng GlobalKey khi thực sự cần
```

---

### State Management – Phần CHI TIẾT

#### 1. setState + InheritedWidget

**setState** là cách đơn giản nhất để quản lý state local.

```dart
// setState – Local state
class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;

  void _increment() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Count: $_count'),
      ElevatedButton(onPressed: _increment, child: const Text('+')),
    ]);
  }
}
```

**InheritedWidget** – Chia sẻ data xuống Widget Tree mà không cần pass qua constructor.

```dart
// Định nghĩa InheritedWidget
class AppStateWidget extends InheritedWidget {
  final int counter;
  final VoidCallback increment;

  const AppStateWidget({
    required this.counter,
    required this.increment,
    required super.child,
  });

  static AppStateWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateWidget>()!;
  }

  @override
  bool updateShouldNotify(AppStateWidget oldWidget) {
    return counter != oldWidget.counter;
  }
}

// Sử dụng
class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppStateWidget.of(context); // Subscribe to changes
    return Text('Count: ${state.counter}');
  }
}
```

**Ưu/Nhược điểm setState + InheritedWidget:**
- ✅ Built-in, không cần package
- ✅ Đơn giản, dễ hiểu
- ❌ setState chỉ cho local state
- ❌ InheritedWidget boilerplate nhiều
- ❌ Khó scale cho app lớn

#### 2. Provider

**Provider** là wrapper của InheritedWidget, dễ dùng hơn nhiều.

```dart
// pubspec.yaml: provider: ^6.1.2

// Model
class CartModel extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get total => _items.fold(0, (sum, p) => sum + p.price);

  void addItem(Product product) {
    _items.add(product);
    notifyListeners(); // Notify tất cả listeners
  }

  void removeItem(String id) {
    _items.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}

// Setup
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
        Provider(create: (_) => ApiService()),
      ],
      child: const MyApp(),
    ),
  );
}

// Consumer – Rebuild khi model thay đổi
Consumer<CartModel>(
  builder: (context, cart, child) {
    return Column(children: [
      child!, // Không rebuild (static content)
      Text('Items: ${cart.itemCount}'),
      Text('Total: \$${cart.total}'),
    ]);
  },
  child: const Text('Cart'), // Static, không rebuild
)

// Selector – Chỉ rebuild khi giá trị cụ thể thay đổi
Selector<CartModel, int>(
  selector: (_, cart) => cart.itemCount,
  builder: (context, count, _) => Badge(label: Text('$count')),
)

// context.watch – Rebuild khi bất kỳ thay đổi
final cart = context.watch<CartModel>();

// context.read – Không subscribe, chỉ đọc 1 lần
context.read<CartModel>().addItem(product);

// context.select – Chỉ rebuild khi selector thay đổi
final count = context.select<CartModel, int>((cart) => cart.itemCount);
```

**Ưu/Nhược điểm Provider:**
- ✅ Đơn giản, dễ học
- ✅ Flutter team recommend
- ✅ Tốt cho app vừa
- ❌ context.watch có thể gây rebuild không cần thiết
- ❌ Khó test hơn Riverpod
- ❌ Không có compile-time safety

#### 3. Riverpod

**Riverpod** là evolution của Provider, không phụ thuộc BuildContext, type-safe hơn.

```dart
// pubspec.yaml: flutter_riverpod: ^2.5.1

// Setup
void main() {
  runApp(
    const ProviderScope(child: MyApp()), // Bắt buộc wrap ProviderScope
  );
}

// Các loại Provider
// 1. Provider – Giá trị bất biến
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// 2. StateProvider – Simple state
final counterProvider = StateProvider<int>((ref) => 0);

// 3. FutureProvider – Async data
final usersProvider = FutureProvider<List<User>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getUsers();
});

// 4. StreamProvider – Stream data
final messagesProvider = StreamProvider.family<List<Message>, String>(
  (ref, chatId) => chatRepository.messagesStream(chatId),
);

// 5. NotifierProvider (Riverpod 2.x) – Thay thế StateNotifierProvider
@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  List<Product> build() => []; // Initial state

  void addItem(Product product) {
    state = [...state, product];
  }

  void removeItem(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

// 6. AsyncNotifierProvider – Async state
@riverpod
class UserList extends _$UserList {
  @override
  Future<List<User>> build() async {
    return ref.watch(apiServiceProvider).getUsers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(apiServiceProvider).getUsers());
  }
}

// Sử dụng trong Widget
class CartScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartNotifierProvider);
    final users = ref.watch(userListProvider);

    return Column(children: [
      // AsyncValue handling
      users.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) => ListTile(title: Text(list[i].name)),
        ),
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      ),

      // Cart items
      ...cart.map((p) => ListTile(
        title: Text(p.name),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => ref.read(cartNotifierProvider.notifier).removeItem(p.id),
        ),
      )),
    ]);
  }
}

// AutoDispose – Tự động dispose khi không còn listener
@riverpod
Future<User> userDetail(UserDetailRef ref, String id) async {
  // Tự động cancel khi widget unmount
  return apiService.getUserById(id);
}

// Family – Provider với parameter
final productProvider = FutureProvider.family<Product, String>(
  (ref, id) => ref.watch(apiServiceProvider).getProduct(id),
);

// .select() – Chỉ rebuild khi field cụ thể thay đổi
final userName = ref.watch(userProvider.select((user) => user.name));

// .listen() – Side effects
ref.listen<int>(counterProvider, (previous, next) {
  if (next >= 10) showDialog(...);
});
```

**Ưu/Nhược điểm Riverpod:**
- ✅ Type-safe, compile-time errors
- ✅ Không phụ thuộc BuildContext
- ✅ Dễ test (không cần Widget tree)
- ✅ AutoDispose tự động cleanup
- ✅ Code generation với @riverpod
- ❌ Learning curve cao hơn Provider
- ❌ Boilerplate với code gen setup

#### 4. Bloc / Cubit

**Bloc** tách biệt hoàn toàn business logic khỏi UI qua Events và States.

```dart
// pubspec.yaml: flutter_bloc: ^8.1.5, freezed: ^2.4.7

// State với freezed
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.success(User user) = _Success;
  const factory AuthState.failure(String message) = _Failure;
}

// Event
@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested(String email, String password) = _LoginRequested;
  const factory AuthEvent.logoutRequested() = _LogoutRequested;
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepo;

  AuthBloc(this._authRepo) : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.map(
        loginRequested: (e) => _onLogin(e, emit),
        logoutRequested: (e) => _onLogout(e, emit),
      );
    });
  }

  Future<void> _onLogin(_LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepo.login(event.email, event.password);
      emit(AuthState.success(user));
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> _onLogout(_LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepo.logout();
    emit(const AuthState.initial());
  }
}

// Cubit – Đơn giản hơn Bloc (không có Event)
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}

// Setup
BlocProvider(
  create: (context) => AuthBloc(context.read<AuthRepository>()),
  child: const AuthScreen(),
)

// Sử dụng trong Widget
class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeMap(
          success: (_) => context.go('/home'),
          failure: (f) => context.showSnackbar(f.message, isError: true),
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.map(
          initial: (_) => const LoginForm(),
          loading: (_) => const CircularProgressIndicator(),
          success: (s) => Text('Welcome ${s.user.name}'),
          failure: (f) => Column(children: [
            Text('Error: ${f.message}'),
            const LoginForm(),
          ]),
        );
      },
    );
  }
}

// BlocBuilder – Chỉ rebuild UI
BlocBuilder<CounterCubit, int>(
  buildWhen: (previous, current) => previous != current,
  builder: (context, count) => Text('$count'),
)

// BlocListener – Chỉ side effects
BlocListener<AuthBloc, AuthState>(
  listenWhen: (previous, current) => current is _Success,
  listener: (context, state) => Navigator.pushNamed(context, '/home'),
  child: const LoginForm(),
)
```

**Ưu/Nhược điểm Bloc:**
- ✅ Tách biệt hoàn toàn business logic
- ✅ Dễ test (pure functions)
- ✅ Predictable state flow
- ✅ Tốt cho team lớn
- ❌ Boilerplate nhiều nhất
- ❌ Learning curve cao
- ❌ Overkill cho app nhỏ

#### 5. GetX

```dart
// pubspec.yaml: get: ^4.6.6

// Controller
class CounterController extends GetxController {
  // Reactive state với .obs
  final count = 0.obs;
  final isLoading = false.obs;
  final user = Rxn<User>(); // Nullable reactive

  void increment() => count++;
  void decrement() => count--;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    isLoading.value = true;
    user.value = await userRepository.getCurrentUser();
    isLoading.value = false;
  }
}

// Setup – Không cần ProviderScope hay BlocProvider
void main() => runApp(GetMaterialApp(home: HomeScreen()));

// Inject controller
Get.put(CounterController());
// Hoặc lazy inject
Get.lazyPut(() => CounterController());

// Sử dụng
class CounterScreen extends StatelessWidget {
  final controller = Get.find<CounterController>();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Obx – Rebuild khi reactive variable thay đổi
      Obx(() => Text('Count: ${controller.count}')),

      // GetX – Rebuild với controller access
      GetX<CounterController>(
        builder: (ctrl) => Text('Loading: ${ctrl.isLoading}'),
      ),

      ElevatedButton(
        onPressed: controller.increment,
        child: const Text('+'),
      ),
    ]);
  }
}

// Navigation với GetX
Get.to(() => const DetailScreen());
Get.toNamed('/detail', arguments: {'id': '123'});
Get.back();
Get.offAll(() => const HomeScreen()); // Clear stack

// Snackbar, Dialog
Get.snackbar('Title', 'Message');
Get.dialog(AlertDialog(title: Text('Alert')));

// Simple state (không reactive)
class SimpleController extends GetxController {
  int count = 0;

  void increment() {
    count++;
    update(); // Trigger rebuild cho GetBuilder
  }
}

GetBuilder<SimpleController>(
  builder: (ctrl) => Text('${ctrl.count}'),
)
```

**Ưu/Nhược điểm GetX:**
- ✅ All-in-one (state, navigation, DI)
- ✅ Ít boilerplate nhất
- ✅ Dễ học, nhanh prototype
- ❌ Quá nhiều magic, khó debug
- ❌ Không follow Flutter best practices
- ❌ Community chia rẽ về chất lượng
- ❌ Khó test

#### 6. Redux và MobX (Tóm tắt)

```dart
// Redux – Unidirectional data flow
// Store → Action → Reducer → Store
// pubspec.yaml: flutter_redux: ^0.10.0

// MobX – Reactive programming
// pubspec.yaml: flutter_mobx: ^2.2.0, mobx: ^2.3.3
// @observable, @action, @computed
// Observer widget tự động track dependencies
```

#### Bảng so sánh tổng hợp State Management 2026

| | setState | Provider | Riverpod | Bloc/Cubit | GetX | Redux | MobX |
|---|---|---|---|---|---|---|---|
| Learning Curve | ⭐ Dễ | ⭐⭐ Dễ | ⭐⭐⭐ TB | ⭐⭐⭐⭐ Khó | ⭐⭐ Dễ | ⭐⭐⭐⭐⭐ Rất khó | ⭐⭐⭐ TB |
| Boilerplate | Ít | Ít | TB | Nhiều | Ít nhất | Rất nhiều | TB |
| Performance | Tốt | Tốt | Tốt nhất | Tốt | Tốt | TB | Tốt |
| Scalability | Kém | TB | Tốt | Tốt nhất | TB | Tốt | TB |
| Testability | TB | TB | Tốt nhất | Tốt | Kém | Tốt | TB |
| Community 2026 | N/A | Lớn | Rất lớn | Rất lớn | Lớn | Nhỏ | Nhỏ |
| Type Safety | TB | TB | Tốt nhất | Tốt | Kém | TB | TB |

**Khuyến nghị 2026:**
- **App nhỏ / prototype**: setState + Provider
- **App vừa / team nhỏ**: Riverpod (khuyến nghị nhất)
- **App lớn / team lớn**: Riverpod hoặc Bloc
- **Cần tách biệt hoàn toàn logic**: Bloc + freezed
- **Prototype nhanh**: GetX (nhưng cẩn thận khi scale)


---

### Routing với GoRouter (chi tiết)

#### GoRouter là gì?

**GoRouter** là package routing chính thức của Flutter team, implement Navigator 2.0 API một cách đơn giản. Là lựa chọn số 1 cho routing năm 2026.

**Lý do dùng GoRouter:**
- Deep linking built-in
- URL-based navigation (Web support)
- Declarative routing
- Type-safe routes (với code gen)
- Nested navigation, ShellRoute
- Authentication guard dễ dàng

```dart
// pubspec.yaml: go_router: ^14.0.0

// Cấu hình cơ bản
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListScreen(),
      routes: [
        // Nested route
        GoRoute(
          path: ':id', // Path parameter
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProductDetailScreen(id: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return SearchScreen(query: query);
      },
    ),
  ],
);

// Sử dụng
MaterialApp.router(
  routerConfig: router,
)

// Navigation
context.go('/products'); // Replace current route
context.push('/products/123'); // Push onto stack
context.pop(); // Go back
context.goNamed('product-detail', pathParameters: {'id': '123'});

// Query parameters
context.go('/search?q=flutter');
```

#### ShellRoute và StatefulShellRoute

```dart
// ShellRoute – Bottom Navigation Bar với shared shell
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/home');
      case 1: context.go('/explore');
      case 2: context.go('/profile');
    }
  }
}

// StatefulShellRoute – Giữ state của mỗi tab (khuyến nghị)
final router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (_, state) =>
                      HomeDetailScreen(id: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
      ],
    ),
  ],
);

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // Tự quản lý state của từng tab
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

#### Authentication Guard và Redirects

```dart
// Auth guard với redirect
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = authService.isLoggedIn;
    final isOnAuthPage = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isLoggedIn && !isOnAuthPage) {
      // Redirect to login, save intended destination
      return '/login?redirect=${state.matchedLocation}';
    }

    if (isLoggedIn && isOnAuthPage) {
      return '/home'; // Already logged in, go home
    }

    return null; // No redirect
  },
  refreshListenable: authService, // Refresh khi auth state thay đổi
  routes: [...],
);

// AuthService phải implement Listenable
class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(String email, String password) async {
    _isLoggedIn = true;
    notifyListeners(); // Trigger GoRouter refresh
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
  }
}
```

#### Typed Routes (Code Generation)

```dart
// Với @TypedGoRoute annotation
part 'router.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

@TypedGoRoute<ProductDetailRoute>(path: '/products/:id')
class ProductDetailRoute extends GoRouteData {
  final String id;
  const ProductDetailRoute({required this.id});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ProductDetailScreen(id: id);
}

// Sử dụng – Type-safe!
const HomeRoute().go(context);
ProductDetailRoute(id: '123').push(context);
```

---

### Animation & Custom UI

#### AnimationController và Tween

```dart
class SlideInWidget extends StatefulWidget {
  final Widget child;
  const SlideInWidget({required this.child});

  @override
  State<SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<SlideInWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 1), // Từ dưới lên
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  ));

  late final Animation<double> _fadeAnimation = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6), // Chỉ fade trong 60% đầu
  ));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
```

#### Hero Animation

```dart
// Source screen
Hero(
  tag: 'product-image-${product.id}', // Tag phải unique và match
  child: Image.network(product.imageUrl, width: 80, height: 80),
)

// Destination screen
Hero(
  tag: 'product-image-${product.id}',
  child: Image.network(product.imageUrl, width: double.infinity),
)
```

#### Staggered Animation

```dart
class StaggeredList extends StatefulWidget {
  final List<String> items;
  const StaggeredList({required this.items});

  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300 + widget.items.length * 100),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final start = index * 0.1;
        final end = (start + 0.5).clamp(0.0, 1.0);

        final animation = Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ));

        return SlideTransition(
          position: animation,
          child: ListTile(title: Text(widget.items[index])),
        );
      },
    );
  }
}
```

#### CustomPainter & Canvas

```dart
class CircleProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  const CircleProgressPainter({
    required this.progress,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      2 * 3.14159 * progress, // Sweep angle
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Text in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toInt()}%',
        style: TextStyle(color: progressColor, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

// Sử dụng
CustomPaint(
  size: const Size(120, 120),
  painter: CircleProgressPainter(progress: 0.75),
)
```

#### SliverAppBar và CustomScrollView

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      expandedHeight: 250,
      pinned: true, // AppBar luôn visible khi scroll
      floating: false,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Products'),
        background: Image.network(
          'https://example.com/banner.jpg',
          fit: BoxFit.cover,
        ),
        collapseMode: CollapseMode.parallax,
      ),
    ),

    // Sticky header
    SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        child: Container(
          color: Colors.white,
          child: const TabBar(tabs: [Tab(text: 'All'), Tab(text: 'Sale')]),
        ),
      ),
    ),

    // Grid
    SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => ProductCard(product: products[index]),
        childCount: products.length,
      ),
    ),

    // List
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text('Item $index')),
        childCount: 20,
      ),
    ),

    // Padding at bottom
    const SliverToBoxAdapter(child: SizedBox(height: 80)),
  ],
)
```


---

### Architecture & Clean Code

#### Clean Architecture trong Flutter

```
lib/
├── core/
│   ├── error/          # Failures, Exceptions
│   ├── network/        # Dio client, interceptors
│   ├── utils/          # Extensions, helpers
│   └── constants/      # App constants
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/    # Remote, Local data sources
│       │   ├── models/         # Data models (fromJson/toJson)
│       │   └── repositories/   # Repository implementations
│       ├── domain/
│       │   ├── entities/       # Business entities (pure Dart)
│       │   ├── repositories/   # Repository interfaces
│       │   └── usecases/       # Business logic
│       └── presentation/
│           ├── bloc/           # Bloc/Cubit
│           ├── pages/          # Screens
│           └── widgets/        # Feature-specific widgets
└── shared/
    └── widgets/        # Shared widgets
```

```dart
// Domain Layer – Pure Dart, không phụ thuộc Flutter
// Entity
class User {
  final String id;
  final String name;
  final String email;
  const User({required this.id, required this.name, required this.email});
}

// Repository interface
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
}

// UseCase
class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<Either<Failure, User>> call(LoginParams params) {
    return _repository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
}

// Data Layer
// Model (extends Entity, thêm fromJson/toJson)
class UserModel extends User {
  const UserModel({required super.id, required super.name, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

// Repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  const AuthRepositoryImpl({required AuthRemoteDataSource remote, required AuthLocalDataSource local})
      : _remote = remote, _local = local;

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await _remote.login(email, password);
      await _local.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remote.logout();
      await _local.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

#### Dependency Injection với get_it + Riverpod

```dart
// get_it setup
final getIt = GetIt.instance;

void setupDependencies() {
  // External
  getIt.registerLazySingleton<Dio>(() => Dio()..interceptors.add(AuthInterceptor()));

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: getIt<AuthRemoteDataSource>(),
      local: getIt<AuthLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
}

// Riverpod providers
final dioProvider = Provider<Dio>((ref) => Dio());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: AuthRemoteDataSourceImpl(ref.watch(dioProvider)),
    local: AuthLocalDataSourceImpl(),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});
```

#### Folder Structure tốt nhất 2026 (Feature-first)

```
lib/
├── app/
│   ├── app.dart              # MaterialApp setup
│   └── router.dart           # GoRouter config
├── core/
│   ├── di/                   # Dependency injection
│   ├── error/                # Failure classes
│   ├── network/              # Dio, interceptors
│   ├── storage/              # SharedPreferences, Hive
│   ├── theme/                # AppTheme
│   └── utils/                # Extensions, helpers
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/    # Riverpod providers
│   │       ├── screens/
│   │       └── widgets/
│   ├── home/
│   ├── product/
│   └── cart/
├── shared/
│   ├── widgets/              # Shared UI components
│   └── models/               # Shared models
└── main.dart
```

---

### Performance & Optimization

#### const constructor và immutable widgets

```dart
// ✅ Dùng const ở mọi nơi có thể
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Text('Title'),           // const
          SizedBox(height: 16),    // const
          Icon(Icons.star),        // const
          MyStaticWidget(),        // const nếu widget có const constructor
        ],
      ),
    );
  }
}

// ✅ Tách widget nhỏ thay vì build method lớn
// ❌ BAD
Widget build(BuildContext context) {
  return Column(children: [
    // 100 dòng code...
  ]);
}

// ✅ GOOD
Widget build(BuildContext context) {
  return Column(children: [
    const _Header(),
    const _Body(),
    const _Footer(),
  ]);
}
```

#### Reduce Rebuild

```dart
// 1. Selector (Provider) – Chỉ rebuild khi field cụ thể thay đổi
Selector<UserModel, String>(
  selector: (_, user) => user.name,
  builder: (_, name, __) => Text(name),
)

// 2. Riverpod .select()
final userName = ref.watch(userProvider.select((u) => u.name));

// 3. BlocBuilder với buildWhen
BlocBuilder<UserBloc, UserState>(
  buildWhen: (prev, curr) => prev.name != curr.name,
  builder: (_, state) => Text(state.name),
)

// 4. RepaintBoundary – Isolate repaint
RepaintBoundary(
  child: ComplexAnimatedWidget(),
)

// 5. const Widget – Không bao giờ rebuild
const ExpensiveStaticWidget()
```

#### Impeller Optimization Tips

```dart
// 1. Tránh saveLayer() nếu không cần thiết
// saveLayer() tạo offscreen buffer, tốn GPU
// ❌ BAD
Container(
  foregroundDecoration: BoxDecoration(
    color: Colors.black.withOpacity(0.5), // Tạo saveLayer
  ),
)

// ✅ GOOD: Dùng ColorFiltered thay thế
ColorFiltered(
  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.srcOver),
  child: myWidget,
)

// 2. Tránh Opacity widget cho animation
// ❌ BAD: Opacity tạo saveLayer
Opacity(opacity: _animation.value, child: myWidget)

// ✅ GOOD: FadeTransition không tạo saveLayer
FadeTransition(opacity: _animation, child: myWidget)

// 3. Dùng cached_network_image cho images
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 300, // Resize trước khi cache
  memCacheHeight: 300,
)
```

#### DevTools Profiling

```dart
// 1. Performance Overlay
MaterialApp(
  showPerformanceOverlay: true, // Hiện FPS overlay
)

// 2. Debug paint
import 'package:flutter/rendering.dart';
debugPaintSizeEnabled = true; // Hiện layout bounds
debugRepaintRainbowEnabled = true; // Highlight repaint areas

// 3. Timeline events
import 'dart:developer';
Timeline.startSync('My expensive operation');
// ... code ...
Timeline.finishSync();

// 4. Memory profiling
// Dùng Flutter DevTools → Memory tab
// Tìm memory leaks, large allocations
```

#### Memory & Image Optimization

```dart
// 1. Dispose controllers
@override
void dispose() {
  _controller.dispose();
  _scrollController.dispose();
  _textController.dispose();
  super.dispose();
}

// 2. Cancel subscriptions
StreamSubscription? _sub;

@override
void initState() {
  super.initState();
  _sub = stream.listen((_) {});
}

@override
void dispose() {
  _sub?.cancel();
  super.dispose();
}

// 3. Image optimization
Image.network(
  url,
  cacheWidth: 300,  // Decode ở kích thước nhỏ hơn
  cacheHeight: 300,
)

// 4. Precache images
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(NetworkImage(imageUrl), context);
}
```

---

### Testing & Advanced Topics

#### Unit Test

```dart
// pubspec.yaml: flutter_test, mocktail: ^1.0.3

// Test UseCase
void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tUser = User(id: '1', name: 'Test', email: tEmail);

    test('should return User when login succeeds', () async {
      // Arrange
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await loginUseCase(
        LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Right(tUser));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });

    test('should return Failure when login fails', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Left(ServerFailure('Invalid credentials')));

      final result = await loginUseCase(
        LoginParams(email: tEmail, password: tPassword),
      );

      expect(result.isLeft(), true);
    });
  });
}

class MockAuthRepository extends Mock implements AuthRepository {}
```

#### Widget Test

```dart
void main() {
  testWidgets('LoginForm shows error when email is empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoginForm())),
    );

    // Tap submit without filling form
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify error message
    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('Counter increments when button tapped', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterWidget()));

    expect(find.text('Count: 0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Count: 1'), findsOneWidget);
  });
}
```

#### Golden Test

```dart
void main() {
  testWidgets('ProductCard matches golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: Product(id: '1', name: 'Test Product', price: 29.99),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(ProductCard),
      matchesGoldenFile('goldens/product_card.png'),
    );
  });
}
```

#### Platform Channels

```dart
// Dart side
class BatteryService {
  static const _channel = MethodChannel('com.example.app/battery');

  Future<int> getBatteryLevel() async {
    try {
      final level = await _channel.invokeMethod<int>('getBatteryLevel');
      return level ?? -1;
    } on PlatformException catch (e) {
      throw Exception('Failed to get battery level: ${e.message}');
    }
  }
}

// Android (Kotlin)
// class MainActivity : FlutterActivity() {
//   override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//     MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.app/battery")
//       .setMethodCallHandler { call, result ->
//         if (call.method == "getBatteryLevel") {
//           val batteryLevel = getBatteryLevel()
//           result.success(batteryLevel)
//         }
//       }
//   }
// }
```

#### Isolates & Background Tasks

```dart
// Isolate cho heavy computation
Future<List<ProcessedData>> processDataInBackground(List<RawData> data) async {
  return compute(_processData, data); // compute() tạo Isolate tự động
}

List<ProcessedData> _processData(List<RawData> data) {
  // Heavy computation – chạy trong Isolate riêng
  return data.map((d) => ProcessedData.from(d)).toList();
}

// Isolate với 2-way communication
Future<void> runIsolate() async {
  final receivePort = ReceivePort();

  await Isolate.spawn(_isolateFunction, receivePort.sendPort);

  final sendPort = await receivePort.first as SendPort;

  final response = ReceivePort();
  sendPort.send([response.sendPort, 'Hello from main']);

  final result = await response.first;
  print('Result: $result');
}

void _isolateFunction(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    final sendPort = message[0] as SendPort;
    final data = message[1] as String;
    sendPort.send('Processed: $data');
  });
}
```

#### Internationalization (i18n)

```dart
// pubspec.yaml:
// flutter_localizations:
//   sdk: flutter
// intl: ^0.19.0

// l10n.yaml
// arb-dir: lib/l10n
// template-arb-file: app_en.arb
// output-localization-file: app_localizations.dart

// lib/l10n/app_en.arb
// {
//   "helloWorld": "Hello World",
//   "greeting": "Hello, {name}!",
//   "@greeting": { "placeholders": { "name": { "type": "String" } } }
// }

// lib/l10n/app_vi.arb
// {
//   "helloWorld": "Xin chào Thế giới",
//   "greeting": "Xin chào, {name}!"
// }

MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const HomeScreen(),
)

// Sử dụng
Text(AppLocalizations.of(context)!.helloWorld)
Text(AppLocalizations.of(context)!.greeting('John'))
```

#### Custom RenderObject (Nâng cao)

```dart
// Tạo custom layout widget
class CustomFlowLayout extends MultiChildRenderObjectWidget {
  final double spacing;

  const CustomFlowLayout({
    required super.children,
    this.spacing = 8,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomFlow(spacing: spacing);
  }

  @override
  void updateRenderObject(BuildContext context, RenderCustomFlow renderObject) {
    renderObject.spacing = spacing;
  }
}

class RenderCustomFlow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, BoxParentData>,
         RenderBoxContainerDefaultsMixin<RenderBox, BoxParentData> {
  double _spacing;

  RenderCustomFlow({required double spacing}) : _spacing = spacing;

  double get spacing => _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    double x = 0;
    double y = 0;
    double rowHeight = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);

      if (x + child.size.width > constraints.maxWidth && x > 0) {
        x = 0;
        y += rowHeight + spacing;
        rowHeight = 0;
      }

      final parentData = child.parentData as BoxParentData;
      parentData.offset = Offset(x, y);

      x += child.size.width + spacing;
      rowHeight = rowHeight < child.size.height ? child.size.height : rowHeight;

      child = childAfter(child);
    }

    size = constraints.constrain(Size(constraints.maxWidth, y + rowHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
```


---

## 6. Best Practices & Common Pitfalls

### Lỗi thường gặp và cách fix

#### OOP Pitfalls

```dart
// ❌ Widget quá lớn, làm nhiều việc
class GodWidget extends StatefulWidget { /* 500 dòng */ }

// ✅ Tách nhỏ, single responsibility
class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(children: [
    const UserHeader(),
    const UserStats(),
    const UserActions(),
  ]);
}

// ❌ Mutable model
class User {
  String name; // Mutable!
  User(this.name);
}

// ✅ Immutable model với copyWith
class User {
  final String name;
  const User({required this.name});
  User copyWith({String? name}) => User(name: name ?? this.name);
}

// ❌ Không dispose controllers
class _MyState extends State<MyWidget> {
  final controller = TextEditingController();
  // Không dispose → memory leak!
}

// ✅ Luôn dispose
class _MyState extends State<MyWidget> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose(); // ✅
    super.dispose();
  }
}
```

#### State Management Pitfalls

```dart
// ❌ setState trong async sau khi widget unmount
Future<void> _load() async {
  final data = await api.getData();
  setState(() => _data = data); // ❌ Widget có thể đã unmount
}

// ✅ Kiểm tra mounted
Future<void> _load() async {
  final data = await api.getData();
  if (!mounted) return; // ✅
  setState(() => _data = data);
}

// ❌ context.watch trong initState
@override
void initState() {
  super.initState();
  final user = context.watch<UserModel>(); // ❌ Lỗi!
}

// ✅ Dùng context.read trong initState
@override
void initState() {
  super.initState();
  final user = context.read<UserModel>(); // ✅
}

// ❌ Riverpod: Đọc provider trong build mà không watch
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.read(userProvider); // ❌ Không rebuild khi thay đổi
  return Text(user.name);
}

// ✅ Dùng watch để subscribe
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userProvider); // ✅ Rebuild khi thay đổi
  return Text(user.name);
}
```

#### ListView Pitfalls

```dart
// ❌ ListView trong Column không có height
Column(children: [
  ListView.builder( // ❌ Lỗi: unbounded height
    itemBuilder: (_, i) => ListTile(title: Text('$i')),
  ),
])

// ✅ Wrap trong Expanded hoặc SizedBox
Column(children: [
  Expanded(
    child: ListView.builder(
      itemBuilder: (_, i) => ListTile(title: Text('$i')),
    ),
  ),
])

// ❌ Không dùng key trong reorderable list
ReorderableListView.builder(
  itemBuilder: (_, i) => ListTile(title: Text(items[i].name)), // ❌ Thiếu key
)

// ✅ Luôn dùng key
ReorderableListView.builder(
  itemBuilder: (_, i) => ListTile(
    key: ValueKey(items[i].id), // ✅
    title: Text(items[i].name),
  ),
)
```

#### GoRouter Pitfalls

```dart
// ❌ Dùng Navigator.push với GoRouter
Navigator.of(context).push(...); // ❌ Bypass GoRouter

// ✅ Luôn dùng context.go/push
context.go('/detail/123'); // ✅

// ❌ Không handle redirect loop
redirect: (context, state) {
  if (!isLoggedIn) return '/login';
  if (state.matchedLocation == '/login') return '/home';
  // ❌ Có thể loop nếu logic sai
}

// ✅ Kiểm tra kỹ điều kiện redirect
redirect: (context, state) {
  final isOnLogin = state.matchedLocation == '/login';
  if (!isLoggedIn && !isOnLogin) return '/login';
  if (isLoggedIn && isOnLogin) return '/home';
  return null; // No redirect
}
```

#### Key Pitfalls

```dart
// ❌ Tạo UniqueKey trong build
Widget build(BuildContext context) {
  return ItemWidget(key: UniqueKey()); // ❌ Rebuild mỗi lần!
}

// ✅ Dùng ValueKey với stable id
Widget build(BuildContext context) {
  return ItemWidget(key: ValueKey(item.id)); // ✅
}

// ❌ GlobalKey trong build
Widget build(BuildContext context) {
  final key = GlobalKey(); // ❌ Tạo mới mỗi lần!
  return Form(key: key);
}

// ✅ GlobalKey là field của State
class _MyState extends State<MyWidget> {
  final _key = GlobalKey<FormState>(); // ✅ Tạo 1 lần
}
```

### Tips tối ưu hiệu suất thực tế

```dart
// 1. Dùng const ở mọi nơi có thể
const Text('Static text')
const SizedBox(height: 16)
const EdgeInsets.all(16)

// 2. Tách widget nhỏ thay vì helper methods
// ❌ Helper method – luôn rebuild
Widget _buildHeader() => Text('Header');

// ✅ Widget riêng – có thể const
class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => const Text('Header');
}

// 3. Dùng ListView.builder thay vì ListView
// 4. Dùng itemExtent cho fixed-height items
// 5. Dùng RepaintBoundary cho complex widgets
// 6. Tránh Opacity widget, dùng FadeTransition
// 7. Dùng cached_network_image với memCacheWidth/Height
// 8. Dùng MediaQuery.sizeOf thay vì MediaQuery.of (Flutter 3.10+)
// 9. Dùng context.select thay vì context.watch khi có thể
// 10. Profile trước khi optimize – đừng optimize sớm
```

### Code Style & Effective Flutter

```dart
// 1. Prefer final over var
final user = User(name: 'John'); // ✅
var user = User(name: 'John');   // ❌ (nếu không reassign)

// 2. Prefer const constructors
const Text('Hello') // ✅
Text('Hello')       // ❌ (nếu có thể const)

// 3. Use named parameters cho readability
// ❌ Positional parameters khó đọc
User('John', 25, 'john@example.com')

// ✅ Named parameters rõ ràng
User(name: 'John', age: 25, email: 'john@example.com')

// 4. Avoid deep nesting – extract widgets
// ❌ Pyramid of doom
Container(child: Padding(child: Column(children: [Row(children: [...])])))

// ✅ Extract widgets
const UserCard()

// 5. Use cascade notation
final paint = Paint()
  ..color = Colors.blue
  ..strokeWidth = 2
  ..style = PaintingStyle.stroke;

// 6. Prefer expression body cho simple methods
String get fullName => '$firstName $lastName'; // ✅
String get fullName { return '$firstName $lastName'; } // ❌

// 7. Use ?? và ?.
final name = user?.name ?? 'Guest'; // ✅
final name = user != null ? user.name : 'Guest'; // ❌

// 8. Avoid print() trong production
debugPrint('Debug message'); // ✅ Chỉ in trong debug mode
print('Message'); // ❌ In cả production
```

---

## 7. Tài liệu tham khảo & Công cụ hỗ trợ

### Tài liệu chính thức

| Tài liệu | URL |
|---|---|
| Flutter Official Docs | https://flutter.dev/docs |
| Dart Language Tour | https://dart.dev/language |
| Flutter API Reference | https://api.flutter.dev |
| Riverpod Docs | https://riverpod.dev |
| GoRouter Docs | https://pub.dev/packages/go_router |
| Impeller Docs | https://github.com/flutter/flutter/wiki/Impeller |
| Flutter Bloc Docs | https://bloclibrary.dev |
| Material Design 3 | https://m3.material.io |
| Flutter DevTools | https://docs.flutter.dev/tools/devtools |
| pub.dev | https://pub.dev |

### Packages quan trọng 2026

| Package | Mục đích | Version |
|---|---|---|
| `flutter_riverpod` | State management | ^2.5.1 |
| `riverpod_annotation` | Code gen cho Riverpod | ^2.3.5 |
| `go_router` | Navigation/Routing | ^14.0.0 |
| `dio` | HTTP client | ^5.4.3 |
| `freezed` | Immutable classes, sealed classes | ^2.4.7 |
| `json_serializable` | JSON serialization | ^6.7.1 |
| `flutter_bloc` | BLoC pattern | ^8.1.5 |
| `get_it` | Dependency injection | ^7.6.7 |
| `injectable` | Code gen cho get_it | ^2.3.2 |
| `hive_flutter` | Local storage | ^1.1.0 |
| `shared_preferences` | Simple key-value storage | ^2.2.3 |
| `cached_network_image` | Image caching | ^3.3.1 |
| `flutter_hooks` | React-like hooks | ^0.20.5 |
| `mocktail` | Mocking cho tests | ^1.0.3 |
| `very_good_cli` | Project scaffolding | CLI tool |
| `melos` | Monorepo management | CLI tool |
| `flutter_lints` | Lint rules | ^4.0.0 |
| `dartz` | Functional programming (Either) | ^0.10.1 |
| `equatable` | Value equality | ^2.0.5 |
| `intl` | Internationalization | ^0.19.0 |
| `flutter_localizations` | Localization | SDK |
| `firebase_core` | Firebase | ^2.30.1 |
| `firebase_messaging` | Push notifications | ^14.9.1 |
| `flutter_local_notifications` | Local notifications | ^17.1.2 |

### Công cụ hỗ trợ

```bash
# very_good_cli – Tạo project với best practices
dart pub global activate very_good_cli
very_good create flutter_app my_app

# melos – Quản lý monorepo
dart pub global activate melos
melos bootstrap
melos run test

# flutter_gen – Type-safe assets
dart pub global activate flutter_gen
fluttergen

# build_runner – Code generation
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch

# flutter_lints – Lint
# pubspec.yaml: flutter_lints: ^4.0.0
# analysis_options.yaml:
# include: package:flutter_lints/flutter.yaml

# Dart Fix – Auto fix lint issues
dart fix --apply

# Flutter Doctor – Kiểm tra môi trường
flutter doctor -v

# Flutter Upgrade
flutter upgrade
flutter pub upgrade --major-versions
```

### Checklist trước khi release

```
Performance:
✅ Chạy flutter analyze – không có warnings
✅ Profile mode testing (flutter run --profile)
✅ Kiểm tra memory leaks với DevTools
✅ Test trên low-end device
✅ Kiểm tra image sizes và caching

Code Quality:
✅ Tất cả controllers được dispose
✅ Tất cả subscriptions được cancel
✅ Không có print() statements
✅ Tất cả TODO comments được giải quyết
✅ Unit tests pass

Security:
✅ API keys không hardcode trong code
✅ Sensitive data được encrypt
✅ Certificate pinning (nếu cần)
✅ ProGuard/R8 rules cho Android

Release:
✅ Version number được update
✅ Changelog được update
✅ Icons và splash screen đúng
✅ Deep links được test
✅ Push notifications được test
```

---

> **Tài liệu này được tổng hợp và cập nhật đến năm 2026.**
> Luôn kiểm tra phiên bản mới nhất của các packages tại [pub.dev](https://pub.dev) và tài liệu chính thức tại [flutter.dev](https://flutter.dev).

