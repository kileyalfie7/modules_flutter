# 🚀 Flutter Senior Developer Roadmap 2026
> **Dành cho:** Dev 3–5 năm Mobile / Flutter muốn lên Senior  
> **Mục tiêu:** Không chỉ "biết dùng" — mà phải **hiểu bản chất, thiết kế hệ thống, và tư duy product**

---

## 📌 Mindset Chuyển Dịch

| Mid-level | Senior |
|---|---|
| "Tôi implement được feature" | "Tôi thiết kế được hệ thống để feature đó scale 5 năm" |
| Biết dùng thư viện | Hiểu bản chất thư viện đó hoạt động thế nào |
| Fix bug khi nó xảy ra | Thiết kế để bug không xảy ra |
| Làm việc theo task | Suy nghĩ theo business impact |
| Code cho bản thân hiểu | Code cho team maintain |

---

## 1️⃣ Flutter Core – Level Nâng Cao

### 🔹 Rendering Engine & Lifecycle

Flutter không dùng WebView hay Native Widget. Nó tự vẽ mọi thứ qua **Skia / Impeller**. Hiểu điều này giúp bạn debug performance chính xác.

```
Widget Tree → Element Tree → RenderObject Tree → Layer Tree → GPU
```

**Những gì cần nắm:**

- **Widget → Element → RenderObject lifecycle**
  - `StatelessWidget`, `StatefulWidget` khác nhau ở level Element như thế nào?
  - `BuildContext` thực ra là `Element` — hiểu điều này để tránh context leak
  - `RenderObject` là nơi thực sự tính toán layout và paint

- **Frame Rendering Pipeline**
  - Flutter target 60fps / 120fps = mỗi frame có ~16ms / 8ms
  - Pipeline: `Vsync → Build → Layout → Paint → Composite → Rasterize`
  - **Jank** xảy ra khi bất kỳ bước nào vượt budget thời gian

- **Skia vs Impeller**
  - Skia: engine cũ, dùng JIT shader compilation → gây jank lần đầu
  - **Impeller** (Flutter 3.7+): pre-compile shader, ít jank hơn — iOS default từ 3.10, Android đang rollout

- **Layer Tree & Compositing**
  - Mỗi `RepaintBoundary` tạo một layer mới
  - Layer được composite bởi engine, không phải Dart
  - Lạm dụng `RepaintBoundary` → tốn memory; thiếu → rebuild cả cây

**Thực hành:**
```dart
// Bọc widget nặng, tái sử dụng nhiều lần
RepaintBoundary(
  child: ComplexAnimationWidget(),
)

// Kiểm tra layer tree
debugPaintLayerBordersEnabled = true;
```

---

### 🔹 CustomPainter & Animation Tối Ưu

```dart
class WaterPourPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dùng Path, Paint tối ưu — tránh tạo object mới trong paint()
  }

  @override
  bool shouldRepaint(WaterPourPainter oldDelegate) {
    // Trả về false khi không có gì thay đổi — quan trọng!
    return oldDelegate.progress != progress;
  }
}
```

**Lưu ý quan trọng:**
- Đừng tạo `Paint()`, `Path()` bên trong `paint()` method — sẽ gây GC pressure
- Dùng `shouldRepaint` để control việc repaint
- `AnimationController` + `Ticker` hiệu quả hơn `Timer` cho animation

---

### 🔹 State Management – Level Kiến Trúc

Không phải "biết dùng" mà là biết **khi nào dùng cái gì** và **tại sao**.

| Solution | Khi nào dùng | Ưu điểm | Nhược điểm |
|---|---|---|---|
| **setState** | UI local, đơn giản | Zero boilerplate | Không scale |
| **Provider** | App vừa, team nhỏ | Dễ học | Verbose khi complex |
| **Riverpod** | App vừa → lớn | Type-safe, testable, compile-time safe | Learning curve |
| **Bloc/Cubit** | Enterprise, team lớn | Predictable, testable, strict | Boilerplate nhiều |
| **GetX** | Prototype nhanh | Ít code | Magic, khó debug, anti-pattern |
| **MobX** | Reactive UI phức tạp | Fine-grained reactivity | Code generation |

**Xu hướng 2025–2026:**
- **Riverpod** đang thắng ở mid-size app (type-safe, không cần context)
- **Bloc** vẫn dominant ở enterprise (banking, fintech, super app)
- **GetX** bị nhiều team bỏ do khó maintain dài hạn

