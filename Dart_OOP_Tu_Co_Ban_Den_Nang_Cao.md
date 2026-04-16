# Dart & OOP – Từ Cơ Bản Đến Nâng Cao

> **Tác giả:** Tổng hợp chuyên sâu dành cho Flutter/Dart Developer  
> **Phiên bản Dart:** 3.x (stable)  
> **Cập nhật:** 2024

---

## Mục lục

1. [Giới thiệu](#1-giới-thiệu)
2. [Cơ bản OOP trong Dart](#2-cơ-bản-oop-trong-dart)
3. [Trung cấp OOP trong Dart](#3-trung-cấp-oop-trong-dart)
4. [Nâng cao OOP trong Dart](#4-nâng-cao-oop-trong-dart)
5. [Tài liệu tham khảo & Mẹo thực tế](#5-tài-liệu-tham-khảo--mẹo-thực-tế)

---

## 1. Giới thiệu

### Dart là gì?

Dart là ngôn ngữ lập trình đa mục đích, strongly-typed, được phát triển bởi Google vào năm 2011. Ban đầu được thiết kế để thay thế JavaScript trên trình duyệt, nhưng ngày nay Dart nổi bật nhất nhờ Flutter – framework UI cross-platform hàng đầu.

**Lịch sử tóm tắt:**

| Năm | Sự kiện |
|-----|---------|
| 2011 | Google giới thiệu Dart tại GOTO Conference |
| 2013 | Dart 1.0 chính thức phát hành |
| 2018 | Dart 2.0 – mạnh mẽ hơn với sound type system |
| 2021 | Dart 2.12 – Null Safety chính thức (sound null safety) |
| 2023 | Dart 3.0 – Records, Patterns, Class modifiers |

**Ứng dụng hiện tại:**

- **Flutter** – Mobile (iOS/Android), Web, Desktop, Embedded
- **Server-side** – Dart Frog, Shelf framework
- **CLI tools** – Dart scripts, build tools
- **Web** – dart2js, dart2wasm

### Đặc điểm nổi bật

- **Strongly typed** với type inference thông minh
- **Sound null safety** – loại bỏ null reference errors tại compile time
- **AOT & JIT compilation** – vừa có hot reload (dev), vừa có hiệu năng cao (production)
- **Garbage collected** – quản lý bộ nhớ tự động
- **Single-threaded với Isolate** – concurrency model an toàn
- **Syntax quen thuộc** – giống Java/C#/JavaScript, dễ tiếp cận

### Tại sao Dart là ngôn ngữ OOP mạnh mẽ?

Dart được thiết kế từ đầu theo triết lý OOP thuần túy:

- **Mọi thứ đều là Object** – kể cả `int`, `bool`, `null` (trong Dart, `null` là instance của `Null`)
- **Class là first-class citizen** – có đầy đủ constructor, inheritance, interface, mixin
- **Mixin-based inheritance** – giải quyết vấn đề đa kế thừa một cách thanh lịch
- **Extension methods** – mở rộng class mà không cần sửa source code
- **Generics mạnh mẽ** – reified generics, không bị type erasure như Java
- **Pattern matching** (Dart 3) – destructuring và matching cực kỳ expressive

---

## 2. Cơ bản OOP trong Dart

### 2.1 Class và Object

Class là bản thiết kế (blueprint), Object là thực thể được tạo ra từ class đó.

```dart
// Định nghĩa class
class User {
  String name;
  int age;

  // Constructor
  User(this.name, this.age);

  void greet() {
    print('Xin chào, tôi là $name, $age tuổi.');
  }
}

void main() {
  // Tạo object (instance)
  final user = User('An', 25);
  user.greet(); // Xin chào, tôi là An, 25 tuổi.

  // Kiểm tra type
  print(user is User);   // true
  print(user is Object); // true – mọi thứ đều là Object
}
```

> **Lưu ý:** Trong Dart, bạn KHÔNG cần từ khóa `new` khi tạo object (Dart 2+). Dùng `User(...)` thay vì `new User(...)`.

---

### 2.2 Constructor

Dart cung cấp nhiều loại constructor linh hoạt:

#### Default Constructor

```dart
class Product {
  String name;
  double price;

  // Cú pháp shorthand – tự động gán vào this.name, this.price
  Product(this.name, this.price);
}
```

#### Named Constructor

```dart
class Product {
  String name;
  double price;
  bool isOnSale;

  Product(this.name, this.price) : isOnSale = false;

  // Named constructor cho các trường hợp đặc biệt
  Product.sale(this.name, this.price) : isOnSale = true;

  Product.free(this.name)
      : price = 0,
        isOnSale = true;
}

void main() {
  final p1 = Product('Áo', 200000);
  final p2 = Product.sale('Quần', 150000);
  final p3 = Product.free('Mẫu thử');
}
```

#### Factory Constructor

Factory constructor dùng khi bạn muốn kiểm soát việc tạo object – có thể trả về instance đã tồn tại, hoặc subtype.

```dart
class AppConfig {
  final String apiUrl;
  final int timeout;

  AppConfig._internal(this.apiUrl, this.timeout);

  // Factory: Singleton pattern đơn giản
  static AppConfig? _instance;

  factory AppConfig({
    String apiUrl = 'https://api.example.com',
    int timeout = 30,
  }) {
    _instance ??= AppConfig._internal(apiUrl, timeout);
    return _instance!;
  }
}

void main() {
  final config1 = AppConfig();
  final config2 = AppConfig();
  print(identical(config1, config2)); // true – cùng một instance
}
```

#### Const Constructor

Dùng khi object là immutable – Dart sẽ cache và tái sử dụng cùng một instance trong compile time.

```dart
class Color {
  final int r, g, b;

  const Color(this.r, this.g, this.b);

  // Constant được định nghĩa sẵn
  static const red = Color(255, 0, 0);
  static const green = Color(0, 255, 0);
  static const blue = Color(0, 0, 255);
}

void main() {
  const c1 = Color(255, 0, 0);
  const c2 = Color(255, 0, 0);
  print(identical(c1, c2)); // true – cùng một object trong memory

  // Trong Flutter: const widget = hiệu năng tốt hơn
  // const Text('Hello') – không rebuild khi widget cha rebuild
}
```

> **Quan trọng:** `const constructor` yêu cầu tất cả fields phải là `final`, và không có logic tính toán runtime.

---

### 2.3 Properties

#### Instance Properties

```dart
class Circle {
  // Instance field
  double radius;

  Circle(this.radius);
}
```

#### Static Properties

```dart
class MathConstants {
  // Static: thuộc về class, không phải instance
  static const double pi = 3.14159265358979;
  static int instanceCount = 0;

  MathConstants() {
    instanceCount++;
  }
}

void main() {
  print(MathConstants.pi);          // 3.14159...
  MathConstants();
  MathConstants();
  print(MathConstants.instanceCount); // 2
}
```

#### Final và Late

```dart
class Order {
  // final: gán một lần, không thay đổi
  final String id;
  final DateTime createdAt;

  // late: khởi tạo muộn – đảm bảo sẽ được gán trước khi dùng
  late String trackingCode;

  Order(this.id) : createdAt = DateTime.now();

  void ship() {
    trackingCode = 'TRACK-${id.toUpperCase()}';
    print('Đã giao hàng: $trackingCode');
  }
}
```

> **Cảnh báo `late`:** Nếu truy cập `late` field trước khi gán giá trị sẽ throw `LateInitializationError`. Dùng cẩn thận, ưu tiên null safety thay thế khi có thể.

---

### 2.4 Methods

#### Instance Methods

```dart
class BankAccount {
  String owner;
  double _balance; // private field

  BankAccount(this.owner, this._balance);

  void deposit(double amount) {
    if (amount <= 0) throw ArgumentError('Số tiền phải > 0');
    _balance += amount;
  }

  bool withdraw(double amount) {
    if (amount > _balance) return false;
    _balance -= amount;
    return true;
  }
}
```

#### Static Methods

```dart
class Validator {
  // Không cần instance để gọi
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^(0|\+84)[0-9]{9}$').hasMatch(phone);
  }
}

void main() {
  print(Validator.isValidEmail('test@gmail.com')); // true
  print(Validator.isValidPhone('0912345678'));      // true
}
```

#### Getter và Setter

```dart
class Temperature {
  double _celsius;

  Temperature(this._celsius);

  // Getter – đọc như property nhưng có logic
  double get fahrenheit => _celsius * 9 / 5 + 32;
  double get kelvin => _celsius + 273.15;
  double get celsius => _celsius;

  // Setter – gán với validation
  set celsius(double value) {
    if (value < -273.15) {
      throw ArgumentError('Nhiệt độ không thể < -273.15°C');
    }
    _celsius = value;
  }
}

void main() {
  final temp = Temperature(100);
  print(temp.fahrenheit); // 212.0
  print(temp.kelvin);     // 373.15
  temp.celsius = -100;    // OK
  temp.celsius = -300;    // throws ArgumentError
}
```

---

### 2.5 Inheritance (Kế thừa)

```dart
// Lớp cha (base class)
class Animal {
  String name;
  int age;

  Animal(this.name, this.age);

  void breathe() => print('$name đang thở...');

  String describe() => '$name, $age tuổi';
}

// Lớp con kế thừa lớp cha
class Dog extends Animal {
  String breed;

  // super() gọi constructor của lớp cha
  Dog(String name, int age, this.breed) : super(name, age);

  void bark() => print('$name: Gâu gâu!');

  @override
  String describe() => '${super.describe()}, giống ${breed}';
}

class Cat extends Animal {
  bool isIndoor;

  Cat(String name, int age, {this.isIndoor = true}) : super(name, age);

  void meow() => print('$name: Meo meo!');
}

void main() {
  final dog = Dog('Rex', 3, 'Labrador');
  dog.breathe();        // Rex đang thở...
  dog.bark();           // Rex: Gâu gâu!
  print(dog.describe()); // Rex, 3 tuổi, giống Labrador

  final cat = Cat('Mimi', 2);
  cat.meow(); // Mimi: Meo meo!
}
```

> **Quy tắc:** Dart chỉ hỗ trợ **single inheritance** (kế thừa đơn). Để tái sử dụng code từ nhiều nguồn, dùng **Mixin**.

---

### 2.6 Polymorphism (Đa hình)

Đa hình cho phép xử lý các object của các class khác nhau thông qua cùng một interface.

```dart
abstract class Shape {
  double area();
  double perimeter();
  void describe() => print('${runtimeType}: area=${area().toStringAsFixed(2)}');
}

class Rectangle extends Shape {
  double width, height;
  Rectangle(this.width, this.height);

  @override
  double area() => width * height;

  @override
  double perimeter() => 2 * (width + height);
}

class Circle extends Shape {
  double radius;
  Circle(this.radius);

  @override
  double area() => 3.14159 * radius * radius;

  @override
  double perimeter() => 2 * 3.14159 * radius;
}

class Triangle extends Shape {
  double a, b, c;
  Triangle(this.a, this.b, this.c);

  @override
  double area() {
    final s = (a + b + c) / 2;
    return (s * (s - a) * (s - b) * (s - c)).abs().toDouble() == 0
        ? 0
        : (s * (s - a) * (s - b) * (s - c));
  }

  @override
  double perimeter() => a + b + c;
}

void main() {
  final shapes = <Shape>[
    Rectangle(4, 5),
    Circle(3),
    Triangle(3, 4, 5),
  ];

  // Đa hình: cùng gọi describe() nhưng mỗi shape xử lý khác nhau
  for (final shape in shapes) {
    shape.describe();
  }

  // Tính tổng diện tích
  final totalArea = shapes.fold(0.0, (sum, s) => sum + s.area());
  print('Tổng diện tích: ${totalArea.toStringAsFixed(2)}');
}
```

---

### 2.7 Encapsulation (Đóng gói)

Dart dùng tiền tố `_` để đánh dấu private (trong cùng **library/file**).

```dart
// user.dart
class User {
  String _name;       // private – chỉ truy cập trong file này
  String _email;      // private
  String? _password;  // private

  User({required String name, required String email})
      : _name = name,
        _email = email;

  // Public getters – cho phép đọc nhưng không thể ghi trực tiếp
  String get name => _name;
  String get email => _email;

  // Public method để thay đổi state có kiểm soát
  void updateName(String newName) {
    if (newName.trim().isEmpty) throw ArgumentError('Tên không được rỗng');
    _name = newName.trim();
  }

  bool setPassword(String password) {
    if (password.length < 8) return false;
    _password = _hashPassword(password); // dùng private method
    return true;
  }

  bool verifyPassword(String password) {
    return _password == _hashPassword(password);
  }

  // Private method – chỉ dùng nội bộ
  String _hashPassword(String password) {
    // Trong thực tế dùng bcrypt hoặc argon2
    return password.split('').reversed.join(); // demo only
  }
}
```

> **Lưu ý quan trọng:** Private trong Dart là **library-level**, không phải class-level. Nghĩa là các class trong cùng một file vẫn có thể truy cập `_` của nhau.

---

### 2.8 Abstraction (Trừu tượng)

Abstract class định nghĩa "hợp đồng" mà các subclass phải tuân theo.

```dart
// Abstract class – không thể instantiate trực tiếp
abstract class PaymentGateway {
  String get name;

  // Abstract method – subclass bắt buộc phải implement
  Future<bool> charge(double amount, String currency);
  Future<bool> refund(String transactionId);

  // Concrete method – có thể dùng chung hoặc override
  void logTransaction(String message) {
    print('[${name.toUpperCase()}] ${DateTime.now()}: $message');
  }
}

class StripeGateway extends PaymentGateway {
  @override
  String get name => 'Stripe';

  @override
  Future<bool> charge(double amount, String currency) async {
    logTransaction('Charging $amount $currency via Stripe');
    // Gọi Stripe API thực tế ở đây
    await Future.delayed(Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> refund(String transactionId) async {
    logTransaction('Refunding $transactionId via Stripe');
    return true;
  }
}

class MoMoGateway extends PaymentGateway {
  @override
  String get name => 'MoMo';

  @override
  Future<bool> charge(double amount, String currency) async {
    logTransaction('Charging $amount $currency via MoMo');
    return true;
  }

  @override
  Future<bool> refund(String transactionId) async {
    logTransaction('Refunding $transactionId via MoMo');
    return true;
  }
}

// Service dùng abstraction – không quan tâm gateway cụ thể
class CheckoutService {
  final PaymentGateway _gateway;

  CheckoutService(this._gateway);

  Future<void> processOrder(double amount) async {
    final success = await _gateway.charge(amount, 'VND');
    print(success ? 'Thanh toán thành công!' : 'Thanh toán thất bại!');
  }
}

void main() async {
  final service = CheckoutService(MoMoGateway());
  await service.processOrder(250000);
}
```

---

## 3. Trung cấp OOP trong Dart

### 3.1 Mixins

Mixin cho phép tái sử dụng code từ nhiều nguồn mà không cần đa kế thừa.

```dart
// Mixin – dùng từ khóa mixin
mixin Loggable {
  void log(String message) {
    print('[${runtimeType}] ${DateTime.now().toIso8601String()}: $message');
  }
}

mixin Cacheable {
  final Map<String, dynamic> _cache = {};

  T? getFromCache<T>(String key) => _cache[key] as T?;

  void setCache(String key, dynamic value) {
    _cache[key] = value;
    log('Cached: $key'); // gọi được log từ Loggable nếu dùng on
  }
}

mixin Validatable {
  bool validate();

  void validateOrThrow() {
    if (!validate()) throw StateError('$runtimeType validation failed');
  }
}

// Dùng mixin với 'with'
class UserRepository with Loggable, Cacheable {
  Future<Map<String, dynamic>?> getUser(String id) async {
    final cached = getFromCache<Map<String, dynamic>>('user_$id');
    if (cached != null) {
      log('Cache hit for user $id');
      return cached;
    }

    // Giả lập fetch từ API
    await Future.delayed(Duration(milliseconds: 100));
    final user = {'id': id, 'name': 'Nguyễn Văn A'};
    setCache('user_$id', user);
    log('Fetched user $id from API');
    return user;
  }
}
```

#### Mixin với `on` – Ràng buộc kiểu

```dart
abstract class ApiService {
  String get baseUrl;
  Map<String, String> get headers;
}

// Mixin này chỉ dùng được trên class extends/implements ApiService
mixin AuthMixin on ApiService {
  String? _token;

  void setToken(String token) => _token = token;

  @override
  Map<String, String> get headers => {
        ...super.headers, // gọi được vì on ApiService
        if (_token != null) 'Authorization': 'Bearer $_token',
      };
}

class HttpClient extends ApiService with AuthMixin {
  @override
  String get baseUrl => 'https://api.example.com';

  @override
  Map<String, String> get headers => {'Content-Type': 'application/json'};
}
```

> **Khi nào dùng Mixin?** Khi có một tập hành vi (behavior) muốn chia sẻ giữa nhiều class không liên quan nhau theo cây kế thừa. Ví dụ: Loggable, Serializable, Cacheable.

---

### 3.2 Interfaces

Dart không có từ khóa `interface` riêng. Mọi class đều có thể dùng như interface thông qua `implements`.

```dart
// Class thường dùng như interface
class Drawable {
  void draw() {}
  void resize(double factor) {}
}

// Abstract class làm interface – phổ biến hơn
abstract class Repository<T, ID> {
  Future<T?> findById(ID id);
  Future<List<T>> findAll();
  Future<T> save(T entity);
  Future<void> delete(ID id);
}

// implements – phải implement TẤT CẢ method, kể cả concrete method
class ProductRepository implements Repository<Product, String> {
  final Map<String, Product> _store = {};

  @override
  Future<Product?> findById(String id) async => _store[id];

  @override
  Future<List<Product>> findAll() async => _store.values.toList();

  @override
  Future<Product> save(Product entity) async {
    _store[entity.id] = entity;
    return entity;
  }

  @override
  Future<void> delete(String id) async => _store.remove(id);
}

class Product {
  final String id;
  final String name;
  final double price;
  const Product({required this.id, required this.name, required this.price});
}
```

---

### 3.3 Abstract Class vs Interface – So sánh

| Tiêu chí | Abstract Class | Interface (`implements`) |
|----------|---------------|--------------------------|
| Instantiate | Không | Không |
| Có code cụ thể | Có | Khi dùng class thường: phải override lại |
| Kế thừa nhiều | Không (chỉ 1 extends) | Có (implements nhiều) |
| Mục đích | "Is-a" relationship | Định nghĩa "contract" |
| Mixin | Kết hợp được | Kết hợp được |
| Constructor | Có | Không cần thiết |

```dart
// BEST PRACTICE: Kết hợp cả ba
abstract class BaseWidget {
  // Abstract class: định nghĩa template
  String get widgetName;
  Widget build(BuildContext context);

  // Shared logic
  void logBuild() => print('Building $widgetName');
}

abstract class Interactable {
  void onTap();
  void onLongPress() {} // optional override
}

// Class kế thừa và implement
class Button extends BaseWidget implements Interactable {
  @override
  String get widgetName => 'Button';

  @override
  Widget build(BuildContext context) {
    logBuild();
    return Container(); // simplified
  }

  @override
  void onTap() => print('Button tapped!');
}
```

---

### 3.4 Extension Methods

Thêm method vào class có sẵn mà không cần sửa source gốc.

```dart
// Extension trên String
extension StringExtension on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');

  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  String toCamelCase() {
    final parts = split(RegExp(r'[_\s-]'));
    if (parts.isEmpty) return this;
    return parts[0].toLowerCase() +
        parts.skip(1).map((p) => p.capitalize).join();
  }
}

// Extension trên List
extension ListExtension<T> on List<T> {
  List<T> get shuffled => [...this]..shuffle();
  T? get randomElement => isEmpty ? null : this[DateTime.now().millisecond % length];
  List<List<T>> chunked(int size) {
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(i, i + size > length ? length : i + size));
    }
    return result;
  }
}

// Extension trên Widget (Flutter)
extension WidgetExtension on Widget {
  Widget padAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  Widget center() => Center(child: this);
}

void main() {
  print('hello world'.titleCase);         // Hello World
  print('user_name'.toCamelCase());       // userName
  print('test@gmail.com'.isValidEmail);   // true

  final list = [1, 2, 3, 4, 5, 6, 7];
  print(list.chunked(3)); // [[1,2,3],[4,5,6],[7]]
}
```

> **Lưu ý:** Extension method không thể truy cập private members (`_`). Extension chỉ thêm được method và getter/setter, không thêm được field.

---

### 3.5 Generics

Generics cho phép viết code tái sử dụng với type-safe.

#### Generic Class

```dart
// Stack generic
class Stack<T> {
  final List<T> _items = [];

  void push(T item) => _items.add(item);

  T pop() {
    if (isEmpty) throw StateError('Stack is empty');
    return _items.removeLast();
  }

  T get peek {
    if (isEmpty) throw StateError('Stack is empty');
    return _items.last;
  }

  bool get isEmpty => _items.isEmpty;
  int get size => _items.length;
}

// Result type – pattern phổ biến trong Flutter
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result.success(this.data)
      : error = null,
        isSuccess = true;

  const Result.failure(this.error)
      : data = null,
        isSuccess = false;

  R when<R>({
    required R Function(T data) success,
    required R Function(String error) failure,
  }) {
    if (isSuccess && data != null) return success(data as T);
    return failure(error ?? 'Unknown error');
  }
}

Future<Result<List<String>>> fetchUsers() async {
  try {
    await Future.delayed(Duration(milliseconds: 100));
    return Result.success(['An', 'Bình', 'Cường']);
  } catch (e) {
    return Result.failure(e.toString());
  }
}

void main() async {
  final result = await fetchUsers();
  result.when(
    success: (users) => print('Users: $users'),
    failure: (err) => print('Error: $err'),
  );
}
```

#### Generic Method và Constraint

```dart
// Constraint với extends
T max<T extends Comparable<T>>(T a, T b) => a.compareTo(b) > 0 ? a : b;

// Constraint với múc tiêu phức tạp hơn
class Repository<T extends Entity> {
  Future<T?> findById(String id) async {
    // T được đảm bảo có id property vì extends Entity
    return null;
  }
}

abstract class Entity {
  String get id;
}

void main() {
  print(max(3, 7));         // 7
  print(max('apple', 'banana')); // banana
  print(max(3.14, 2.71));   // 3.14
}
```

---

### 3.6 Null Safety

Null safety là một trong những tính năng quan trọng nhất của Dart 2.12+.

```dart
// Nullable vs Non-nullable
String nonNullable = 'Giá trị này không bao giờ null';
String? nullable = null; // Có thể null

// Toán tử null-aware
String? name = null;

// ?? – Null coalescing
final displayName = name ?? 'Ẩn danh';

// ?.  – Null-aware access
final length = name?.length; // null nếu name là null

// ??= – Null-aware assignment
name ??= 'Người dùng mới'; // gán chỉ khi null

// ! – Null assertion (cẩn thận!)
// Chỉ dùng khi chắc chắn không null, vì nếu sai -> runtime error
final forced = name!; // throws nếu name là null

// Late initialization
class UserProfile {
  late String _displayName; // sẽ gán trước khi dùng

  void init(String name) {
    _displayName = name;
  }

  String get displayName => _displayName;
}

// Required parameter
class ApiConfig {
  final String baseUrl;
  final String apiKey;
  final int? timeout; // optional

  const ApiConfig({
    required this.baseUrl, // bắt buộc
    required this.apiKey,  // bắt buộc
    this.timeout,          // optional
  });
}

// Pattern hay gặp trong Flutter
Future<void> processUser(String? userId) async {
  // Guard clause
  if (userId == null) return;
  // Sau đây userId đã được promote thành String (non-nullable)
  print(userId.length); // an toàn
}
```

**Bảng tóm tắt toán tử null safety:**

| Toán tử | Ý nghĩa | Ví dụ |
|---------|---------|-------|
| `?` | Khai báo nullable | `String? name` |
| `??` | Giá trị mặc định nếu null | `name ?? 'default'` |
| `?.` | Truy cập an toàn | `name?.length` |
| `??=` | Gán nếu null | `name ??= 'value'` |
| `!` | Ép buộc non-null | `name!` |
| `late` | Khởi tạo muộn | `late String x` |

---

### 3.7 Enums (Enhanced Enum – Dart 2.17+)

```dart
// Enum cơ bản
enum Status { pending, processing, completed, failed }

// Enhanced enum – có field, method, constructor
enum OrderStatus {
  pending('Chờ xử lý', '🕐'),
  confirmed('Đã xác nhận', '✅'),
  shipping('Đang giao', '🚚'),
  delivered('Đã giao', '📦'),
  cancelled('Đã hủy', '❌');

  final String label;
  final String icon;

  const OrderStatus(this.label, this.icon);

  bool get isActive => this != cancelled && this != delivered;

  String get displayText => '$icon $label';

  // Factory method trong enum
  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

void main() {
  final status = OrderStatus.shipping;
  print(status.displayText); // 🚚 Đang giao
  print(status.isActive);    // true

  // Switch với enum
  final message = switch (status) {
    OrderStatus.pending => 'Đơn hàng đang chờ xử lý',
    OrderStatus.shipping => 'Đơn hàng đang trên đường',
    OrderStatus.delivered => 'Đơn hàng đã đến nơi',
    _ => 'Trạng thái khác',
  };
  print(message);
}
```

---

### 3.8 Records (Dart 3+)

Records là kiểu dữ liệu tổng hợp bất biến, nhẹ hơn class.

```dart
// Record type
typedef Point = (double x, double y);
typedef UserInfo = ({String name, int age, String email});

void main() {
  // Positional record
  final point = (3.0, 4.0);
  print(point.$1); // 3.0
  print(point.$2); // 4.0

  // Named record
  final user = (name: 'An', age: 25, email: 'an@example.com');
  print(user.name);  // An
  print(user.age);   // 25

  // Destructuring
  final (x, y) = point;
  print('x=$x, y=$y');

  final (:name, :age, :email) = user;
  print('$name ($age) - $email');

  // Record trong function return
  final minMax = getMinMax([3, 1, 4, 1, 5, 9, 2, 6]);
  print('Min: ${minMax.$1}, Max: ${minMax.$2}');
}

// Function trả về nhiều giá trị thanh lịch
(int min, int max) getMinMax(List<int> numbers) {
  if (numbers.isEmpty) throw ArgumentError('List is empty');
  return (
    numbers.reduce((a, b) => a < b ? a : b),
    numbers.reduce((a, b) => a > b ? a : b),
  );
}

// Record trong class
class CartItem {
  final String productId;
  final int quantity;
  final double price;

  const CartItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  // Trả về summary như record
  ({double total, double tax}) get summary {
    final total = quantity * price;
    return (total: total, tax: total * 0.1);
  }
}
```

---

### 3.9 Pattern Matching (Dart 3+)

```dart
sealed class Shape {}
class Circle extends Shape { final double radius; Circle(this.radius); }
class Rectangle extends Shape { final double w, h; Rectangle(this.w, this.h); }
class Triangle extends Shape { final double a, b, c; Triangle(this.a, this.b, this.c); }

double calculateArea(Shape shape) => switch (shape) {
  Circle(:final radius) => 3.14159 * radius * radius,
  Rectangle(:final w, :final h) => w * h,
  Triangle(:final a, :final b, :final c) => _triangleArea(a, b, c),
};

double _triangleArea(double a, double b, double c) {
  final s = (a + b + c) / 2;
  return (s * (s - a) * (s - b) * (s - c)).toDouble();
}

void main() {
  // Switch expression
  final shapes = [Circle(5), Rectangle(4, 6), Triangle(3, 4, 5)];
  for (final shape in shapes) {
    print('Area: ${calculateArea(shape).toStringAsFixed(2)}');
  }

  // Pattern matching với if-case
  final dynamic value = [1, 2, 3];
  if (value case [int first, int second, ...]) {
    print('List starts with $first, $second');
  }

  // Object pattern
  final user = {'name': 'An', 'age': 25};
  if (user case {'name': String name, 'age': int age}) {
    print('$name is $age years old');
  }

  // Guard clause trong pattern
  final score = 85;
  final grade = switch (score) {
    >= 90 => 'A',
    >= 80 => 'B',
    >= 70 => 'C',
    >= 60 => 'D',
    _ => 'F',
  };
  print('Grade: $grade'); // B
}
```

---

## 4. Nâng cao OOP trong Dart

### 4.1 Effective Dart & Clean Code OOP

#### Quy tắc đặt tên

```dart
// ✅ ĐÚNG
class UserRepository {}     // PascalCase cho class
const maxRetries = 3;       // lowerCamelCase cho variable/const
void fetchUserData() {}     // lowerCamelCase cho method
static const defaultTimeout = 30; // lowerCamelCase

// ✅ Private
String _internalState = '';
void _processData() {}

// ❌ SAI
class user_repository {}
const MaxRetries = 3;
void FetchUserData() {}
```

#### Prefer composition over inheritance

```dart
// ❌ Kế thừa sâu – khó maintain
class Animal {}
class Pet extends Animal {}
class Dog extends Pet {}
class TrainedDog extends Dog {}
class ServiceDog extends TrainedDog {}

// ✅ Composition – linh hoạt hơn
class Dog {
  final TrainingBehavior training;
  final HealthTracker health;
  final SocialBehavior social;

  Dog({required this.training, required this.health, required this.social});
}
```

#### Immutable objects

```dart
// ✅ Immutable model – an toàn hơn, dễ debug
class UserModel {
  final String id;
  final String name;
  final String email;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  // copyWith thay vì mutate
  UserModel copyWith({String? name, String? email}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && id == other.id && name == other.name && email == other.email;

  @override
  int get hashCode => Object.hash(id, name, email);

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}
```

---

### 4.2 SOLID Principles trong Dart

#### S – Single Responsibility Principle

```dart
// ❌ VI PHẠM – class làm quá nhiều thứ
class UserManager {
  void registerUser(String email, String password) { /* ... */ }
  void sendWelcomeEmail(String email) { /* ... */ }
  void saveToDatabase(Map data) { /* ... */ }
  void logActivity(String action) { /* ... */ }
}

// ✅ ĐÚNG – mỗi class chỉ một trách nhiệm
class UserRegistrationService {
  final UserRepository _repo;
  final EmailService _email;
  final Logger _logger;

  UserRegistrationService(this._repo, this._email, this._logger);

  Future<User> register(String email, String password) async {
    final user = await _repo.create(email, password);
    await _email.sendWelcomeEmail(user.email);
    _logger.info('User registered: ${user.email}');
    return user;
  }
}
```

#### O – Open/Closed Principle

```dart
// ✅ MỞ để mở rộng, ĐÓNG để sửa đổi
abstract class DiscountStrategy {
  double apply(double price);
}

class NoDiscount extends DiscountStrategy {
  @override
  double apply(double price) => price;
}

class PercentageDiscount extends DiscountStrategy {
  final double percentage;
  PercentageDiscount(this.percentage);

  @override
  double apply(double price) => price * (1 - percentage / 100);
}

class SeasonalDiscount extends DiscountStrategy {
  final double amount;
  SeasonalDiscount(this.amount);

  @override
  double apply(double price) => (price - amount).clamp(0, double.infinity);
}

// Thêm discount mới không cần sửa OrderService
class OrderService {
  DiscountStrategy _discount;
  OrderService(this._discount);

  void setDiscount(DiscountStrategy discount) => _discount = discount;

  double calculateTotal(double price) => _discount.apply(price);
}
```

#### L – Liskov Substitution Principle

```dart
// ✅ Subtype có thể thay thế parent type
abstract class Bird {
  void eat();
}

abstract class FlyingBird extends Bird {
  void fly();
}

// ✅ Penguin không vi phạm – nó không extends FlyingBird
class Penguin extends Bird {
  @override
  void eat() => print('Chim cánh cụt ăn cá');
}

class Eagle extends FlyingBird {
  @override
  void eat() => print('Đại bàng ăn thỏ');

  @override
  void fly() => print('Đại bàng bay cao');
}
```

#### I – Interface Segregation Principle

```dart
// ❌ Interface quá lớn
abstract class WorkerInterface {
  void work();
  void eat();
  void sleep();
  void manage();
  void report();
}

// ✅ Tách nhỏ interface theo responsibility
abstract class Workable { void work(); }
abstract class Eatable { void eat(); }
abstract class Manageable { void manage(); }

class Developer implements Workable, Eatable {
  @override void work() => print('Viết code');
  @override void eat() => print('Ăn cơm hộp');
}

class Manager implements Workable, Eatable, Manageable {
  @override void work() => print('Họp hành');
  @override void eat() => print('Ăn nhà hàng');
  @override void manage() => print('Quản lý team');
}
```

#### D – Dependency Inversion Principle

```dart
// ✅ Depend on abstractions, not concretions
abstract class NotificationChannel {
  Future<void> send(String message, String recipient);
}

class EmailNotification implements NotificationChannel {
  @override
  Future<void> send(String message, String recipient) async {
    print('Email to $recipient: $message');
  }
}

class PushNotification implements NotificationChannel {
  @override
  Future<void> send(String message, String recipient) async {
    print('Push to $recipient: $message');
  }
}

class SMSNotification implements NotificationChannel {
  @override
  Future<void> send(String message, String recipient) async {
    print('SMS to $recipient: $message');
  }
}

// NotificationService không biết channel cụ thể
class NotificationService {
  final List<NotificationChannel> _channels;

  NotificationService(this._channels);

  Future<void> notify(String message, String recipient) async {
    await Future.wait(
      _channels.map((c) => c.send(message, recipient)),
    );
  }
}

void main() async {
  final service = NotificationService([
    EmailNotification(),
    PushNotification(),
  ]);
  await service.notify('Đơn hàng đã được xác nhận!', 'user@example.com');
}
```

---

### 4.3 Design Patterns trong Dart

#### Singleton Pattern

```dart
class DatabaseConnection {
  static DatabaseConnection? _instance;
  late final String connectionString;

  DatabaseConnection._() {
    connectionString = 'postgresql://localhost:5432/mydb';
    print('Kết nối database...');
  }

  factory DatabaseConnection.instance() {
    return _instance ??= DatabaseConnection._();
  }

  Future<List<Map>> query(String sql) async {
    // thực hiện query
    return [];
  }
}

// Thread-safe hơn với late static
class Config {
  static final Config _instance = Config._internal();
  factory Config() => _instance;
  Config._internal();

  final String env = const String.fromEnvironment('ENV', defaultValue: 'dev');
}
```

#### Factory Method Pattern

```dart
abstract class Button {
  void render();
  void onClick();
}

class IOSButton extends Button {
  @override void render() => print('Render iOS Button (Cupertino style)');
  @override void onClick() => print('iOS tap feedback');
}

class AndroidButton extends Button {
  @override void render() => print('Render Android Button (Material style)');
  @override void onClick() => print('Android ripple effect');
}

class WebButton extends Button {
  @override void render() => print('Render Web Button (HTML style)');
  @override void onClick() => print('Web click');
}

// Factory
class ButtonFactory {
  static Button create(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.iOS => IOSButton(),
      TargetPlatform.android => AndroidButton(),
      _ => WebButton(),
    };
  }
}

enum TargetPlatform { iOS, android, web }
```

#### Builder Pattern

```dart
class HttpRequest {
  final String url;
  final String method;
  final Map<String, String> headers;
  final Map<String, dynamic>? body;
  final int timeout;

  const HttpRequest._({
    required this.url,
    required this.method,
    required this.headers,
    this.body,
    required this.timeout,
  });

  static HttpRequestBuilder builder(String url) => HttpRequestBuilder._(url);
}

class HttpRequestBuilder {
  final String _url;
  String _method = 'GET';
  final Map<String, String> _headers = {};
  Map<String, dynamic>? _body;
  int _timeout = 30;

  HttpRequestBuilder._(this._url);

  HttpRequestBuilder method(String method) {
    _method = method;
    return this;
  }

  HttpRequestBuilder header(String key, String value) {
    _headers[key] = value;
    return this;
  }

  HttpRequestBuilder bearerToken(String token) {
    return header('Authorization', 'Bearer $token');
  }

  HttpRequestBuilder json(Map<String, dynamic> body) {
    _body = body;
    return header('Content-Type', 'application/json');
  }

  HttpRequestBuilder timeout(int seconds) {
    _timeout = seconds;
    return this;
  }

  HttpRequest build() => HttpRequest._(
        url: _url,
        method: _method,
        headers: Map.unmodifiable(_headers),
        body: _body,
        timeout: _timeout,
      );
}

void main() {
  final request = HttpRequest.builder('https://api.example.com/users')
      .method('POST')
      .bearerToken('my-token-123')
      .json({'name': 'An', 'email': 'an@example.com'})
      .timeout(15)
      .build();

  print('${request.method} ${request.url}');
  print('Headers: ${request.headers}');
}
```

#### Observer Pattern

```dart
// Observer (Event System)
typedef Listener<T> = void Function(T event);

class EventBus<T> {
  final List<Listener<T>> _listeners = [];

  void subscribe(Listener<T> listener) => _listeners.add(listener);

  void unsubscribe(Listener<T> listener) => _listeners.remove(listener);

  void publish(T event) {
    for (final listener in List.from(_listeners)) {
      listener(event);
    }
  }
}

// Sự kiện
class CartEvent {
  final String type;
  final Map<String, dynamic> data;
  const CartEvent(this.type, this.data);
}

// Trong Flutter với ChangeNotifier
class CartNotifier extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get total => _items.fold(0, (sum, item) => sum + item.total);

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners(); // Observer pattern built-in
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }
}

class CartItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  const CartItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });
  double get total => quantity * price;
}
```

#### Repository Pattern

```dart
// Entity
class Product {
  final String id;
  final String name;
  final double price;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });
}

// Abstract Repository
abstract class ProductRepository {
  Future<Product?> findById(String id);
  Future<List<Product>> findAll({int page = 1, int limit = 20});
  Future<List<Product>> search(String query);
  Future<Product> save(Product product);
  Future<void> delete(String id);
}

// Remote implementation
class RemoteProductRepository implements ProductRepository {
  final HttpClient _client;
  RemoteProductRepository(this._client);

  @override
  Future<Product?> findById(String id) async {
    // final response = await _client.get('/products/$id');
    // return Product.fromJson(response);
    return null; // simplified
  }

  @override
  Future<List<Product>> findAll({int page = 1, int limit = 20}) async {
    return [];
  }

  @override
  Future<List<Product>> search(String query) async {
    return [];
  }

  @override
  Future<Product> save(Product product) async {
    return product;
  }

  @override
  Future<void> delete(String id) async {}
}

// Local/Cache implementation
class CachedProductRepository implements ProductRepository {
  final ProductRepository _remote;
  final Map<String, Product> _cache = {};

  CachedProductRepository(this._remote);

  @override
  Future<Product?> findById(String id) async {
    return _cache[id] ?? await _remote.findById(id);
  }

  @override
  Future<List<Product>> findAll({int page = 1, int limit = 20}) =>
      _remote.findAll(page: page, limit: limit);

  @override
  Future<List<Product>> search(String query) => _remote.search(query);

  @override
  Future<Product> save(Product product) async {
    final saved = await _remote.save(product);
    _cache[saved.id] = saved;
    return saved;
  }

  @override
  Future<void> delete(String id) async {
    await _remote.delete(id);
    _cache.remove(id);
  }
}

class HttpClient {
  Future<dynamic> get(String path) async {}
}
```

#### Strategy Pattern

```dart
// Sorting strategies
abstract class SortStrategy<T> {
  List<T> sort(List<T> items, Comparator<T> comparator);
}

class BubbleSortStrategy<T> implements SortStrategy<T> {
  @override
  List<T> sort(List<T> items, Comparator<T> comparator) {
    final list = List<T>.from(items);
    for (var i = 0; i < list.length - 1; i++) {
      for (var j = 0; j < list.length - 1 - i; j++) {
        if (comparator(list[j], list[j + 1]) > 0) {
          final temp = list[j];
          list[j] = list[j + 1];
          list[j + 1] = temp;
        }
      }
    }
    return list;
  }
}

class QuickSortStrategy<T> implements SortStrategy<T> {
  @override
  List<T> sort(List<T> items, Comparator<T> comparator) {
    if (items.length <= 1) return items;
    final list = List<T>.from(items);
    _quickSort(list, 0, list.length - 1, comparator);
    return list;
  }

  void _quickSort(List<T> list, int low, int high, Comparator<T> comparator) {
    if (low < high) {
      final pivot = _partition(list, low, high, comparator);
      _quickSort(list, low, pivot - 1, comparator);
      _quickSort(list, pivot + 1, high, comparator);
    }
  }

  int _partition(List<T> list, int low, int high, Comparator<T> comparator) {
    final pivot = list[high];
    var i = low - 1;
    for (var j = low; j < high; j++) {
      if (comparator(list[j], pivot) <= 0) {
        i++;
        final temp = list[i];
        list[i] = list[j];
        list[j] = temp;
      }
    }
    final temp = list[i + 1];
    list[i + 1] = list[high];
    list[high] = temp;
    return i + 1;
  }
}

class Sorter<T> {
  SortStrategy<T> _strategy;
  Sorter(this._strategy);

  void setStrategy(SortStrategy<T> strategy) => _strategy = strategy;

  List<T> sort(List<T> items, Comparator<T> comparator) =>
      _strategy.sort(items, comparator);
}
```

#### BLoC Pattern (Flutter)

```dart
import 'dart:async';

// Events
abstract class AuthEvent {}
class LoginEvent extends AuthEvent {
  final String email, password;
  LoginEvent(this.email, this.password);
}
class LogoutEvent extends AuthEvent {}

// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String userId;
  AuthAuthenticated(this.userId);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// BLoC
class AuthBloc {
  final _eventController = StreamController<AuthEvent>();
  final _stateController = StreamController<AuthState>.broadcast();

  Sink<AuthEvent> get events => _eventController.sink;
  Stream<AuthState> get states => _stateController.stream;

  AuthBloc() {
    _eventController.stream.listen(_mapEventToState);
  }

  Future<void> _mapEventToState(AuthEvent event) async {
    if (event is LoginEvent) {
      _stateController.add(AuthLoading());
      try {
        await Future.delayed(Duration(seconds: 1)); // giả lập API
        if (event.email == 'test@gmail.com' && event.password == '12345678') {
          _stateController.add(AuthAuthenticated('user_001'));
        } else {
          _stateController.add(AuthError('Email hoặc mật khẩu không đúng'));
        }
      } catch (e) {
        _stateController.add(AuthError(e.toString()));
      }
    } else if (event is LogoutEvent) {
      _stateController.add(AuthInitial());
    }
  }

  void dispose() {
    _eventController.close();
    _stateController.close();
  }
}
```

---

### 4.4 Isolate & Concurrency

Dart là single-threaded nhưng hỗ trợ concurrency thông qua Isolate.

```dart
import 'dart:isolate';

// Future & async/await – xử lý I/O không đồng bộ (không cần Isolate)
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Dữ liệu từ API';
}

// Isolate – chạy code trên thread riêng (CPU-intensive tasks)
Future<int> computeFibonacciInIsolate(int n) async {
  return await Isolate.run(() => _fibonacci(n));
}

int _fibonacci(int n) {
  if (n <= 1) return n;
  return _fibonacci(n - 1) + _fibonacci(n - 2);
}

// Compute (Flutter) – wrapper tiện lợi
// import 'package:flutter/foundation.dart';
// final result = await compute(_fibonacci, 40);

// Stream – xử lý dữ liệu theo thời gian thực
Stream<int> countdown(int from) async* {
  for (var i = from; i >= 0; i--) {
    yield i;
    await Future.delayed(Duration(seconds: 1));
  }
}

void main() async {
  // Future
  final data = await fetchData();
  print(data);

  // Isolate
  final fib = await computeFibonacciInIsolate(35);
  print('Fibonacci(35) = $fib');

  // Stream
  await for (final count in countdown(5)) {
    print(count);
  }
}
```

---

### 4.5 Functional Programming kết hợp OOP

```dart
// Higher-order functions
List<T> myMap<T, R>(List<R> list, T Function(R) transform) {
  return list.map(transform).toList();
}

List<T> myFilter<T>(List<T> list, bool Function(T) predicate) {
  return list.where(predicate).toList();
}

// Closure
Function makeMultiplier(int factor) {
  return (int x) => x * factor; // closure capture factor
}

// Function composition
typedef Transform<T> = T Function(T);

Transform<T> compose<T>(List<Transform<T>> transforms) {
  return (T input) => transforms.fold(input, (acc, fn) => fn(acc));
}

void main() {
  // OOP + FP kết hợp
  final products = [
    Product(id: '1', name: 'Áo', price: 200000, stock: 10),
    Product(id: '2', name: 'Quần', price: 350000, stock: 0),
    Product(id: '3', name: 'Giày', price: 500000, stock: 5),
  ];

  // Fluent pipeline style
  final result = products
      .where((p) => p.stock > 0)                    // filter
      .map((p) => p.copyWith(price: p.price * 0.9)) // transform
      .toList()
      ..sort((a, b) => a.price.compareTo(b.price)); // sort

  // fold / reduce
  final totalValue = products
      .fold<double>(0, (sum, p) => sum + p.price * p.stock);

  print('Total inventory value: ${totalValue.toStringAsFixed(0)} VND');

  // Multiplier
  final double3x = makeMultiplier(3);
  print(double3x(10)); // 30
}

class Product {
  final String id, name;
  final double price;
  final int stock;
  const Product({required this.id, required this.name, required this.price, required this.stock});
  Product copyWith({String? name, double? price, int? stock}) =>
      Product(id: id, name: name ?? this.name, price: price ?? this.price, stock: stock ?? this.stock);
}
```

---

### 4.6 Testing OOP

```dart
// Cài đặt: flutter pub add dev:test dev:mockito dev:build_runner

// Unit test
// test/user_service_test.dart
import 'package:test/test.dart';

class UserService {
  final UserRepository repository;
  UserService(this.repository);

  Future<User?> getUserById(String id) async {
    if (id.isEmpty) throw ArgumentError('ID không được rỗng');
    return repository.findById(id);
  }
}

abstract class UserRepository {
  Future<User?> findById(String id);
}

class User {
  final String id, name;
  const User({required this.id, required this.name});
}

// Mock thủ công (không cần mockito)
class MockUserRepository implements UserRepository {
  User? _mockUser;
  bool _shouldThrow = false;

  void setUser(User user) => _mockUser = user;
  void setThrow() => _shouldThrow = true;

  @override
  Future<User?> findById(String id) async {
    if (_shouldThrow) throw Exception('DB Error');
    return _mockUser;
  }
}

void main() {
  group('UserService', () {
    late MockUserRepository mockRepo;
    late UserService service;

    setUp(() {
      mockRepo = MockUserRepository();
      service = UserService(mockRepo);
    });

    test('returns user when found', () async {
      mockRepo.setUser(User(id: '1', name: 'An'));

      final user = await service.getUserById('1');

      expect(user, isNotNull);
      expect(user?.name, equals('An'));
    });

    test('throws when id is empty', () {
      expect(
        () => service.getUserById(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('returns null when user not found', () async {
      final user = await service.getUserById('999');
      expect(user, isNull);
    });
  });
}
```

---

### 4.7 Performance Optimization trong OOP

#### Const Constructor

```dart
// ✅ Dùng const khi object không đổi
class AppColors {
  static const primary = Color(0xFF2196F3);
  static const secondary = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
}

// Flutter: const widget không rebuild
// ✅
const Text('Hello World')
const SizedBox(height: 16)
const Icon(Icons.home)

// ❌ Sẽ rebuild mỗi khi parent rebuild
Text('Hello World')
SizedBox(height: 16)
```

#### Freezed – Code generation cho Immutable classes

```dart
// pubspec.yaml:
// dependencies:
//   freezed_annotation: ^2.4.1
// dev_dependencies:
//   freezed: ^2.4.5
//   build_runner: ^2.4.7

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.initial() = _Initial;
  const factory UserState.loading() = _Loading;
  const factory UserState.loaded(List<User> users) = _Loaded;
  const factory UserState.error(String message) = _Error;
}

// Sử dụng
void handleState(UserState state) {
  state.when(
    initial: () => print('Chưa load'),
    loading: () => print('Đang load...'),
    loaded: (users) => print('Có ${users.length} users'),
    error: (msg) => print('Lỗi: $msg'),
  );
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    @Default(false) bool isActive,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
// Run: dart run build_runner build
```

#### Avoid premature optimization – nhưng chú ý

```dart
// ✅ Tránh tạo object không cần thiết trong vòng lặp
// ❌
for (final item in items) {
  final date = DateFormat('dd/MM/yyyy'); // tạo mới mỗi iteration
  print(date.format(item.createdAt));
}

// ✅
final date = DateFormat('dd/MM/yyyy'); // tạo một lần
for (final item in items) {
  print(date.format(item.createdAt));
}

// ✅ Dùng StringBuffer thay vì nối chuỗi
String buildReport(List<String> lines) {
  final buffer = StringBuffer();
  for (final line in lines) {
    buffer.writeln(line);
  }
  return buffer.toString();
}
```

---

### 4.8 Best Practices & Common Pitfalls

#### Best Practices

```dart
// 1. Prefer named parameters cho constructor có nhiều tham số
class Widget {
  // ❌
  Widget(String title, double width, double height, Color color, bool enabled);

  // ✅
  Widget({
    required String title,
    required double width,
    required double height,
    Color color = const Color(0xFF000000),
    bool enabled = true,
  });
}

// 2. Dùng sealed class + pattern matching thay vì instanceof chain
sealed class ApiResponse<T> {}
class ApiSuccess<T> extends ApiResponse<T> { final T data; ApiSuccess(this.data); }
class ApiFailure<T> extends ApiResponse<T> { final String message; ApiFailure(this.message); }
class ApiLoading<T> extends ApiResponse<T> {}

// Xử lý exhaustive – compiler sẽ báo lỗi nếu thiếu case
String getMessage(ApiResponse response) => switch (response) {
  ApiSuccess(:final data) => 'Success: $data',
  ApiFailure(:final message) => 'Error: $message',
  ApiLoading() => 'Loading...',
};

// 3. Cascade notation cho fluent API
class QueryBuilder {
  String _table = '';
  final List<String> _conditions = [];
  int? _limit;

  QueryBuilder from(String table) { _table = table; return this; }
  QueryBuilder where(String condition) { _conditions.add(condition); return this; }
  QueryBuilder limit(int n) { _limit = n; return this; }
  String build() => 'SELECT * FROM $_table'
    '${_conditions.isNotEmpty ? ' WHERE ${_conditions.join(' AND ')}' : ''}'
    '${_limit != null ? ' LIMIT $_limit' : ''}';
}

final query = QueryBuilder()
  ..from('users')
  ..where('age > 18')
  ..where('is_active = true')
  ..limit(10);
```

#### Common Pitfalls

```dart
// ❌ PITFALL 1: Quên late init
class Service {
  late Repository _repo;
  // Nếu method gọi _repo trước init() -> LateInitializationError
  void init() { _repo = Repository(); }
}
// ✅ Tốt hơn: inject qua constructor
class Service2 {
  final Repository _repo;
  Service2(this._repo);
}

// ❌ PITFALL 2: Mutable default parameter
class Config {
  List<String> tags;
  Config({this.tags = const []}); // ✅ dùng const []
  // Config({List<String>? tags}) : tags = tags ?? []; // cũng OK
}

// ❌ PITFALL 3: Override == mà quên hashCode
class Point {
  final int x, y;
  Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Point && x == other.x && y == other.y;

  // ❌ Nếu quên hashCode: Set/Map sẽ hoạt động sai
  @override
  int get hashCode => Object.hash(x, y); // ✅ luôn override cả hai
}

// ❌ PITFALL 4: Circular dependency
// UserService -> OrderService -> UserService (vòng tròn)
// ✅ Dùng event bus hoặc tách abstract interface

// ❌ PITFALL 5: Giữ BuildContext qua async gap (Flutter)
Future<void> badMethod(BuildContext context) async {
  await Future.delayed(Duration(seconds: 1));
  Navigator.of(context).pop(); // UNSAFE nếu widget đã unmount
}

Future<void> goodMethod(BuildContext context) async {
  final navigator = Navigator.of(context); // lưu trước
  await Future.delayed(Duration(seconds: 1));
  if (context.mounted) { // check mounted (Dart 3)
    navigator.pop();
  }
}
```

---

### 4.9 Meta-programming với Mirrors

```dart
// ⚠️ Mirrors chỉ dùng trong Dart VM, KHÔNG hoạt động khi compile AOT (Flutter mobile/desktop)
// Chỉ dùng cho: CLI tools, server-side Dart, test utilities

import 'dart:mirrors';

class ReflectionExample {
  String name = 'Dart';
  int version = 3;

  void printInfo() => print('$name v$version');
}

void inspectClass(Type type) {
  final mirror = reflectClass(type);
  print('Class: ${mirror.simpleName}');

  mirror.declarations.forEach((symbol, declaration) {
    if (declaration is VariableMirror) {
      print('  Field: ${MirrorSystem.getName(symbol)}');
    } else if (declaration is MethodMirror && !declaration.isConstructor) {
      print('  Method: ${MirrorSystem.getName(symbol)}');
    }
  });
}

// ✅ Thay thế cho Flutter: Code generation (build_runner)
// json_serializable, freezed, injectable, drift đều dùng code gen
```

---

## 5. Tài liệu tham khảo & Mẹo thực tế

### Tài liệu chính thức

| Tài liệu | Link |
|----------|------|
| Dart Language Tour | https://dart.dev/language |
| Dart API Reference | https://api.dart.dev |
| Effective Dart | https://dart.dev/effective-dart |
| Flutter Docs | https://flutter.dev/docs |
| Pub.dev (packages) | https://pub.dev |

### Công cụ hỗ trợ

#### Package thiết yếu cho OOP trong Flutter

```yaml
# pubspec.yaml
dependencies:
  # State management
  flutter_bloc: ^8.1.3          # BLoC pattern
  riverpod: ^2.4.9              # Provider nâng cao
  provider: ^6.1.1              # Simple state management

  # DI (Dependency Injection)
  get_it: ^7.6.4                # Service locator
  injectable: ^2.3.2            # DI code gen

  # Immutable models
  freezed_annotation: ^2.4.1    # Model code gen
  json_annotation: ^4.8.1       # JSON serialization

  # Utilities
  equatable: ^2.0.5             # == và hashCode tự động
  dartz: ^0.10.1                # Functional programming (Either, Option)

dev_dependencies:
  build_runner: ^2.4.7          # Code generation runner
  freezed: ^2.4.5               # Freezed code gen
  json_serializable: ^6.7.1     # JSON code gen
  injectable_generator: ^2.4.1  # Injectable code gen
  mockito: ^5.4.3               # Mocking cho test
```

#### Dart DevTools

```bash
# Chạy DevTools
dart devtools

# Flutter DevTools (built-in)
flutter run --observatory-port=8888
# Mở: http://127.0.0.1:8888

# Tính năng DevTools:
# - Memory profiler: phát hiện memory leak
# - CPU profiler: tối ưu hiệu năng
# - Widget Inspector: debug Flutter UI
# - Timeline: phân tích frame rendering
```

### Mẹo thực tế từ dự án Flutter

**1. Cấu trúc thư mục theo tính năng (Feature-first)**

```
lib/
├── core/
│   ├── error/
│   ├── network/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   └── products/
│       └── ...
└── main.dart
```

**2. Clean Architecture layer**

```
Presentation (UI) → Domain (Business Logic) → Data (API/DB)
                         ↑
                    (Repository Interface)
```

**3. Dart 3 features checklist**

```
✅ Records thay vì Map<String, dynamic> cho typed data
✅ Sealed class + exhaustive switch thay vì if-instanceof chain
✅ Pattern matching để destructure object
✅ Class modifiers (final, base, interface, sealed, mixin class)
✅ Named constructor + factory constructor cho tất cả model
✅ Const constructor cho widget không đổi
✅ Extension methods để mở rộng built-in class
```

**4. Dart class modifiers (Dart 3)**

```dart
// base class – chỉ extends được, không implements
base class Vehicle { void move() {} }

// final class – không extends, không implements
final class Singleton { Singleton._(); }

// interface class – chỉ implements được
interface class Printable { void print(); }

// sealed class – exhaustive switch, chỉ extend trong cùng library
sealed class Result<T> {}
class Success<T> extends Result<T> { final T data; Success(this.data); }
class Failure<T> extends Result<T> { final String error; Failure(this.error); }

// mixin class – dùng được cả as mixin lẫn as class
mixin class Loggable {
  void log(String msg) => print(msg);
}
class MyService extends Loggable {} // as class
class OtherService with Loggable {} // as mixin
```

**5. Câu lệnh hay dùng**

```bash
# Tạo project mới
dart create my_project
flutter create my_flutter_app

# Phân tích lỗi
dart analyze
flutter analyze

# Format code
dart format .

# Chạy test
dart test
flutter test

# Code generation
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch  # watch mode

# Upgrade dependencies
dart pub upgrade
flutter pub upgrade

# Kiểm tra outdated packages
dart pub outdated
```

---

> **Tổng kết:** Dart là ngôn ngữ OOP mạnh mẽ và hiện đại. Nắm vững các nguyên tắc từ cơ bản (class, inheritance, polymorphism) đến nâng cao (SOLID, Design Patterns, Null Safety, Records, Pattern Matching) sẽ giúp bạn xây dựng các ứng dụng Flutter chất lượng cao, dễ bảo trì và mở rộng. Luôn ưu tiên **tính rõ ràng (clarity)** hơn **sự ngắn gọn (cleverness)**, và áp dụng nguyên tắc **"đơn giản nhất có thể nhưng không đơn giản hơn nữa"**.