**Riverpod 2.0 – Những gì cần biết:**
```dart
// Provider đơn giản
final counterProvider = StateProvider<int>((ref) => 0);

// AsyncNotifier cho data fetching
class UserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    return ref.watch(userRepositoryProvider).fetchUser();
  }
}

// Family modifier
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  return ref.watch(userRepositoryProvider).fetchUser(userId);
});
```

---

### 🔹 Dependency Injection

```
GetIt (Service Locator)  ←→  Riverpod (built-in DI)  ←→  Injectable (code gen)
```

**GetIt + Injectable pattern:**
```dart
@injectable
class UserRepository {
  final ApiClient _client;
  UserRepository(this._client);
}

// Auto-generated
getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt()));
```

---

## 2️⃣ Performance Engineering

> Dev 3–5 năm **phải** biết tối ưu. Đây là điểm phân biệt rõ nhất.

### 🔹 Công Cụ Profiling

**Flutter DevTools** – bắt buộc thành thạo:
- **Performance tab**: xem frame timeline, identify jank frames (đỏ = >16ms)
- **CPU Profiler**: xem hàm nào chiếm CPU nhiều nhất
- **Memory tab**: detect memory leak, xem heap
- **Widget Inspector**: xem rebuild count

```bash
# Chạy app ở profile mode để đo chính xác
flutter run --profile
```

### 🔹 Tối Ưu Rebuild

```dart
// ❌ Bad: Rebuild cả list khi 1 item thay đổi
Consumer<CartProvider>(
  builder: (context, cart, child) => ListView(
    children: cart.items.map((item) => CartItem(item)).toList(),
  ),
)

// ✅ Good: Chỉ rebuild item cần thiết
ListView.builder(
  itemCount: cart.items.length,
  itemBuilder: (context, index) => Consumer<CartProvider>(
    builder: (context, cart, child) => CartItem(cart.items[index]),
  ),
)

// ✅ Better: Dùng const constructor
const MyWidget(key: ValueKey('stable'));

// ✅ Tách phần static ra child
Consumer<Provider>(
  builder: (context, value, child) => Column(
    children: [
      child!, // Không rebuild
      Text(value.data),
    ],
  ),
  child: const ExpensiveStaticWidget(),
)
```

### 🔹 Large List Optimization

```dart
// ✅ ListView.builder – lazy loading
ListView.builder(
  itemCount: items.length,
  itemExtent: 80, // Cố định height → tính toán scroll nhanh hơn
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ✅ SliverList với delegate cho dynamic height
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) => ItemWidget(items[index]),
    childCount: items.length,
  ),
)

// ✅ Pagination – đừng load 10,000 items
void _onScroll() {
  if (_scrollController.position.pixels >= 
      _scrollController.position.maxScrollExtent - 200) {
    context.read<ListBloc>().add(LoadMoreEvent());
  }
}
```

### 🔹 Image Optimization

```dart
// ✅ Cache image
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 200,  // Decode ở size nhỏ hơn nếu hiển thị nhỏ
  memCacheHeight: 200,
  placeholder: (context, url) => const ShimmerWidget(),
)

// ✅ Resize trước khi hiển thị
Image.network(
  url,
  cacheWidth: 400, // Flutter sẽ decode ở 400px, không phải original
)

// ✅ Precache ảnh quan trọng
await precacheImage(NetworkImage(url), context);
```

### 🔹 Isolate Cho Heavy Work

```dart
// ❌ Chạy JSON parse lớn trên main thread → jank
final data = jsonDecode(largeJsonString);

// ✅ Dùng compute() (chạy trên isolate)
final data = await compute(parseJson, largeJsonString);

// ✅ Isolate phức tạp hơn
Future<List<ProcessedItem>> processItems(List<RawItem> items) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_isolateWork, [receivePort.sendPort, items]);
  return await receivePort.first as List<ProcessedItem>;
}
```

### 🔹 Memory Leak Prevention

```dart
// ❌ Common leak: StreamSubscription không cancel
class MyWidget extends StatefulWidget { ... }
class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = stream.listen((_) {});
  }

  @override
  void dispose() {
    _subscription?.cancel(); // ✅ Bắt buộc
    super.dispose();
  }
}

// ❌ Animation controller leak
AnimationController? _controller;

@override
void dispose() {
  _controller?.dispose(); // ✅ Bắt buộc
  super.dispose();
}
```

---

## 3️⃣ Native Bridge & Platform Integration

> Đây là điểm yếu của nhiều Flutter dev. Nắm được phần này = lợi thế cạnh tranh.

### 🔹 MethodChannel

```dart
// Dart side
const channel = MethodChannel('com.myapp/native');

Future<String> getBatteryLevel() async {
  try {
    final result = await channel.invokeMethod<int>('getBatteryLevel');
    return 'Battery: $result%';
  } on PlatformException catch (e) {
    return 'Failed: ${e.message}';
  }
}

// Android side (Kotlin)
class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.myapp/native"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "getBatteryLevel" -> {
          val batteryLevel = getBatteryLevel()
          result.success(batteryLevel)
        }
        else -> result.notImplemented()
      }
    }
  }
}
```

### 🔹 Channel Types

| Channel | Dùng cho |
|---|---|
| `MethodChannel` | Gọi function một lần, có response |
| `EventChannel` | Stream liên tục (sensor, location) |
| `BasicMessageChannel` | Gửi message 2 chiều liên tục |

### 🔹 Push Notification Architecture

```
FCM/APNs → Firebase → App (background/foreground handler)
                          ↓
                   Notification permission
                   Notification payload
                   Deep link từ notification
                   Badge count
```

**Firebase Messaging setup đúng cách:**
```dart
// Background message handler - PHẢI là top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
}

void main() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}
```

### 🔹 Deep Link / App Link

```
Universal Link (iOS) / App Link (Android) → App mở đúng màn hình

https://myapp.com/product/123
         ↓
app://product/123
         ↓
ProductDetailScreen(id: 123)
```

**GoRouter + Deep link:**
```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/product/:id',
      builder: (context, state) => ProductDetailScreen(
        id: state.pathParameters['id']!,
      ),
    ),
  ],
);
```

### 🔹 Background Service

```dart
// flutter_background_service
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Chạy trong isolate riêng
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    // Sync data, gửi location, etc.
  });
}
```

---

## 4️⃣ Architecture & System Thinking

> Đây là gap lớn nhất giữa mid và senior.

### 🔹 Clean Architecture trong Flutter

```
lib/
├── core/
│   ├── error/          # Failures, Exceptions
│   ├── network/        # Dio, interceptors
│   ├── utils/
│   └── constants/
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/     # API calls, local DB
│       │   ├── models/          # JSON serialization
│       │   └── repositories/    # Implementation
│       ├── domain/
│       │   ├── entities/        # Pure Dart classes
│       │   ├── repositories/    # Abstract interfaces
│       │   └── usecases/        # Business logic
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
```

**Dependency Rule:** Dependency chỉ trỏ vào trong (inward). Domain không phụ thuộc bất kỳ layer nào.

```dart
// Domain layer - pure Dart, không import Flutter
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
}

// Use case
class GetUserUseCase {
  final UserRepository repository;
  GetUserUseCase(this.repository);

  Future<Either<Failure, User>> call(String id) {
    return repository.getUser(id);
  }
}
```

### 🔹 Feature-First vs Layer-First

```
# Layer-first (dễ lộn xộn khi scale)
lib/
├── models/
├── repositories/
├── screens/

# Feature-first (recommended cho app lớn)
lib/
├── features/
│   ├── auth/
│   ├── home/
│   ├── product/
│   └── cart/
```

### 🔹 Modular Architecture / Super App

```
super_app/
├── shell_app/           # Host app, navigation
├── feature_auth/        # Có thể deploy riêng
├── feature_shopping/
├── feature_payment/
└── shared_ui/           # Design system chung
```

**Kỹ thuật:**
- **Melos**: quản lý monorepo Flutter
- **Dart pub workspaces**: dependency management
- **Dynamic feature delivery** (Android): download feature khi cần
- **Deferred loading** (Flutter Web): lazy load dart libraries

### 🔹 Offline-First Design

```
User Action
    ↓
Local DB (Hive/Isar/SQLite) ← Hiển thị ngay
    ↓
Sync Queue
    ↓
API (khi có network)
    ↓
Conflict Resolution Strategy
```

**Caching Strategy:**
| Strategy | Khi nào dùng |
|---|---|
| Cache-first | Data ít thay đổi (config, catalog) |
| Network-first | Data real-time (chat, stock) |
| Stale-while-revalidate | Balance UX và freshness |
| Cache-only | Offline mode |

### 🔹 Error Handling Architecture

```dart
// Functional error handling với Either (dartz package)
Future<Either<Failure, User>> getUser(String id) async {
  try {
    final response = await apiClient.get('/users/$id');
    return Right(User.fromJson(response.data));
  } on DioException catch (e) {
    return Left(NetworkFailure(e.message));
  } on CacheException {
    return Left(CacheFailure());
  }
}

// Ở UI layer
final result = await getUserUseCase(userId);
result.fold(
  (failure) => showError(failure.message),
  (user) => showUserProfile(user),
);
```

---

## 5️⃣ Testing Strategy

> Senior dev viết test. Không có exception.

### 🔹 Testing Pyramid

```
        /\
       /  \   E2E Tests (ít nhất)
      /----\  Integration Tests
     /      \ Widget Tests
    /--------\ Unit Tests (nhiều nhất)
```

### 🔹 Unit Test

```dart
void main() {
  group('GetUserUseCase', () {
    late MockUserRepository mockRepository;
    late GetUserUseCase useCase;

    setUp(() {
      mockRepository = MockUserRepository();
      useCase = GetUserUseCase(mockRepository);
    });

    test('should return User when repository succeeds', () async {
      // Arrange
      const userId = '123';
      final tUser = User(id: userId, name: 'Test');
      when(() => mockRepository.getUser(userId))
          .thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result, Right(tUser));
      verify(() => mockRepository.getUser(userId)).called(1);
    });
  });
}
```

### 🔹 Widget Test

```dart
testWidgets('shows user name after loading', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userProvider.overrideWith((ref) => AsyncValue.data(mockUser)),
      ],
      child: const MaterialApp(home: UserScreen()),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.text('John Doe'), findsOneWidget);
});
```

### 🔹 Golden Test (Screenshot Test)

```dart
testWidgets('ProductCard matches golden', (tester) async {
  await tester.pumpWidget(const ProductCard(product: mockProduct));
  await expectLater(
    find.byType(ProductCard),
    matchesGoldenFile('goldens/product_card.png'),
  );
});
```

---

## 6️⃣ AI + Developer Workflow

> Không dùng AI năm 2026 = tự giảm productivity 50%.

### 🔹 AI Tools Arsenal

| Tool | Dùng cho |
|---|---|
| **Cursor IDE** | AI-native IDE, best for large codebase |
| **GitHub Copilot** | Inline completion, mọi IDE |
| **Claude** | Architecture decisions, code review, docs |
| **ChatGPT / Gemini** | Research, explain concepts |
| **Claude Code** | Agentic coding, refactor large files |

### 🔹 Prompt Engineering cho Dev

**Tạo boilerplate:**
```
Tạo Bloc cho feature "User Profile" trong Flutter với Clean Architecture.
Bao gồm: State, Event, Bloc class.
State có 3 variant: Loading, Loaded(User), Error(String).
Event: LoadUser(String userId), UpdateUser(User user).
Dùng Either từ dartz cho error handling.
```

**Review code:**
```
Review đoạn code Flutter này về:
1. Performance issues
2. Memory leaks
3. Best practices
4. Testability

[paste code]
```

**Debug:**
```
Tôi bị lỗi này trong Flutter:
[error message]

Context: [mô tả vấn đề]
Tôi đã thử: [những gì đã thử]
```

### 🔹 AI-Assisted Development Workflow

```
1. Feature planning  → Dùng Claude/ChatGPT phân tích requirements
2. Architecture      → AI suggest patterns phù hợp
3. Scaffolding       → Copilot/Cursor gen boilerplate
4. Implementation    → AI pair programming
5. Testing           → AI gen test cases
6. Code Review       → AI review trước khi tạo PR
7. Documentation     → AI gen docs từ code
```

### 🔹 Auto Test Generation

```bash
# Với Claude Code hoặc Cursor
"Generate unit tests for UserRepository class.
Cover: success cases, network errors, cache errors.
Use mocktail for mocking."
```

---

## 7️⃣ Product & Business Thinking

> Senior dev nghĩ theo **user impact**, không chỉ code.

### 🔹 Analytics & Tracking

```dart
// Event tracking có cấu trúc
class AnalyticsEvent {
  static const String productViewed = 'product_viewed';
  static const String addToCart = 'add_to_cart';
  static const String checkoutStarted = 'checkout_started';
}

// Luôn track thêm properties
await analytics.logEvent(
  name: AnalyticsEvent.productViewed,
  parameters: {
    'product_id': product.id,
    'product_name': product.name,
    'category': product.category,
    'price': product.price,
    'source': 'home_feed', // Từ đâu user đến đây?
  },
);
```

### 🔹 Feature Flag System

```dart
// Không deploy = không risk
class FeatureFlags {
  static Future<bool> isEnabled(String flag) async {
    return RemoteConfig.instance.getBool(flag);
  }
}

// Trong code
if (await FeatureFlags.isEnabled('new_checkout_flow')) {
  // New implementation
} else {
  // Old implementation
}
```

### 🔹 A/B Testing

```dart
// Firebase Remote Config + A/B Testing
final remoteConfig = FirebaseRemoteConfig.instance;
final variant = remoteConfig.getString('checkout_button_variant');

// Track conversion per variant
analytics.logEvent(
  name: 'purchase_completed',
  parameters: {'ab_variant': variant},
);
```

### 🔹 Crash Reporting

```dart
// Firebase Crashlytics
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

// Custom error info
await FirebaseCrashlytics.instance.setCustomKey('user_id', userId);
await FirebaseCrashlytics.instance.setCustomKey('feature_flag', flagValue);

// Non-fatal errors
FirebaseCrashlytics.instance.recordError(
  exception,
  stackTrace,
  reason: 'Failed to load user profile',
  fatal: false,
);
```

---

## 8️⃣ DevOps & CI/CD cho Mobile

> Senior dev không chỉ code — phải ship được.

### 🔹 CI/CD Pipeline

```yaml
# GitHub Actions example
name: Flutter CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --release
```

### 🔹 Fastlane cho Auto Deploy

```ruby
# Fastfile
lane :deploy_staging do
  flutter_build(build_type: 'apk', flavor: 'staging')
  upload_to_firebase_app_distribution(
    app: ENV['FIREBASE_APP_ID'],
    groups: 'internal-testers'
  )
end

lane :deploy_production do
  flutter_build(build_type: 'appbundle')
  upload_to_play_store(track: 'internal')
end
```

### 🔹 Flavors / Build Variants

```
app/
├── dev/     → localhost API, debug tools, free signing
├── staging/ → staging API, crash reporting on
└── prod/    → production API, optimized, release signing
```

---

## 9️⃣ Security Best Practices

### 🔹 Lưu trữ sensitive data

```dart
// ❌ Never store in SharedPreferences
prefs.setString('auth_token', token);

// ✅ Dùng flutter_secure_storage (Keychain/Keystore)
const storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);
```

### 🔹 Certificate Pinning

```dart
// Dio với certificate pinning
dio.options.validateStatus = (status) => status! < 500;
(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
  client.badCertificateCallback = (cert, host, port) {
    return cert.sha256 == expectedHash; // Pin certificate
  };
};
```

### 🔹 Obfuscation

```bash
# Build với obfuscation
flutter build apk --obfuscate --split-debug-info=./debug-info
```

---

## 🎯 Learning Path & Timeline

### Tháng 1–2: Consolidate Core
- [ ] Đọc Flutter source code (Widget, Element, RenderObject)
- [ ] Thực hành với Flutter DevTools profiling
- [ ] Build một app với Riverpod + Clean Architecture

### Tháng 3–4: System Level
- [ ] Viết một MethodChannel plugin từ đầu (Android + iOS)
- [ ] Implement offline-first với sync queue
- [ ] Set up CI/CD pipeline cho một project

### Tháng 5–6: Architecture & Product
- [ ] Refactor một app thành modular architecture
- [ ] Implement feature flag + A/B testing
- [ ] Set up analytics tracking đúng cách

### Ongoing: AI Workflow
- [ ] Dùng Cursor IDE hàng ngày
- [ ] Build prompt templates cho task lặp lại
- [ ] Share knowledge qua blog/YouTube (teaching = deepening)

---

## 📚 Tài Nguyên Học Tập

### Sách & Docs
- [Flutter Architecture Recommendations](https://docs.flutter.dev/app-architecture)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Riverpod Documentation](https://riverpod.dev)
- Clean Code – Robert C. Martin

### Kênh YouTube
- Flutter (official)
- ResoCoder (Clean Architecture Flutter)
- Reso Coder – Bloc Tutorial

### Cộng Đồng
- Flutter Discord
- Flutter Vietnam Facebook Group
- r/FlutterDev Reddit

---

## 🏆 Checklist Senior Flutter Dev

### Technical
- [ ] Hiểu Widget → Element → RenderObject lifecycle
- [ ] Profile và fix jank bằng DevTools
- [ ] Thiết kế Clean Architecture cho feature mới
- [ ] Viết unit test, widget test, golden test
- [ ] Tự viết MethodChannel plugin
- [ ] Set up CI/CD pipeline
- [ ] Implement offline-first với conflict resolution
- [ ] Hiểu AOT compilation và tree shaking

### Leadership
- [ ] Code review hiệu quả, constructive feedback
- [ ] Onboard junior dev
- [ ] Viết technical design document
- [ ] Estimate chính xác và communicate risk

### Product
- [ ] Phân tích analytics để cải thiện UX
- [ ] Hiểu business metrics (DAU, retention, conversion)
- [ ] Propose technical solutions từ user pain points

---

> 💡 **Nhớ:** Senior không phải là người biết nhiều nhất — mà là người **giải quyết vấn đề đúng cách**, **mentor được người khác**, và **nghĩ xa hơn bản thân mình**.