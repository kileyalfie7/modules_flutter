# Dart & OOP – Từ Cơ Bản Đến Nâng Cao (Cập nhật 2026)

## 1. Giới thiệu

### Dart là gì?

**Dart** là ngôn ngữ lập trình hiện đại, mã nguồn mở do Google phát triển từ năm 2011, chính thức ra mắt phiên bản 1.0 vào năm 2013. Dart được thiết kế để xây dựng ứng dụng đa nền tảng với hiệu suất cao và developer experience tuyệt vời.

**Lịch sử ngắn gọn:**
- **2011**: Google công bố Dart
- **2013**: Dart 1.0 ra mắt
- **2018**: Dart 2.0 với type system mới
- **2021**: Dart 2.12 - Sound null safety
- **2023**: Dart 3.0 - Records, patterns, class modifiers
- **2024-2026**: Dart 3.x - Primary constructors, augmentations, Wasm support

**Đặc điểm nổi bật:**
- **Strongly typed** với type inference thông minh
- **Sound null safety** - compiler đảm bảo không có null errors
- **AOT (Ahead-of-Time)** compilation → hiệu suất native cho production
- **JIT (Just-in-Time)** compilation → hot reload siêu nhanh cho development
- **Garbage collection** tự động, tối ưu
- **Async/await** native hỗ trợ lập trình bất đồng bộ
- **Multi-platform**: Mobile, Web, Desktop, Server, Embedded
- **WebAssembly (Wasm)** support từ Dart 3.22+ (2024)

**Ứng dụng hiện nay (2026):**

1. **Flutter** - Framework UI đa nền tảng hàng đầu
   - Mobile: iOS, Android
   - Web: Progressive Web Apps
   - Desktop: Windows, macOS, Linux
   - Embedded: IoT devices, automotive

2. **Server-side Development**
   - **Dart Frog**: Full-stack framework (như Next.js)
   - **Shelf**: HTTP server middleware
   - **Serverpod**: Backend framework với ORM
   - **Conduit**: REST API framework

3. **Web Development**
   - Compile sang JavaScript
   - WebAssembly (Wasm) cho performance tốt hơn
   - Angular Dart (enterprise apps)

4. **CLI Tools & Scripts**
   - Build tools, automation scripts
   - DevOps utilities

5. **Desktop Applications**
   - Native desktop apps qua Flutter
   - Cross-platform tools

### Tại sao Dart là ngôn ngữ OOP mạnh mẽ và hiện đại?

1. **OOP thuần túy**: Mọi thứ đều là object (kể cả numbers, functions, null)
2. **Class-based inheritance** với single inheritance + mixins mạnh mẽ
3. **Interface implicit**: Mọi class đều có thể làm interface
4. **Abstract classes** và **interfaces** rõ ràng
5. **Mixins** cho code reuse không cần kế thừa
6. **Extension methods** mở rộng class mà không sửa source
7. **Generics** với type safety đầy đủ
8. **Class modifiers** (Dart 3+): `sealed`, `final`, `base`, `interface`, `mixin`
9. **Records & Pattern matching** (Dart 3+) cho code ngắn gọn
10. **Null safety** bắt buộc → ít bug runtime
11. **Modern syntax**: Arrow functions, cascade operators, collection if/for
12. **Metaprogramming**: Annotations, code generation

---

## 2. Cơ bản ngôn ngữ Dart (nền tảng cần thiết)

### 2.1. Biến và Kiểu dữ liệu

#### 2.1.1. Khai báo biến

```dart
void main() {
  // var - type inference
  var name = 'An';        // String
  var age = 25;           // int
  var height = 1.75;      // double
  var isActive = true;    // bool
  
  // Explicit type
  String city = 'Hà Nội';
  int year = 2026;
  double pi = 3.14159;
  bool isDone = false;
  
  // final - runtime constant (chỉ gán 1 lần)
  final currentTime = DateTime.now();
  final List<int> numbers = [1, 2, 3];
  // currentTime = DateTime.now(); // ERROR
  
  // const - compile-time constant
  const maxUsers = 100;
  const pi2 = 3.14;
  const list = [1, 2, 3]; // Deep immutable
  
  // dynamic - bất kỳ type nào
  dynamic anything = 'text';
  anything = 42;          // OK
  anything = true;        // OK
  
  // Object - base type của mọi object
  Object obj = 'Hello';
  obj = 123;              // OK
  // print(obj.length);   // ERROR - không biết type cụ thể
}
```

**So sánh var vs final vs const:**

| Đặc điểm | `var` | `final` | `const` |
|----------|-------|---------|---------|
| **Thay đổi giá trị** | Có | Không | Không |
| **Xác định lúc** | Runtime | Runtime | Compile-time |
| **Deep immutable** | Không | Không | Có |
| **Use case** | Biến thay đổi | Giá trị 1 lần | Hằng số |

#### 2.1.2. Kiểu dữ liệu cơ bản

```dart
void main() {
  // Numbers
  int integer = 42;
  double decimal = 3.14;
  num number = 10;        // Có thể là int hoặc double
  number = 3.5;           // OK
  
  // String
  String single = 'Hello';
  String double = "World";
  String multiline = '''
    Dòng 1
    Dòng 2
  ''';
  
  // String interpolation
  var name = 'An';
  var age = 25;
  print('Tên: $name, Tuổi: $age');
  print('Năm sinh: ${2026 - age}');
  
  // Boolean
  bool isTrue = true;
  bool isFalse = false;
  
  // Runes (Unicode characters)
  var heart = '\u2665';   // ♥
  var smile = '😊';
  
  // Symbols
  Symbol sym = #mySymbol;
}
```

#### 2.1.3. Null Safety

```dart
void main() {
  // Non-nullable
  String name = 'An';
  // name = null;         // ERROR
  
  // Nullable
  String? nullableName;
  nullableName = null;    // OK
  nullableName = 'Bình';  // OK
  
  // Late - khởi tạo sau
  late String description;
  description = 'Loaded';
  
  // Late final - chỉ gán 1 lần
  late final String token;
  token = 'abc123';
  // token = 'xyz';       // ERROR
}
```

---

### 2.2. Toán tử (Operators)

#### 2.2.1. Toán tử số học

```dart
void main() {
  var a = 10, b = 3;
  
  print(a + b);   // 13 - Cộng
  print(a - b);   // 7  - Trừ
  print(a * b);   // 30 - Nhân
  print(a / b);   // 3.333... - Chia (double)
  print(a ~/ b);  // 3  - Chia lấy nguyên
  print(a % b);   // 1  - Chia lấy dư
  
  // Increment/Decrement
  var x = 5;
  print(++x);     // 6 - Pre-increment
  print(x++);     // 6 - Post-increment (x = 7 sau đó)
  print(--x);     // 6 - Pre-decrement
}
```

#### 2.2.2. Toán tử so sánh

```dart
void main() {
  var a = 10, b = 20;
  
  print(a == b);  // false - Bằng
  print(a != b);  // true  - Khác
  print(a > b);   // false - Lớn hơn
  print(a < b);   // true  - Nhỏ hơn
  print(a >= b);  // false - Lớn hơn hoặc bằng
  print(a <= b);  // true  - Nhỏ hơn hoặc bằng
}
```

#### 2.2.3. Toán tử logic

```dart
void main() {
  var a = true, b = false;
  
  print(a && b);  // false - AND
  print(a || b);  // true  - OR
  print(!a);      // false - NOT
}
```

#### 2.2.4. Toán tử gán

```dart
void main() {
  var a = 10;
  
  a += 5;   // a = a + 5  → 15
  a -= 3;   // a = a - 3  → 12
  a *= 2;   // a = a * 2  → 24
  a ~/= 4;  // a = a ~/ 4 → 6
  a %= 4;   // a = a % 4  → 2
}
```

#### 2.2.5. Toán tử Null-aware

```dart
void main() {
  String? name;
  
  // ?? - Null coalescing
  String displayName = name ?? 'Guest';
  print(displayName); // Guest
  
  // ??= - Null-aware assignment
  name ??= 'Default';
  print(name);        // Default
  name ??= 'Another';
  print(name);        // Default (không đổi)
  
  // ?. - Null-aware access
  String? text;
  print(text?.length);      // null (không crash)
  
  text = 'Hello';
  print(text?.length);      // 5
  
  // ! - Null assertion
  String? value = 'Test';
  print(value!.length);     // 5
  // String? nullValue = null;
  // print(nullValue!.length); // CRASH!
}
```

#### 2.2.6. Cascade Operator (..)

```dart
class Person {
  String? name;
  int? age;
  
  void introduce() {
    print('$name, $age tuổi');
  }
}

void main() {
  // Không dùng cascade
  var person1 = Person();
  person1.name = 'An';
  person1.age = 25;
  person1.introduce();
  
  // Dùng cascade
  var person2 = Person()
    ..name = 'Bình'
    ..age = 30
    ..introduce();
  
  // Null-aware cascade
  Person? nullPerson;
  nullPerson?..name = 'Test'..age = 20; // Không làm gì nếu null
}
```

**So sánh Null-aware Operators:**

| Operator | Ý nghĩa | Khi nào dùng |
|----------|---------|--------------|
| `??` | Giá trị mặc định nếu null | Fallback value |
| `??=` | Gán nếu null | Lazy initialization |
| `?.` | Truy cập an toàn | Tránh null crash |
| `!` | Assert không null | Chắc chắn 100% |
| `?..` | Cascade an toàn | Chain calls |

---

### 2.3. Control Flow

#### 2.3.1. If-Else

```dart
void main() {
  var age = 18;
  
  if (age >= 18) {
    print('Người lớn');
  } else if (age >= 13) {
    print('Thiếu niên');
  } else {
    print('Trẻ em');
  }
  
  // Ternary operator
  var status = age >= 18 ? 'Adult' : 'Minor';
  print(status);
}
```

#### 2.3.2. Switch

```dart
void main() {
  var grade = 'A';
  
  // Traditional switch
  switch (grade) {
    case 'A':
      print('Xuất sắc');
      break;
    case 'B':
      print('Giỏi');
      break;
    case 'C':
      print('Khá');
      break;
    default:
      print('Trung bình');
  }
  
  // Switch expression (Dart 3+)
  var message = switch (grade) {
    'A' => 'Xuất sắc',
    'B' => 'Giỏi',
    'C' => 'Khá',
    _ => 'Trung bình',
  };
  print(message);
}
```

#### 2.3.3. For Loop

```dart
void main() {
  // Traditional for
  for (var i = 0; i < 5; i++) {
    print('Count: $i');
  }
  
  // For-in
  var fruits = ['Apple', 'Banana', 'Orange'];
  for (var fruit in fruits) {
    print(fruit);
  }
  
  // forEach
  fruits.forEach((fruit) => print(fruit));
  
  // For with index
  for (var i = 0; i < fruits.length; i++) {
    print('$i: ${fruits[i]}');
  }
}
```

#### 2.3.4. While & Do-While

```dart
void main() {
  // While
  var count = 0;
  while (count < 5) {
    print('Count: $count');
    count++;
  }
  
  // Do-While
  var num = 0;
  do {
    print('Number: $num');
    num++;
  } while (num < 3);
}
```

#### 2.3.5. Break & Continue

```dart
void main() {
  // Break
  for (var i = 0; i < 10; i++) {
    if (i == 5) break;
    print(i);
  }
  
  // Continue
  for (var i = 0; i < 5; i++) {
    if (i == 2) continue;
    print(i); // Skip 2
  }
}
```

---

### 2.4. Functions

#### 2.4.1. Function cơ bản

```dart
// Function với return type
int add(int a, int b) {
  return a + b;
}

// Arrow function (expression body)
int multiply(int a, int b) => a * b;

// Void function
void greet(String name) {
  print('Hello, $name!');
}

void main() {
  print(add(5, 3));        // 8
  print(multiply(4, 2));   // 8
  greet('An');             // Hello, An!
}
```

#### 2.4.2. Optional Parameters

```dart
// Optional positional parameters
String formatName(String first, [String? middle, String? last]) {
  var name = first;
  if (middle != null) name += ' $middle';
  if (last != null) name += ' $last';
  return name;
}

// Named parameters
void createUser({
  required String name,
  required int age,
  String? email,
  bool isActive = true,
}) {
  print('Name: $name, Age: $age, Active: $isActive');
}

void main() {
  print(formatName('Nguyễn'));              // Nguyễn
  print(formatName('Nguyễn', 'Văn', 'An')); // Nguyễn Văn An
  
  createUser(name: 'An', age: 25);
  createUser(name: 'Bình', age: 30, email: 'binh@example.com');
}
```

#### 2.4.3. Default Values

```dart
void printInfo({
  String name = 'Guest',
  int age = 0,
  String country = 'Vietnam',
}) {
  print('$name, $age, $country');
}

void main() {
  printInfo();                              // Guest, 0, Vietnam
  printInfo(name: 'An', age: 25);          // An, 25, Vietnam
}
```

#### 2.4.4. Anonymous Functions & Closures

```dart
void main() {
  // Anonymous function
  var list = [1, 2, 3, 4, 5];
  
  list.forEach((item) {
    print(item * 2);
  });
  
  // Arrow anonymous function
  var doubled = list.map((x) => x * 2).toList();
  print(doubled); // [2, 4, 6, 8, 10]
  
  // Closure - function có thể truy cập biến bên ngoài
  var multiplier = 3;
  var triple = (int x) => x * multiplier;
  print(triple(5)); // 15
}
```

#### 2.4.5. Higher-Order Functions

```dart
// Function nhận function làm parameter
void executeOperation(int a, int b, int Function(int, int) operation) {
  var result = operation(a, b);
  print('Result: $result');
}

// Function trả về function
Function makeMultiplier(int factor) {
  return (int x) => x * factor;
}

void main() {
  // Truyền function
  executeOperation(10, 5, (a, b) => a + b);  // Result: 15
  executeOperation(10, 5, (a, b) => a * b);  // Result: 50
  
  // Function trả về function
  var triple = makeMultiplier(3);
  print(triple(5));  // 15
  
  var double = makeMultiplier(2);
  print(double(5));  // 10
}
```

---

### 2.5. Collections

#### 2.5.1. List

```dart
void main() {
  // Tạo list
  var numbers = [1, 2, 3, 4, 5];
  List<String> fruits = ['Apple', 'Banana', 'Orange'];
  
  // Truy cập
  print(numbers[0]);        // 1
  print(fruits.first);      // Apple
  print(fruits.last);       // Orange
  print(fruits.length);     // 3
  
  // Thêm/xóa
  fruits.add('Mango');
  fruits.addAll(['Grape', 'Kiwi']);
  fruits.remove('Banana');
  fruits.removeAt(0);
  
  // Kiểm tra
  print(fruits.contains('Apple'));  // false
  print(fruits.isEmpty);            // false
  print(fruits.isNotEmpty);         // true
  
  // Spread operator
  var moreFruits = ['Pear', ...fruits, 'Cherry'];
  print(moreFruits);
  
  // Collection if
  var includeZero = true;
  var nums = [
    if (includeZero) 0,
    1, 2, 3,
  ];
  
  // Collection for
  var listOfInts = [1, 2, 3];
  var listOfStrings = [
    '#0',
    for (var i in listOfInts) '#$i',
  ];
  print(listOfStrings); // [#0, #1, #2, #3]
}
```

#### 2.5.2. Set

```dart
void main() {
  // Tạo set (không trùng lặp)
  var numbers = {1, 2, 3, 4, 5};
  Set<String> fruits = {'Apple', 'Banana', 'Orange'};
  
  // Thêm
  fruits.add('Mango');
  fruits.add('Apple');  // Không thêm (đã có)
  print(fruits);        // {Apple, Banana, Orange, Mango}
  
  // Set operations
  var set1 = {1, 2, 3};
  var set2 = {3, 4, 5};
  
  print(set1.union(set2));        // {1, 2, 3, 4, 5}
  print(set1.intersection(set2)); // {3}
  print(set1.difference(set2));   // {1, 2}
}
```

#### 2.5.3. Map

```dart
void main() {
  // Tạo map
  var person = {
    'name': 'An',
    'age': 25,
    'city': 'Hà Nội',
  };
  
  Map<String, dynamic> user = {
    'id': 1,
    'username': 'an123',
    'isActive': true,
  };
  
  // Truy cập
  print(person['name']);     // An
  print(user['age'] ?? 0);   // 0 (không tồn tại)
  
  // Thêm/sửa
  person['email'] = 'an@example.com';
  person['age'] = 26;
  
  // Xóa
  person.remove('city');
  
  // Kiểm tra
  print(person.containsKey('name'));    // true
  print(person.containsValue('An'));    // true
  
  // Duyệt
  person.forEach((key, value) {
    print('$key: $value');
  });
  
  // Keys & Values
  print(person.keys);    // (name, age, email)
  print(person.values);  // (An, 26, an@example.com)
}
```

**So sánh List vs Set vs Map:**

| Đặc điểm | List | Set | Map |
|----------|------|-----|-----|
| **Thứ tự** | Có | Không đảm bảo | Không đảm bảo |
| **Trùng lặp** | Cho phép | Không | Key không trùng |
| **Truy cập** | Index | Iteration | Key |
| **Use case** | Danh sách có thứ tự | Tập hợp unique | Key-value pairs |

#### 2.5.4. Collection Methods

```dart
void main() {
  var numbers = [1, 2, 3, 4, 5];
  
  // map - transform
  var doubled = numbers.map((x) => x * 2).toList();
  print(doubled); // [2, 4, 6, 8, 10]
  
  // where - filter
  var evens = numbers.where((x) => x % 2 == 0).toList();
  print(evens); // [2, 4]
  
  // forEach - iterate
  numbers.forEach((x) => print(x));
  
  // fold - reduce
  var sum = numbers.fold(0, (prev, curr) => prev + curr);
  print(sum); // 15
  
  // reduce
  var product = numbers.reduce((a, b) => a * b);
  print(product); // 120
  
  // any - kiểm tra có phần tử thỏa điều kiện
  print(numbers.any((x) => x > 3)); // true
  
  // every - kiểm tra tất cả thỏa điều kiện
  print(numbers.every((x) => x > 0)); // true
  
  // firstWhere
  var firstEven = numbers.firstWhere((x) => x % 2 == 0);
  print(firstEven); // 2
  
  // take, skip
  print(numbers.take(3).toList());  // [1, 2, 3]
  print(numbers.skip(2).toList());  // [3, 4, 5]
}
```

---

### 2.6. Import, Library, Part

#### 2.6.1. Import

```dart
// Import core library
import 'dart:math';
import 'dart:async';
import 'dart:convert';

// Import package
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Import file
import 'utils/helpers.dart';
import '../models/user.dart';

// Import với prefix
import 'package:lib1/lib1.dart';
import 'package:lib2/lib2.dart' as lib2;

// Import chỉ một số thành phần
import 'package:flutter/material.dart' show Widget, State;

// Import trừ một số thành phần
import 'package:flutter/material.dart' hide Colors;

void main() {
  // Dùng với prefix
  var element = lib2.Element();
  
  // Dùng http với alias
  http.get(Uri.parse('https://example.com'));
}
```

#### 2.6.2. Library

```dart
// file: my_library.dart
library my_library;

// Export các file khác
export 'src/user.dart';
export 'src/product.dart';

// Private members (bắt đầu với _)
class _InternalHelper {
  void doSomething() {}
}

// Public class
class PublicAPI {
  void publicMethod() {}
}
```

#### 2.6.3. Part & Part Of

```dart
// file: user.dart
library user;

part 'user_model.dart';
part 'user_repository.dart';

class UserService {
  // Implementation
}

// file: user_model.dart
part of user;

class User {
  String name;
  int age;
  User(this.name, this.age);
}

// file: user_repository.dart
part of user;

class UserRepository {
  Future<User> getUser(String id) async {
    // Implementation
    return User('An', 25);
  }
}
```

---

## Tổng kết Phần 2

Phần 2 đã cover nền tảng Dart:
- ✅ Biến và kiểu dữ liệu (var, final, const, int, double, String, bool, dynamic, Object)
- ✅ Toán tử (arithmetic, comparison, logical, null-aware, cascade)
- ✅ Control flow (if-else, switch, for, while, break, continue)
- ✅ Functions (arrow, optional, named, default, anonymous, higher-order)
- ✅ Collections (List, Set, Map) và methods (map, where, fold, reduce...)
- ✅ Null safety cơ bản
- ✅ Import, library, part

**Các bảng so sánh:**
- var vs final vs const
- Null-aware operators
- List vs Set vs Map

---

## 3. Cơ bản OOP trong Dart

### 3.1. Class và Object

**Class** là bản thiết kế (blueprint) để tạo ra các object. **Object** là instance cụ thể của class.

```dart
// Định nghĩa class
class Person {
  // Properties
  String name;
  int age;
  
  // Constructor
  Person(this.name, this.age);
  
  // Method
  void introduce() {
    print('Xin chào, tôi là $name, $age tuổi');
  }
  
  // Method với return
  int getBirthYear() {
    return 2026 - age;
  }
}

void main() {
  // Tạo object
  var person1 = Person('An', 25);
  var person2 = Person('Bình', 30);
  
  // Truy cập properties
  print(person1.name);  // An
  print(person2.age);   // 30
  
  // Gọi methods
  person1.introduce();  // Xin chào, tôi là An, 25 tuổi
  print('Năm sinh: ${person1.getBirthYear()}'); // 2001
}
```

**Best practices:**
- Class name: **PascalCase** (`UserProfile`, `ApiService`)
- Properties/methods: **camelCase** (`userName`, `fetchData()`)
- Private members: prefix `_` (`_privateMethod`)

---

### 3.2. Constructor

Constructor là phương thức đặc biệt để khởi tạo object.

#### 3.2.1. Default Constructor

```dart
class User {
  String name;
  int age;
  String email;
  
  // Default constructor
  User(this.name, this.age, this.email);
  
  // Constructor với body
  User.withValidation(this.name, this.age, this.email) {
    if (age < 0) throw Exception('Age must be positive');
    if (!email.contains('@')) throw Exception('Invalid email');
  }
}

void main() {
  var user1 = User('An', 25, 'an@example.com');
  var user2 = User.withValidation('Bình', 30, 'binh@example.com');
}
```

#### 3.2.2. Named Constructor

Constructor có tên, cho phép nhiều cách khởi tạo khác nhau.

```dart
class Point {
  double x, y;
  
  Point(this.x, this.y);
  
  // Named constructor - origin
  Point.origin()
      : x = 0,
        y = 0;
  
  // Named constructor - from JSON
  Point.fromJson(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'];
  
  // Named constructor - polar coordinates
  Point.polar(double radius, double angle)
      : x = radius * cos(angle),
        y = radius * sin(angle);
}

void main() {
  var p1 = Point(10, 20);
  var p2 = Point.origin();
  var p3 = Point.fromJson({'x': 5.0, 'y': 15.0});
  var p4 = Point.polar(10, pi / 4);
}
```

#### 3.2.3. Factory Constructor

Không nhất thiết tạo object mới, có thể return cached instance hoặc subtype.

```dart
class Logger {
  final String name;
  static final Map<String, Logger> _cache = {};
  
  // Private constructor
  Logger._internal(this.name);
  
  // Factory constructor - singleton pattern
  factory Logger(String name) {
    return _cache.putIfAbsent(name, () => Logger._internal(name));
  }
  
  void log(String message) {
    print('[$name] $message');
  }
}

// Factory với subtype
abstract class Shape {
  factory Shape(String type) {
    switch (type) {
      case 'circle':
        return Circle(5);
      case 'square':
        return Square(4);
      default:
        throw Exception('Unknown shape');
    }
  }
  
  double area();
}

class Circle implements Shape {
  final double radius;
  Circle(this.radius);
  
  @override
  double area() => pi * radius * radius;
}

class Square implements Shape {
  final double side;
  Square(this.side);
  
  @override
  double area() => side * side;
}

void main() {
  var logger1 = Logger('App');
  var logger2 = Logger('App');
  print(identical(logger1, logger2)); // true
  
  Shape shape = Shape('circle');
  print(shape.area());
}
```

#### 3.2.4. Const Constructor

Tạo compile-time constant, tối ưu memory và performance.

```dart
class ImmutablePoint {
  final double x, y;
  
  // Const constructor - tất cả fields phải final
  const ImmutablePoint(this.x, this.y);
}

void main() {
  // Compile-time constants
  const p1 = ImmutablePoint(0, 0);
  const p2 = ImmutablePoint(0, 0);
  
  print(identical(p1, p2)); // true - cùng instance
  
  // Runtime
  var p3 = ImmutablePoint(1, 1);
  var p4 = ImmutablePoint(1, 1);
  print(identical(p3, p4)); // false - khác instance
}
```

#### 3.2.5. Primary Constructor (Dart 3.x+)

Cú pháp ngắn gọn hơn (tính năng đang phát triển, có thể thay đổi).

```dart
// Traditional
class UserOld {
  final String name;
  final int age;
  
  UserOld(this.name, this.age);
}

// Primary constructor (nếu được hỗ trợ đầy đủ trong tương lai)
// Syntax có thể như sau:
class User(String name, int age);

// Hoặc với body:
class User(String name, int age) {
  void greet() => print('Hello, $name');
}
```

**So sánh các loại Constructor:**

| Loại | Tạo object mới? | Use case | Ví dụ |
|------|-----------------|----------|-------|
| **Default** | Luôn luôn | Khởi tạo thông thường | `User('An', 25)` |
| **Named** | Luôn luôn | Nhiều cách khởi tạo | `Point.origin()`, `User.fromJson()` |
| **Factory** | Không nhất thiết | Singleton, cache, subtype | `Logger('app')` |
| **Const** | Không (nếu giống nhau) | Immutable, performance | `const Point(0, 0)` |

---

### 3.3. Properties

#### 3.3.1. Instance Properties

```dart
class Product {
  // Mutable
  String name;
  double price;
  
  // Immutable (final)
  final String id;
  
  // Late initialization
  late String description;
  
  // Private
  String _category;
  
  Product(this.id, this.name, this.price, this._category);
}

void main() {
  var product = Product('P001', 'Laptop', 1000, 'Electronics');
  
  product.name = 'Gaming Laptop'; // OK - mutable
  // product.id = 'P002';         // ERROR - final
  
  product.description = 'High-end laptop'; // OK - late
}
```

#### 3.3.2. Static Properties

Thuộc về class, không phải instance.

```dart
class AppConfig {
  static const String appName = 'MyApp';
  static const String version = '1.0.0';
  static int userCount = 0;
  
  static void incrementUsers() {
    userCount++;
  }
}

void main() {
  print(AppConfig.appName);    // MyApp
  print(AppConfig.userCount);  // 0
  
  AppConfig.incrementUsers();
  print(AppConfig.userCount);  // 1
  
  // Không thể truy cập qua instance
  // var config = AppConfig();
  // print(config.appName); // ERROR
}
```

#### 3.3.3. Getters và Setters

```dart
class Rectangle {
  double width, height;
  
  Rectangle(this.width, this.height);
  
  // Getter - computed property
  double get area => width * height;
  
  double get perimeter => 2 * (width + height);
  
  // Getter với logic
  String get shape {
    if (width == height) return 'Square';
    return 'Rectangle';
  }
  
  // Setter
  set dimensions(List<double> values) {
    if (values.length != 2) {
      throw Exception('Need exactly 2 values');
    }
    width = values[0];
    height = values[1];
  }
  
  // Setter với validation
  set area(double value) {
    // Giữ nguyên tỷ lệ, thay đổi kích thước
    var ratio = width / height;
    height = sqrt(value / ratio);
    width = height * ratio;
  }
}

void main() {
  var rect = Rectangle(10, 20);
  
  print(rect.area);      // 200.0
  print(rect.perimeter); // 60.0
  print(rect.shape);     // Rectangle
  
  rect.dimensions = [15, 15];
  print(rect.shape);     // Square
  
  rect.area = 100;
  print('${rect.width} x ${rect.height}'); // ~10 x 10
}
```

**So sánh final vs const vs late:**

| Đặc điểm | `final` | `const` | `late` | `late final` |
|----------|---------|---------|--------|--------------|
| **Gán lại** | Không | Không | Có | Không |
| **Thời điểm** | Runtime | Compile-time | Runtime (sau) | Runtime (sau) |
| **Deep immutable** | Không | Có | Không | Không |
| **Lazy init** | Không | Không | Có | Có |
| **Use case** | Immutable data | Constants | DI, async | Async immutable |

---

### 3.4. Methods

#### 3.4.1. Instance Methods

```dart
class BankAccount {
  String accountNumber;
  double _balance;
  
  BankAccount(this.accountNumber, this._balance);
  
  // Getter
  double get balance => _balance;
  
  // Instance method
  void deposit(double amount) {
    if (amount > 0) {
      _balance += amount;
      _logTransaction('Deposit', amount);
    }
  }
  
  bool withdraw(double amount) {
    if (amount > 0 && _balance >= amount) {
      _balance -= amount;
      _logTransaction('Withdraw', amount);
      return true;
    }
    return false;
  }
  
  // Private method
  void _logTransaction(String type, double amount) {
    print('[$type] $amount - Balance: $_balance');
  }
  
  // Method với named parameters
  void transfer({
    required BankAccount to,
    required double amount,
    String? note,
  }) {
    if (withdraw(amount)) {
      to.deposit(amount);
      if (note != null) print('Note: $note');
    }
  }
}

void main() {
  var account1 = BankAccount('ACC001', 1000);
  var account2 = BankAccount('ACC002', 500);
  
  account1.deposit(500);
  account1.withdraw(200);
  
  account1.transfer(
    to: account2,
    amount: 300,
    note: 'Payment',
  );
}
```

#### 3.4.2. Static Methods

```dart
class MathUtils {
  // Static method
  static double calculateCircleArea(double radius) {
    return pi * radius * radius;
  }
  
  static int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
  }
  
  static bool isPrime(int n) {
    if (n < 2) return false;
    for (var i = 2; i <= sqrt(n); i++) {
      if (n % i == 0) return false;
    }
    return true;
  }
}

class StringHelper {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  static String reverse(String text) {
    return text.split('').reversed.join();
  }
}

void main() {
  print(MathUtils.calculateCircleArea(5));  // 78.53...
  print(MathUtils.factorial(5));            // 120
  print(MathUtils.isPrime(17));             // true
  
  print(StringHelper.capitalize('hello'));  // Hello
  print(StringHelper.reverse('dart'));      // trad
}
```

**So sánh Static vs Instance:**

| Đặc điểm | Static | Instance |
|----------|--------|----------|
| **Gọi qua** | Class name | Object |
| **Truy cập instance members** | Không | Có |
| **Truy cập static members** | Có | Có |
| **Memory** | 1 bản duy nhất | Mỗi object 1 bản |
| **Use case** | Utility, factory | Business logic, state |

---

### 3.5. Inheritance (Kế thừa)

Class con kế thừa properties và methods từ class cha.

```dart
// Class cha (superclass/parent class)
class Animal {
  String name;
  int age;
  
  Animal(this.name, this.age);
  
  void eat() {
    print('$name đang ăn');
  }
  
  void sleep() {
    print('$name đang ngủ');
  }
  
  void makeSound() {
    print('$name phát ra âm thanh');
  }
}

// Class con (subclass/child class)
class Dog extends Animal {
  String breed;
  
  // Constructor gọi super
  Dog(String name, int age, this.breed) : super(name, age);
  
  // Override method
  @override
  void makeSound() {
    print('$name sủa: Gâu gâu!');
  }
  
  // Method riêng
  void fetch() {
    print('$name đang đuổi bắt bóng');
  }
  
  // Method gọi super
  void rest() {
    super.sleep(); // Gọi method của class cha
    print('$name nghỉ ngơi sau khi chơi');
  }
}

class Cat extends Animal {
  bool isIndoor;
  
  Cat(String name, int age, this.isIndoor) : super(name, age);
  
  @override
  void makeSound() {
    print('$name kêu: Meo meo!');
  }
  
  void climb() {
    print('$name đang leo cây');
  }
}

void main() {
  var dog = Dog('Buddy', 3, 'Golden Retriever');
  dog.eat();       // Buddy đang ăn (từ Animal)
  dog.makeSound(); // Buddy sủa: Gâu gâu! (override)
  dog.fetch();     // Buddy đang đuổi bắt bóng (riêng Dog)
  dog.rest();      // Gọi super.sleep()
  
  var cat = Cat('Kitty', 2, true);
  cat.makeSound(); // Kitty kêu: Meo meo!
  cat.climb();     // Kitty đang leo cây
}
```

**Sử dụng super:**

```dart
class Vehicle {
  String brand;
  int year;
  
  Vehicle(this.brand, this.year);
  
  void start() {
    print('$brand đang khởi động');
  }
  
  void displayInfo() {
    print('Brand: $brand, Year: $year');
  }
}

class Car extends Vehicle {
  int seats;
  String fuelType;
  
  Car(String brand, int year, this.seats, this.fuelType)
      : super(brand, year);
  
  @override
  void start() {
    super.start(); // Gọi method cha
    print('Xe $seats chỗ, nhiên liệu $fuelType');
  }
  
  @override
  void displayInfo() {
    super.displayInfo(); // Gọi method cha
    print('Seats: $seats, Fuel: $fuelType');
  }
}

void main() {
  var car = Car('Toyota', 2026, 5, 'Hybrid');
  car.start();
  car.displayInfo();
}
```

**Lưu ý quan trọng:**
- Dart chỉ hỗ trợ **single inheritance** (1 class chỉ extends 1 class)
- Dùng **mixins** để tái sử dụng code từ nhiều nguồn
- Constructor không được kế thừa
- Private members (`_`) không truy cập được từ subclass (nếu khác file)

---

### 3.6. Polymorphism (Đa hình)

Khả năng object có nhiều hình thái, cùng interface nhưng hành vi khác nhau.

```dart
class Shape {
  String name;
  
  Shape(this.name);
  
  void draw() {
    print('Vẽ hình $name');
  }
  
  double area() => 0;
  
  double perimeter() => 0;
}

class Circle extends Shape {
  double radius;
  
  Circle(this.radius) : super('Circle');
  
  @override
  void draw() {
    print('Vẽ hình tròn bán kính $radius');
  }
  
  @override
  double area() => pi * radius * radius;
  
  @override
  double perimeter() => 2 * pi * radius;
}

class Rectangle extends Shape {
  double width, height;
  
  Rectangle(this.width, this.height) : super('Rectangle');
  
  @override
  void draw() {
    print('Vẽ hình chữ nhật ${width}x$height');
  }
  
  @override
  double area() => width * height;
  
  @override
  double perimeter() => 2 * (width + height);
}

class Triangle extends Shape {
  double a, b, c;
  
  Triangle(this.a, this.b, this.c) : super('Triangle');
  
  @override
  void draw() {
    print('Vẽ tam giác cạnh $a, $b, $c');
  }
  
  @override
  double area() {
    var s = (a + b + c) / 2;
    return sqrt(s * (s - a) * (s - b) * (s - c));
  }
  
  @override
  double perimeter() => a + b + c;
}

// Function nhận Shape nhưng xử lý được tất cả subclasses
void printShapeInfo(Shape shape) {
  shape.draw();
  print('Diện tích: ${shape.area().toStringAsFixed(2)}');
  print('Chu vi: ${shape.perimeter().toStringAsFixed(2)}');
  print('---');
}

void main() {
  // Polymorphism - cùng type Shape nhưng hành vi khác nhau
  List<Shape> shapes = [
    Circle(5),
    Rectangle(4, 6),
    Triangle(3, 4, 5),
    Circle(3),
  ];
  
  // Xử lý đồng nhất
  for (var shape in shapes) {
    printShapeInfo(shape);
  }
  
  // Type checking
  for (var shape in shapes) {
    if (shape is Circle) {
      print('Đây là hình tròn bán kính ${shape.radius}');
    } else if (shape is Rectangle) {
      print('Đây là hình chữ nhật ${shape.width}x${shape.height}');
    }
  }
}
```

**Annotation @override:**
- Không bắt buộc nhưng **nên dùng**
- Compiler kiểm tra xem có đang override đúng method không
- Tăng tính rõ ràng và maintainability
- IDE hỗ trợ tốt hơn

---

### 3.7. Encapsulation (Đóng gói)

Ẩn giấu implementation details, chỉ expose interface cần thiết.

```dart
class BankAccount {
  // Private properties
  String _accountNumber;
  double _balance;
  List<String> _transactionHistory = [];
  
  // Public constructor
  BankAccount(this._accountNumber, this._balance);
  
  // Public getters
  String get accountNumber => _accountNumber;
  double get balance => _balance;
  List<String> get transactionHistory => List.unmodifiable(_transactionHistory);
  
  // Public methods với validation
  bool deposit(double amount) {
    if (_isValidAmount(amount)) {
      _balance += amount;
      _logTransaction('Deposit: +$amount');
      return true;
    }
    return false;
  }
  
  bool withdraw(double amount) {
    if (_isValidAmount(amount) && _hasSufficientBalance(amount)) {
      _balance -= amount;
      _logTransaction('Withdraw: -$amount');
      return true;
    }
    return false;
  }
  
  bool transfer(BankAccount toAccount, double amount) {
    if (withdraw(amount)) {
      toAccount.deposit(amount);
      _logTransaction('Transfer to ${toAccount.accountNumber}: -$amount');
      return true;
    }
    return false;
  }
  
  // Private helper methods
  bool _isValidAmount(double amount) {
    return amount > 0;
  }
  
  bool _hasSufficientBalance(double amount) {
    return _balance >= amount;
  }
  
  void _logTransaction(String transaction) {
    var timestamp = DateTime.now().toIso8601String();
    _transactionHistory.add('[$timestamp] $transaction');
  }
  
  // Private method không expose
  void _calculateInterest() {
    // Internal calculation
  }
}

void main() {
  var account = BankAccount('ACC001', 1000);
  
  // Có thể truy cập public members
  print(account.balance);        // 1000.0
  print(account.accountNumber);  // ACC001
  
  account.deposit(500);
  account.withdraw(200);
  
  // Không thể truy cập private members
  // print(account._balance);           // ERROR
  // account._logTransaction('Test');   // ERROR
  // account._calculateInterest();      // ERROR
  
  // Không thể modify history trực tiếp
  var history = account.transactionHistory;
  // history.add('Fake');  // ERROR - unmodifiable
  
  print(account.transactionHistory);
}
```

**Quy tắc Private trong Dart:**
- Prefix `_` → private trong **library** (file), không phải class
- Không có `protected` keyword như Java/C++
- Private members chỉ truy cập được trong cùng file
- Nếu muốn share giữa nhiều classes, đặt trong cùng file

**Best practices:**
- Mặc định làm private, chỉ public khi cần
- Dùng getters thay vì expose fields trực tiếp
- Return unmodifiable collections nếu không muốn modify
- Validate trong setters/methods
- Tách logic phức tạp thành private methods

---

### 3.8. Abstraction (Trừu tượng)

Định nghĩa interface/contract mà không cần implementation chi tiết.

#### 3.8.1. Abstract Class

```dart
// Abstract class - không thể tạo instance trực tiếp
abstract class Database {
  // Abstract methods - không có body
  Future<void> connect();
  Future<void> disconnect();
  Future<List<Map<String, dynamic>>> query(String sql);
  Future<int> execute(String sql);
  
  // Concrete method - có implementation
  void log(String message) {
    print('[DB] $message');
  }
  
  // Abstract getter
  String get databaseType;
  
  // Concrete method sử dụng abstract members
  Future<void> initialize() async {
    log('Initializing $databaseType database...');
    await connect();
    log('Database ready');
  }
}

// Implementation cụ thể
class MySQLDatabase extends Database {
  final String host;
  final int port;
  
  MySQLDatabase(this.host, this.port);
  
  @override
  String get databaseType => 'MySQL';
  
  @override
  Future<void> connect() async {
    log('Connecting to MySQL at $host:$port...');
    await Future.delayed(Duration(seconds: 1));
    log('Connected to MySQL');
  }
  
  @override
  Future<void> disconnect() async {
    log('Disconnecting from MySQL...');
  }
  
  @override
  Future<List<Map<String, dynamic>>> query(String sql) async {
    log('Executing query: $sql');
    return [{'id': 1, 'name': 'Test'}];
  }
  
  @override
  Future<int> execute(String sql) async {
    log('Executing: $sql');
    return 1; // Affected rows
  }
}

class PostgreSQLDatabase extends Database {
  final String connectionString;
  
  PostgreSQLDatabase(this.connectionString);
  
  @override
  String get databaseType => 'PostgreSQL';
  
  @override
  Future<void> connect() async {
    log('Connecting to PostgreSQL...');
  }
  
  @override
  Future<void> disconnect() async {
    log('Disconnecting from PostgreSQL...');
  }
  
  @override
  Future<List<Map<String, dynamic>>> query(String sql) async {
    log('PostgreSQL query: $sql');
    return [];
  }
  
  @override
  Future<int> execute(String sql) async {
    log('PostgreSQL execute: $sql');
    return 0;
  }
}

void main() async {
  // var db = Database(); // ERROR - không thể tạo instance
  
  Database db = MySQLDatabase('localhost', 3306);
  await db.initialize();
  var results = await db.query('SELECT * FROM users');
  await db.disconnect();
  
  print('---');
  
  Database db2 = PostgreSQLDatabase('postgresql://localhost');
  await db2.initialize();
}
```

#### 3.8.2. Abstract Class trong Flutter

```dart
// Base widget abstract class
abstract class BaseWidget extends StatelessWidget {
  const BaseWidget({Key? key}) : super(key: key);
  
  // Abstract method - subclass phải implement
  Widget buildContent(BuildContext context);
  
  // Concrete method - có implementation mặc định
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildContent(context),
    );
  }
  
  // Có thể override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(title: Text(getTitle()));
  }
  
  // Abstract getter
  String getTitle();
}

// Concrete implementation
class HomeScreen extends BaseWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  String getTitle() => 'Home';
  
  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: Text('Home Screen Content'),
    );
  }
}

class ProfileScreen extends BaseWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  
  @override
  String getTitle() => 'Profile';
  
  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: Text('Profile Screen Content'),
    );
  }
  
  // Override để customize
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(getTitle()),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {},
        ),
      ],
    );
  }
}
```

**Khi nào dùng Abstract Class:**
- Muốn định nghĩa contract cho subclasses
- Có một số implementation chung (concrete methods)
- Cần kế thừa state (fields)
- Muốn force subclasses implement một số methods

**Lưu ý:**
- Abstract class có thể có constructor
- Có thể mix abstract và concrete methods
- Subclass phải implement tất cả abstract members
- Có thể có fields (properties)

---

## Tổng kết Phần 3

Phần 3 đã cover cơ bản OOP:
- ✅ Class và Object
- ✅ Constructor (default, named, factory, const, primary)
- ✅ Properties (instance, static, final, late, getters/setters)
- ✅ Methods (instance, static, private)
- ✅ Inheritance (extends, super)
- ✅ Polymorphism (@override, type checking)
- ✅ Encapsulation (private với _)
- ✅ Abstraction (abstract class)

**Các bảng so sánh:**
- Constructor types
- final vs const vs late
- Static vs Instance
- Public vs Private

---
## 4. Trung cấp OOP trong Dart

### 4.1. Mixins

**Mixin** là cách để tái sử dụng code của một class trong nhiều class hierarchies khác nhau mà không cần kế thừa.

#### 4.1.1. Cơ bản về Mixins

\`\`\`dart
// Định nghĩa mixin
mixin Flyable {
  void fly() {
    print('Đang bay');
  }
  
  double get altitude => 1000.0;
  
  void land() {
    print('Đang hạ cánh');
  }
}

mixin Swimmable {
  void swim() {
    print('Đang bơi');
  }
  
  double get swimSpeed => 5.0;
}

class Animal {
  String name;
  int age;
  
  Animal(this.name, this.age);
  
  void eat() => print('$name đang ăn');
}

// Sử dụng mixins với 'with'
class Duck extends Animal with Flyable, Swimmable {
  Duck(String name, int age) : super(name, age);
  
  void quack() => print('$name kêu: Quạc quạc!');
}

class Fish extends Animal with Swimmable {
  Fish(String name, int age) : super(name, age);
}

class Bird extends Animal with Flyable {
  Bird(String name, int age) : super(name, age);
}

void main() {
  var duck = Duck('Donald', 2);
  duck.eat();   // Donald đang ăn (từ Animal)
  duck.fly();   // Đang bay (từ Flyable)
  duck.swim();  // Đang bơi (từ Swimmable)
  duck.quack(); // Donald kêu: Quạc quạc!
  
  var fish = Fish('Nemo', 1);
  fish.swim();  // Đang bơi
  // fish.fly(); // ERROR - Fish không có Flyable
}
\`\`\`

#### 4.1.2. Mixin với 'on' - Ràng buộc kiểu

\`\`\`dart
class Performer {
  String name;
  Performer(this.name);
  
  void perform() => print('$name đang biểu diễn');
}

// Mixin chỉ áp dụng cho subclass của Performer
mixin Musical on Performer {
  void playInstrument(String instrument) {
    print('$name đang chơi $instrument');
  }
  
  void sing(String song) {
    print('$name đang hát $song');
  }
}

mixin Dancer on Performer {
  void dance(String style) {
    print('$name đang nhảy $style');
  }
}

class Artist extends Performer with Musical, Dancer {
  Artist(String name) : super(name);
}

// class Robot with Musical {} // ERROR - Robot không extends Performer

void main() {
  var artist = Artist('Taylor');
  artist.perform();                    // Taylor đang biểu diễn
  artist.playInstrument('guitar');     // Taylor đang chơi guitar
  artist.sing('Love Story');           // Taylor đang hát Love Story
  artist.dance('ballet');              // Taylor đang nhảy ballet
}
\`\`\`

#### 4.1.3. Mixin với State

\`\`\`dart
mixin TimestampMixin {
  DateTime? _createdAt;
  DateTime? _updatedAt;
  
  DateTime get createdAt => _createdAt ??= DateTime.now();
  
  void markUpdated() {
    _updatedAt = DateTime.now();
  }
  
  DateTime? get updatedAt => _updatedAt;
  
  String get createdAtFormatted {
    return createdAt.toIso8601String();
  }
}

mixin ValidationMixin {
  final List<String> _errors = [];
  
  List<String> get errors => List.unmodifiable(_errors);
  bool get isValid => _errors.isEmpty;
  
  void addError(String error) {
    _errors.add(error);
  }
  
  void clearErrors() {
    _errors.clear();
  }
}

class Post with TimestampMixin, ValidationMixin {
  String title;
  String content;
  
  Post(this.title, this.content) {
    validate();
  }
  
  void validate() {
    clearErrors();
    if (title.isEmpty) addError('Title is required');
    if (content.length < 10) addError('Content too short');
  }
  
  void edit(String newContent) {
    content = newContent;
    validate();
    if (isValid) {
      markUpdated();
    }
  }
}

void main() async {
  var post = Post('Hello', 'World');
  print('Created: ${post.createdAt}');
  print('Valid: ${post.isValid}');
  print('Errors: ${post.errors}');
  
  await Future.delayed(Duration(seconds: 2));
  post.edit('Updated content with more text');
  print('Updated: ${post.updatedAt}');
  print('Valid: ${post.isValid}');
}
\`\`\`

**So sánh Abstract Class vs Mixin:**

| Đặc điểm | Abstract Class | Mixin |
|----------|----------------|-------|
| **Kế thừa** | Single (chỉ 1) | Multiple (nhiều) |
| **Constructor** | Có | Không |
| **Extends** | Có thể extends class khác | Không extends được |
| **Ràng buộc** | Không | Có (với `on`) |
| **State** | Có | Có |
| **Use case** | IS-A relationship | HAS-A behavior |

---

### 4.2. Interfaces

Trong Dart, **mọi class đều là interface**. Dùng `implements` để implement interface.

\`\`\`dart
// Class này vừa là class vừa là interface
class Drawable {
  void draw() {
    print('Drawing...');
  }
  
  void erase() {
    print('Erasing...');
  }
}

// Implement interface - phải override TẤT CẢ members
class Circle implements Drawable {
  double radius;
  
  Circle(this.radius);
  
  @override
  void draw() {
    print('Vẽ hình tròn bán kính $radius');
  }
  
  @override
  void erase() {
    print('Xóa hình tròn');
  }
}

// Implement nhiều interfaces
abstract class Printable {
  void print();
}

abstract class Saveable {
  void save();
}

abstract class Shareable {
  void share();
}

class Document implements Printable, Saveable, Shareable {
  String content;
  
  Document(this.content);
  
  @override
  void print() {
    print('Printing: $content');
  }
  
  @override
  void save() {
    print('Saving document...');
  }
  
  @override
  void share() {
    print('Sharing document...');
  }
}

void main() {
  var circle = Circle(5);
  circle.draw();
  circle.erase();
  
  var doc = Document('My Document');
  doc.print();
  doc.save();
  doc.share();
}
\`\`\`

**So sánh extends vs implements vs with:**

| Đặc điểm | `extends` | `implements` | `with` |
|----------|-----------|--------------|--------|
| **Số lượng** | 1 | Nhiều | Nhiều |
| **Kế thừa code** | Có | Không | Có |
| **Phải override** | Không (trừ abstract) | Tất cả | Không |
| **Constructor** | Kế thừa | Không | Không |
| **Use case** | IS-A | Contract | Behavior reuse |
| **Thứ tự** | Đầu tiên | Sau with | Sau extends |

---

### 4.3. Extension Methods

Thêm methods vào class có sẵn mà không cần kế thừa hay sửa source code.

\`\`\`dart
// Extension cho String
extension StringExtensions on String {
  // Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
  
  // Check if valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  // Truncate string
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return substring(0, maxLength) + suffix;
  }
  
  // Remove whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');
  
  // To title case
  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

// Extension cho List
extension ListExtensions<T> on List<T> {
  // Get first or null
  T? get firstOrNull => isEmpty ? null : first;
  
  // Get last or null
  T? get lastOrNull => isEmpty ? null : last;
  
  // Chunk list
  List<List<T>> chunk(int size) {
    List<List<T>> chunks = [];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
  
  // Remove duplicates
  List<T> get unique => toSet().toList();
}

// Extension cho int
extension IntExtensions on int {
  // Check if even
  bool get isEven => this % 2 == 0;
  
  // Check if odd
  bool get isOdd => this % 2 != 0;
  
  // Times iteration
  void times(void Function(int) action) {
    for (var i = 0; i < this; i++) {
      action(i);
    }
  }
}

void main() {
  // String extensions
  print('hello'.capitalize());              // Hello
  print('test@example.com'.isValidEmail);   // true
  print('Long text here'.truncate(8));      // Long tex...
  print('hello world'.toTitleCase());       // Hello World
  
  // List extensions
  var emptyList = <int>[];
  print(emptyList.firstOrNull);             // null
  
  var numbers = [1, 2, 3, 4, 5, 6, 7];
  print(numbers.chunk(3));                  // [[1, 2, 3], [4, 5, 6], [7]]
  
  var duplicates = [1, 2, 2, 3, 3, 3];
  print(duplicates.unique);                 // [1, 2, 3]
  
  // Int extensions
  print(4.isEven);                          // true
  print(5.isOdd);                           // true
  
  3.times((i) => print('Iteration $i'));
}
\`\`\`

**Best practices:**
- Đặt tên extension rõ ràng: `StringExtensions`, `DateTimeExtensions`
- Nhóm related methods trong cùng extension
- Tránh conflict với existing methods
- Dùng cho utility functions, không abuse
- Có thể đặt trong file riêng và import khi cần

---

### 4.4. Generics

Cho phép viết code type-safe mà vẫn linh hoạt với nhiều kiểu dữ liệu.

#### 4.4.1. Generic Classes

\`\`\`dart
// Generic class
class Box<T> {
  T value;
  
  Box(this.value);
  
  T getValue() => value;
  
  void setValue(T newValue) {
    value = newValue;
  }
  
  void display() {
    print('Box contains: $value (${value.runtimeType})');
  }
}

// Generic class với multiple type parameters
class Pair<K, V> {
  K key;
  V value;
  
  Pair(this.key, this.value);
  
  @override
  String toString() => 'Pair($key: $value)';
}

void main() {
  var intBox = Box<int>(42);
  print(intBox.getValue()); // 42
  intBox.display();         // Box contains: 42 (int)
  
  var stringBox = Box<String>('Hello');
  stringBox.display();      // Box contains: Hello (String)
  
  // Type inference
  var autoBox = Box(3.14);  // Box<double>
  autoBox.display();
  
  var pair = Pair<String, int>('age', 25);
  print(pair);              // Pair(age: 25)
}
\`\`\`

#### 4.4.2. Generic Methods

\`\`\`dart
// Generic method
T getFirst<T>(List<T> items) {
  if (items.isEmpty) throw Exception('List is empty');
  return items.first;
}

// Multiple type parameters
Map<K, V> createMap<K, V>(List<K> keys, List<V> values) {
  if (keys.length != values.length) {
    throw Exception('Keys and values must have same length');
  }
  return Map.fromIterables(keys, values);
}

// Generic method trong class
class Utils {
  static T? findFirst<T>(List<T> items, bool Function(T) predicate) {
    for (var item in items) {
      if (predicate(item)) return item;
    }
    return null;
  }
  
  static List<R> transform<T, R>(List<T> items, R Function(T) transformer) {
    return items.map(transformer).toList();
  }
}

void main() {
  print(getFirst([1, 2, 3]));           // 1
  print(getFirst(['a', 'b', 'c']));     // a
  
  var map = createMap(['name', 'age'], ['An', 25]);
  print(map);                           // {name: An, age: 25}
  
  var numbers = [1, 2, 3, 4, 5];
  var firstEven = Utils.findFirst(numbers, (n) => n % 2 == 0);
  print(firstEven);                     // 2
  
  var doubled = Utils.transform(numbers, (n) => n * 2);
  print(doubled);                       // [2, 4, 6, 8, 10]
}
\`\`\`

#### 4.4.3. Generic Constraints

\`\`\`dart
// Constraint với extends
class NumberBox<T extends num> {
  T value;
  
  NumberBox(this.value);
  
  T add(T other) => (value + other) as T;
  
  bool isGreaterThan(T other) => value > other;
  
  T get doubled => (value * 2) as T;
}

// Generic với Comparable
class SortedList<T extends Comparable<T>> {
  final List<T> _items = [];
  
  void add(T item) {
    _items.add(item);
    _items.sort();
  }
  
  List<T> get items => List.unmodifiable(_items);
  
  T? get min => _items.isEmpty ? null : _items.first;
  T? get max => _items.isEmpty ? null : _items.last;
}

void main() {
  var intBox = NumberBox<int>(10);
  print(intBox.add(5));              // 15
  print(intBox.doubled);             // 20
  
  var doubleBox = NumberBox<double>(3.14);
  print(doubleBox.isGreaterThan(2.0)); // true
  
  // var stringBox = NumberBox<String>('test'); // ERROR
  
  var sortedInts = SortedList<int>();
  sortedInts.add(5);
  sortedInts.add(2);
  sortedInts.add(8);
  sortedInts.add(1);
  print(sortedInts.items);  // [1, 2, 5, 8]
  print('Min: ${sortedInts.min}, Max: ${sortedInts.max}');
}
\`\`\`

#### 4.4.4. Generic trong Flutter/Real-world

\`\`\`dart
// Generic State management
abstract class BaseState<T> {
  T? data;
  String? error;
  bool isLoading = false;
  
  bool get hasData => data != null;
  bool get hasError => error != null;
  bool get isIdle => !isLoading && !hasError && !hasData;
}

class UserState extends BaseState<User> {
  void loadUser(User user) {
    data = user;
    isLoading = false;
    error = null;
  }
  
  void setError(String err) {
    error = err;
    isLoading = false;
  }
}

// Generic Repository pattern
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);
  Future<void> update(String id, T item);
}

class UserRepository implements Repository<User> {
  final List<User> _users = [];
  
  @override
  Future<List<User>> getAll() async {
    return List.unmodifiable(_users);
  }
  
  @override
  Future<User?> getById(String id) async {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> save(User item) async {
    _users.add(item);
  }
  
  @override
  Future<void> delete(String id) async {
    _users.removeWhere((u) => u.id == id);
  }
  
  @override
  Future<void> update(String id, User item) async {
    final index = _users.indexWhere((u) => u.id == id);
    if (index != -1) {
      _users[index] = item;
    }
  }
}

class User {
  String id;
  String name;
  int age;
  
  User(this.id, this.name, this.age);
}

void main() async {
  var userRepo = UserRepository();
  await userRepo.save(User('1', 'An', 25));
  await userRepo.save(User('2', 'Bình', 30));
  
  var users = await userRepo.getAll();
  print('Total users: ${users.length}');
  
  var user = await userRepo.getById('1');
  print('Found: ${user?.name}');
}
\`\`\`

---

### 4.5. Null Safety Toàn Diện

Dart có **sound null safety** - compiler đảm bảo non-nullable variables không bao giờ null.

#### 4.5.1. Null Safety Operators Chi Tiết

\`\`\`dart
void main() {
  String? nullableName;
  String name = 'An';
  
  // 1. Null-aware access (?.)
  print(nullableName?.length);  // null (không crash)
  print(name.length);           // 2
  
  // Chain null-aware
  String? email;
  print(email?.toLowerCase()?.trim()); // null
  
  // 2. Null assertion (!)
  String? value = 'Test';
  print(value!.length);  // 4 - OK
  
  // String? nullValue = null;
  // print(nullValue!.length); // CRASH!
  
  // 3. Null coalescing (??)
  String displayName = nullableName ?? 'Guest';
  print(displayName);  // Guest
  
  // Chain ??
  String? first;
  String? second;
  String? third = 'Third';
  String result = first ?? second ?? third ?? 'Default';
  print(result);  // Third
  
  // 4. Null-aware assignment (??=)
  String? username;
  username ??= 'DefaultUser';
  print(username);  // DefaultUser
  username ??= 'AnotherUser';
  print(username);  // DefaultUser (không đổi)
  
  // 5. Null-aware cascade (?..)
  List<int>? numbers;
  numbers?..add(1)..add(2)..add(3);  // Không làm gì nếu null
  print(numbers);  // null
  
  numbers = [];
  numbers?..add(1)..add(2);
  print(numbers);  // [1, 2]
}
\`\`\`

#### 4.5.2. Late Variables Chi Tiết

\`\`\`dart
class UserService {
  // Late - khởi tạo sau
  late String apiKey;
  
  // Late final - chỉ gán 1 lần
  late final String userId;
  
  // Lazy initialization - chỉ chạy khi truy cập lần đầu
  late String heavyData = _loadHeavyData();
  
  // Late với nullable
  late String? optionalData;
  
  String _loadHeavyData() {
    print('Loading heavy data...');
    return 'Heavy data loaded';
  }
  
  void init(String key, String id) {
    apiKey = key;
    userId = id;
    // userId = 'another'; // ERROR - late final chỉ gán 1 lần
  }
}

// Late trong top-level
late final String appConfig = loadConfig();

String loadConfig() {
  print('Loading config...');
  return 'Config loaded';
}

void main() {
  var service = UserService();
  service.init('abc123', 'user_1');
  
  print(service.apiKey);  // abc123
  print(service.userId);  // user_1
  
  // heavyData chỉ load khi truy cập lần đầu
  print(service.heavyData);  // Loading heavy data... Heavy data loaded
  print(service.heavyData);  // Heavy data loaded (không load lại)
  
  // Top-level late
  print(appConfig);  // Loading config... Config loaded
}
\`\`\`

#### 4.5.3. Required Parameters

\`\`\`dart
class User {
  final String name;
  final int age;
  final String? email;  // Optional
  final String? phone;  // Optional
  
  // Named parameters với required
  User({
    required this.name,
    required this.age,
    this.email,
    this.phone,
  });
}

// Function với required
void sendNotification({
  required String userId,
  required String message,
  String? title,
  bool urgent = false,
}) {
  print('Sending to $userId: $message');
  if (urgent) print('URGENT!');
}

void main() {
  var user = User(name: 'An', age: 25);
  // var user2 = User(age: 25); // ERROR - thiếu name
  
  sendNotification(userId: '123', message: 'Hello');
  sendNotification(
    userId: '456',
    message: 'Important',
    urgent: true,
  );
}
\`\`\`

**So sánh Null Safety Operators:**

| Operator | Ý nghĩa | Return | Khi nào dùng |
|----------|---------|--------|--------------|
| `?.` | Null-aware access | null hoặc value | Truy cập an toàn |
| `!` | Null assertion | value hoặc crash | Chắc chắn không null |
| `??` | Null coalescing | value hoặc default | Giá trị mặc định |
| `??=` | Null-aware assignment | void | Gán nếu null |
| `?..` | Null-aware cascade | void | Cascade an toàn |

---

### 4.6. Enhanced Enum (Dart 2.17+)

Enum nâng cao với fields, methods, và implements.

\`\`\`dart
// Enhanced enum với fields và methods
enum Status {
  pending(color: 0xFFFFA500, label: 'Đang chờ', priority: 1),
  approved(color: 0xFF00FF00, label: 'Đã duyệt', priority: 3),
  rejected(color: 0xFFFF0000, label: 'Từ chối', priority: 2);
  
  final int color;
  final String label;
  final int priority;
  
  const Status({
    required this.color,
    required this.label,
    required this.priority,
  });
  
  // Method
  bool get isCompleted => this == approved || this == rejected;
  
  bool get isPending => this == pending;
  
  // Static method
  static Status fromString(String value) {
    return Status.values.firstWhere(
      (s) => s.name == value,
      orElse: () => Status.pending,
    );
  }
  
  // Override toString
  @override
  String toString() => label;
}

// Enum implements interface
enum HttpMethod implements Comparable<HttpMethod> {
  get(priority: 1, idempotent: true),
  post(priority: 2, idempotent: false),
  put(priority: 2, idempotent: true),
  delete(priority: 3, idempotent: true),
  patch(priority: 2, idempotent: false);
  
  final int priority;
  final bool idempotent;
  
  const HttpMethod({
    required this.priority,
    required this.idempotent,
  });
  
  @override
  int compareTo(HttpMethod other) => priority.compareTo(other.priority);
  
  bool get isSafe => this == get;
}

// Enum với methods phức tạp
enum PaymentMethod {
  cash(fee: 0, processingTime: 0),
  card(fee: 2.5, processingTime: 1),
  bankTransfer(fee: 1.0, processingTime: 24),
  eWallet(fee: 1.5, processingTime: 0);
  
  final double fee;
  final int processingTime;  // hours
  
  const PaymentMethod({
    required this.fee,
    required this.processingTime,
  });
  
  double calculateFee(double amount) {
    return amount * (fee / 100);
  }
  
  String get description {
    return switch (this) {
      cash => 'Thanh toán tiền mặt',
      card => 'Thanh toán thẻ',
      bankTransfer => 'Chuyển khoản ngân hàng',
      eWallet => 'Ví điện tử',
    };
  }
}

void main() {
  var status = Status.pending;
  print(status.label);        // Đang chờ
  print(status.color);        // 4294944256
  print(status.isCompleted);  // false
  print(status.priority);     // 1
  
  // Switch với enum
  var message = switch (status) {
    Status.pending => 'Chờ xử lý',
    Status.approved => 'Đã chấp nhận',
    Status.rejected => 'Đã từ chối',
  };
  print(message);
  
  // HttpMethod
  var method = HttpMethod.post;
  print(method.priority);     // 2
  print(method.idempotent);   // false
  print(method.isSafe);       // false
  
  // PaymentMethod
  var payment = PaymentMethod.card;
  print(payment.description);
  print('Fee for 1000: ${payment.calculateFee(1000)}');  // 25.0
  
  // Iterate all values
  for (var method in PaymentMethod.values) {
    print('${method.name}: ${method.description}');
  }
}
\`\`\`

**So sánh Old Enum vs Enhanced Enum:**

| Đặc điểm | Old Enum | Enhanced Enum |
|----------|----------|---------------|
| **Fields** | Không | Có |
| **Methods** | Không | Có |
| **Constructor** | Không | Có (const) |
| **Implements** | Không | Có |
| **Custom values** | Không | Có |
| **Use case** | Simple constants | Rich domain models |

---

### 4.7. Records (Dart 3.0+)

Records là anonymous, immutable, aggregate types - thay thế cho class đơn giản.

#### 4.7.1. Cơ bản về Records

\`\`\`dart
void main() {
  // Positional record
  var record = ('An', 25, true);
  print(record.$1);  // An
  print(record.$2);  // 25
  print(record.$3);  // true
  
  // Named record
  var person = (name: 'Bình', age: 30, isActive: false);
  print(person.name);      // Bình
  print(person.age);       // 30
  print(person.isActive);  // false
  
  // Mixed (positional + named)
  var mixed = ('An', age: 25, city: 'HN');
  print(mixed.$1);    // An
  print(mixed.age);   // 25
  print(mixed.city);  // HN
  
  // Empty record
  var empty = ();
  
  // Single element (needs trailing comma)
  var single = ('value',);
  print(single.$1);  // value
}
\`\`\`

#### 4.7.2. Records trong Functions

\`\`\`dart
// Return multiple values
(String, int) getUserInfo() {
  return ('An', 25);
}

// Named record return
({String name, int age, String email}) getUserDetails() {
  return (name: 'An', age: 25, email: 'an@example.com');
}

// Mixed return
(String, {int age, String city}) getMixedInfo() {
  return ('An', age: 25, city: 'HN');
}

// Record as parameter
void printPerson((String name, int age) person) {
  print('${person.$1} is ${person.$2} years old');
}

// Destructuring in parameters
void printPersonDestructured((String, int) person) {
  var (name, age) = person;
  print('$name is $age years old');
}

void main() {
  // Destructuring
  var (name, age) = getUserInfo();
  print('$name, $age tuổi');  // An, 25 tuổi
  
  var user = getUserDetails();
  print('${user.name} - ${user.email}');
  
  var (userName, :age, :city) = getMixedInfo();
  print('$userName, $age, $city');
  
  // Pass record
  printPerson(('Bình', 30));
  printPersonDestructured(('Cường', 35));
}
\`\`\`

#### 4.7.3. Records vs Class

\`\`\`dart
// Với Class
class Point {
  final double x, y;
  const Point(this.x, this.y);
  
  @override
  String toString() => 'Point($x, $y)';
}

// Với Record
typedef PointRecord = (double x, double y);

// Với Class - có methods
class Rectangle {
  final double width, height;
  
  const Rectangle(this.width, this.height);
  
  double get area => width * height;
  
  bool contains(Point point) {
    return point.x >= 0 && point.x <= width &&
           point.y >= 0 && point.y <= height;
  }
}

// Với Record - không có methods
typedef RectangleRecord = (double width, double height);

double calculateArea(RectangleRecord rect) {
  return rect.$1 * rect.$2;
}

void main() {
  // Class
  var p1 = Point(10, 20);
  print('${p1.x}, ${p1.y}');
  
  // Record
  var p2 = (x: 10.0, y: 20.0);
  print('${p2.x}, ${p2.y}');
  
  // Equality
  var p3 = (x: 10.0, y: 20.0);
  print(p2 == p3);  // true - structural equality
  
  var p4 = Point(10, 20);
  var p5 = Point(10, 20);
  print(p4 == p5);  // false - reference equality (unless override ==)
}
\`\`\`

**So sánh Records vs Class:**

| Đặc điểm | Records | Class |
|----------|---------|-------|
| **Syntax** | Ngắn gọn `(x: 1, y: 2)` | Dài hơn |
| **Mutability** | Immutable | Có thể mutable |
| **Methods** | Không | Có |
| **Equality** | Structural | Reference (trừ khi override) |
| **Performance** | Nhanh hơn | Chậm hơn một chút |
| **Use case** | Temporary data, return values | Domain models, business logic |

---

### 4.8. Pattern Matching (Dart 3.0+)

Pattern matching mạnh mẽ cho destructuring và control flow.

#### 4.8.1. Switch Expressions

\`\`\`dart
String getStatusMessage(int code) {
  return switch (code) {
    200 => 'Success',
    201 => 'Created',
    404 => 'Not Found',
    500 => 'Server Error',
    >= 400 && < 500 => 'Client Error',
    >= 500 => 'Server Error',
    _ => 'Unknown',
  };
}

// Switch với multiple values
String getGrade(int score) {
  return switch (score) {
    >= 90 => 'A',
    >= 80 => 'B',
    >= 70 => 'C',
    >= 60 => 'D',
    _ => 'F',
  };
}

// Switch với type
String describeValue(Object value) {
  return switch (value) {
    int() => 'Integer: $value',
    double() => 'Double: $value',
    String() => 'String: $value',
    List() => 'List with ${value.length} items',
    _ => 'Unknown type',
  };
}

void main() {
  print(getStatusMessage(200));  // Success
  print(getStatusMessage(403));  // Client Error
  print(getGrade(85));           // B
  print(describeValue(42));      // Integer: 42
  print(describeValue([1, 2]));  // List with 2 items
}
\`\`\`

#### 4.8.2. Destructuring Records

\`\`\`dart
void main() {
  var person = (name: 'An', age: 25, city: 'HN');
  
  // Destructuring
  var (name: userName, age: userAge, city: _) = person;
  print('$userName, $userAge tuổi');  // An, 25 tuổi
  
  // Positional destructuring
  var point = (10, 20);
  var (x, y) = point;
  print('x: $x, y: $y');  // x: 10, y: 20
  
  // In switch
  var result = switch (person) {
    (name: 'An', age: var a, city: _) => 'Found An, age $a',
    (name: var n, age: > 30, city: _) => '$n is over 30',
    _ => 'Other person',
  };
  print(result);
}
\`\`\`

#### 4.8.3. List & Map Patterns

\`\`\`dart
void main() {
  var numbers = [1, 2, 3, 4, 5];
  
  // List destructuring
  var [first, second, ...rest] = numbers;
  print('First: $first');    // 1
  print('Second: $second');  // 2
  print('Rest: $rest');      // [3, 4, 5]
  
  // Pattern matching with lists
  var message = switch (numbers) {
    [] => 'Empty list',
    [var x] => 'Single element: $x',
    [var x, var y] => 'Two elements: $x, $y',
    [var first, ...var rest] => 'First: $first, Rest: $rest',
  };
  print(message);
  
  // Map patterns
  var user = {'name': 'An', 'age': 25, 'city': 'HN'};
  
  var greeting = switch (user) {
    {'name': var n, 'age': var a} => 'Hello $n, age $a',
    {'name': var n} => 'Hello $n',
    _ => 'Hello stranger',
  };
  print(greeting);
}
\`\`\`

#### 4.8.4. Object Patterns với Sealed Classes

\`\`\`dart
sealed class Shape {}

class Circle extends Shape {
  final double radius;
  Circle(this.radius);
}

class Rectangle extends Shape {
  final double width, height;
  Rectangle(this.width, this.height);
}

class Triangle extends Shape {
  final double base, height;
  Triangle(this.base, this.height);
}

// Exhaustive pattern matching
double calculateArea(Shape shape) {
  return switch (shape) {
    Circle(radius: var r) => 3.14 * r * r,
    Rectangle(width: var w, height: var h) => w * h,
    Triangle(base: var b, height: var h) => 0.5 * b * h,
    // Không cần default case - compiler check exhaustive
  };
}

String describeShape(Shape shape) {
  return switch (shape) {
    Circle(radius: var r) when r > 10 => 'Large circle',
    Circle(radius: var r) => 'Small circle with radius $r',
    Rectangle(width: var w, height: var h) when w == h => 'Square',
    Rectangle() => 'Rectangle',
    Triangle() => 'Triangle',
  };
}

void main() {
  print(calculateArea(Circle(5)));           // 78.5
  print(calculateArea(Rectangle(4, 6)));     // 24.0
  print(calculateArea(Triangle(3, 4)));      // 6.0
  
  print(describeShape(Circle(15)));          // Large circle
  print(describeShape(Rectangle(5, 5)));     // Square
}
\`\`\`

---

### 4.9. Class Modifiers (Dart 3.0+)

Kiểm soát cách class được sử dụng bên ngoài library.

#### 4.9.1. Sealed Classes

Chỉ có thể được extended trong cùng library, bắt buộc exhaustive checking.

\`\`\`dart
// sealed class - chỉ subclass trong cùng file/library
sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
}

class Error<T> extends Result<T> {
  final String message;
  final int? code;
  Error(this.message, [this.code]);
}

class Loading<T> extends Result<T> {}

// Exhaustive checking - compiler bắt buộc handle tất cả cases
String handleResult<T>(Result<T> result) {
  return switch (result) {
    Success(data: var d) => 'Success: $d',
    Error(message: var m, code: var c) => 'Error $c: $m',
    Loading() => 'Loading...',
    // Không cần default case
  };
}

// Real-world example
sealed class NetworkResponse<T> {}

class NetworkSuccess<T> extends NetworkResponse<T> {
  final T data;
  final int statusCode;
  NetworkSuccess(this.data, this.statusCode);
}

class NetworkError<T> extends NetworkResponse<T> {
  final String message;
  final int statusCode;
  NetworkError(this.message, this.statusCode);
}

class NetworkTimeout<T> extends NetworkResponse<T> {}

void main() {
  var success = Success('Data loaded');
  var error = Error('Network error', 500);
  var loading = Loading();
  
  print(handleResult(success));  // Success: Data loaded
  print(handleResult(error));    // Error 500: Network error
  print(handleResult(loading));  // Loading...
}
\`\`\`

#### 4.9.2. Final Classes

Không thể được extended hoặc implemented bên ngoài library.

\`\`\`dart
// final class - không thể extend hay implement
final class ImmutableConfig {
  final String apiKey;
  final String baseUrl;
  final int timeout;
  
  const ImmutableConfig({
    required this.apiKey,
    required this.baseUrl,
    this.timeout = 30,
  });
}

// class MyConfig extends ImmutableConfig {} // ERROR
// class MyConfig implements ImmutableConfig {} // ERROR

// Use case: Prevent inheritance for security/performance
final class SecureStorage {
  final Map<String, String> _storage = {};
  
  void set(String key, String value) {
    _storage[key] = value;
  }
  
  String? get(String key) => _storage[key];
}

void main() {
  var config = ImmutableConfig(
    apiKey: 'abc123',
    baseUrl: 'https://api.example.com',
  );
  print(config.apiKey);
}
\`\`\`

#### 4.9.3. Base Classes

Phải được extended, không thể implemented.

\`\`\`dart
// base class - chỉ có thể extends, không implements
base class Vehicle {
  String brand;
  int year;
  
  Vehicle(this.brand, this.year);
  
  void start() => print('$brand starting...');
  
  void stop() => print('$brand stopping...');
}

class Car extends Vehicle {
  int seats;
  
  Car(String brand, int year, this.seats) : super(brand, year);
  
  @override
  void start() {
    super.start();
    print('Car with $seats seats ready');
  }
}

// class Bike implements Vehicle {} // ERROR - không thể implements

void main() {
  var car = Car('Toyota', 2026, 5);
  car.start();
}
\`\`\`

#### 4.9.4. Interface Classes

Chỉ có thể implemented, không thể extended.

\`\`\`dart
// interface class - chỉ có thể implements
interface class Drawable {
  void draw() {
    print('Drawing...');
  }
  
  void erase() {
    print('Erasing...');
  }
}

class Circle implements Drawable {
  double radius;
  
  Circle(this.radius);
  
  @override
  void draw() => print('Drawing circle');
  
  @override
  void erase() => print('Erasing circle');
}

// class Shape extends Drawable {} // ERROR - không thể extends

void main() {
  var circle = Circle(5);
  circle.draw();
}
\`\`\`

#### 4.9.5. Mixin Classes

Có thể dùng như mixin hoặc class thông thường.

\`\`\`dart
// mixin class - có thể dùng như mixin hoặc class
mixin class Loggable {
  void log(String message) {
    print('[${DateTime.now()}] $message');
  }
  
  void logError(String error) {
    print('[ERROR] $error');
  }
}

// Dùng như mixin
class Service with Loggable {
  void doSomething() {
    log('Doing something');
  }
}

// Dùng như class
class Logger extends Loggable {
  void customLog(String message) {
    log('Custom: $message');
  }
}

void main() {
  var service = Service();
  service.doSomething();  // [2026-04-16...] Doing something
  
  var logger = Logger();
  logger.customLog('Test');  // [2026-04-16...] Custom: Test
}
\`\`\`

**So sánh Class Modifiers:**

| Modifier | Extends | Implements | Mixin | Use case |
|----------|---------|------------|-------|----------|
| **sealed** | Trong library | Không | Không | Exhaustive pattern matching |
| **final** | Không | Không | Không | Prevent inheritance |
| **base** | Có | Không | Không | Force inheritance |
| **interface** | Không | Có | Không | Pure contracts |
| **mixin** | Có | Có (as mixin) | Có | Flexible reuse |

---

## Tổng kết Phần 4

Phần 4 đã cover trung cấp OOP:
- ✅ Mixins (with, on, state)
- ✅ Interfaces (implements, multiple)
- ✅ Extension methods (generic, constraints)
- ✅ Generics (class, method, constraints, real-world)
- ✅ Null safety toàn diện (operators, late, required)
- ✅ Enhanced Enum với fields, methods, implements
- ✅ Records - immutable aggregate types
- ✅ Pattern matching (switch expressions, destructuring, sealed classes)
- ✅ Class modifiers (sealed, final, base, interface, mixin)

**Các bảng so sánh quan trọng:**
- Abstract class vs Mixin
- extends vs implements vs with
- Null safety operators
- Old enum vs Enhanced enum
- Records vs Class
- Class modifiers comparison

---

## 5. Nâng cao OOP trong Dart

### 5.1. Effective Dart & Clean Code OOP

#### 5.1.1. Naming Conventions

\`\`\`dart
// Classes, enums, typedefs: PascalCase
class UserProfile {}
enum Status { active, inactive }
typedef Callback = void Function();

// Libraries, packages, directories, files: snake_case
// user_repository.dart
// api_service.dart

// Variables, functions, parameters: camelCase
var userName = 'An';
void fetchData() {}
void processUser(String userId) {}

// Constants: lowerCamelCase
const maxRetries = 3;
const apiTimeout = 30;

// Private members: prefix _
class BankAccount {
  double _balance;
  void _logTransaction() {}
}

// Boolean variables: is, has, can
bool isActive = true;
bool hasPermission = false;
bool canEdit = true;
\`\`\`

#### 5.1.2. Immutability

\`\`\`dart
// BAD - Mutable
class User {
  String name;
  int age;
  
  User(this.name, this.age);
}

// GOOD - Immutable
class User {
  final String name;
  final int age;
  
  const User(this.name, this.age);
  
  // Copy with method for "mutations"
  User copyWith({String? name, int? age}) {
    return User(
      name ?? this.name,
      age ?? this.age,
    );
  }
}

void main() {
  const user = User('An', 25);
  // user.name = 'Bình'; // ERROR
  
  final updatedUser = user.copyWith(age: 26);
  print('${updatedUser.name}, ${updatedUser.age}');
}
\`\`\`

#### 5.1.3. Composition over Inheritance

\`\`\`dart
// BAD - Deep inheritance
class Animal {}
class Mammal extends Animal {}
class Dog extends Mammal {}
class Labrador extends Dog {}

// GOOD - Composition
class Engine {
  void start() => print('Engine starting');
}

class Wheels {
  int count;
  Wheels(this.count);
}

class Car {
  final Engine engine;
  final Wheels wheels;
  
  Car(this.engine, this.wheels);
  
  void drive() {
    engine.start();
    print('Driving with ${wheels.count} wheels');
  }
}

void main() {
  var car = Car(Engine(), Wheels(4));
  car.drive();
}
\`\`\`

---

### 5.2. SOLID Principles

#### 5.2.1. Single Responsibility Principle (SRP)

Một class chỉ nên có một lý do để thay đổi.

\`\`\`dart
// BAD - Multiple responsibilities
class User {
  String name;
  String email;
  
  User(this.name, this.email);
  
  void save() {
    // Database logic
    print('Saving to database...');
  }
  
  void sendEmail() {
    // Email logic
    print('Sending email...');
  }
  
  String toJson() {
    // Serialization logic
    return '{"name": "$name", "email": "$email"}';
  }
}

// GOOD - Separated responsibilities
class User {
  final String name;
  final String email;
  
  const User(this.name, this.email);
}

class UserRepository {
  void save(User user) {
    print('Saving ${user.name} to database...');
  }
}

class EmailService {
  void sendWelcomeEmail(User user) {
    print('Sending email to ${user.email}');
  }
}

class UserSerializer {
  String toJson(User user) {
    return '{"name": "${user.name}", "email": "${user.email}"}';
  }
}

void main() {
  var user = User('An', 'an@example.com');
  
  var repo = UserRepository();
  repo.save(user);
  
  var emailService = EmailService();
  emailService.sendWelcomeEmail(user);
  
  var serializer = UserSerializer();
  print(serializer.toJson(user));
}
\`\`\`

#### 5.2.2. Open/Closed Principle (OCP)

Open for extension, closed for modification.

\`\`\`dart
// BAD - Modify existing code for new features
class AreaCalculator {
  double calculate(Object shape) {
    if (shape is Circle) {
      return 3.14 * shape.radius * shape.radius;
    } else if (shape is Rectangle) {
      return shape.width * shape.height;
    }
    // Need to modify this method for new shapes
    return 0;
  }
}

// GOOD - Extend without modifying
abstract class Shape {
  double calculateArea();
}

class Circle implements Shape {
  final double radius;
  Circle(this.radius);
  
  @override
  double calculateArea() => 3.14 * radius * radius;
}

class Rectangle implements Shape {
  final double width, height;
  Rectangle(this.width, this.height);
  
  @override
  double calculateArea() => width * height;
}

// New shape - no modification needed
class Triangle implements Shape {
  final double base, height;
  Triangle(this.base, this.height);
  
  @override
  double calculateArea() => 0.5 * base * height;
}

class AreaCalculator {
  double calculate(Shape shape) {
    return shape.calculateArea();
  }
}

void main() {
  var calculator = AreaCalculator();
  print(calculator.calculate(Circle(5)));
  print(calculator.calculate(Rectangle(4, 6)));
  print(calculator.calculate(Triangle(3, 4)));
}
\`\`\`

#### 5.2.3. Liskov Substitution Principle (LSP)

Subclass phải có thể thay thế superclass mà không làm hỏng chương trình.

\`\`\`dart
// BAD - Violates LSP
class Bird {
  void fly() => print('Flying');
}

class Penguin extends Bird {
  @override
  void fly() {
    throw Exception('Penguins cannot fly!');
  }
}

// GOOD - Follows LSP
abstract class Bird {
  void move();
}

class FlyingBird extends Bird {
  @override
  void move() => print('Flying');
}

class Penguin extends Bird {
  @override
  void move() => print('Swimming');
}

void makeBirdMove(Bird bird) {
  bird.move();  // Works for all birds
}

void main() {
  makeBirdMove(FlyingBird());  // Flying
  makeBirdMove(Penguin());     // Swimming
}
\`\`\`

#### 5.2.4. Interface Segregation Principle (ISP)

Không nên force class implement methods không dùng.

\`\`\`dart
// BAD - Fat interface
abstract class Worker {
  void work();
  void eat();
  void sleep();
}

class Robot implements Worker {
  @override
  void work() => print('Working');
  
  @override
  void eat() => throw Exception('Robots don\'t eat');
  
  @override
  void sleep() => throw Exception('Robots don\'t sleep');
}

// GOOD - Segregated interfaces
abstract class Workable {
  void work();
}

abstract class Eatable {
  void eat();
}

abstract class Sleepable {
  void sleep();
}

class Human implements Workable, Eatable, Sleepable {
  @override
  void work() => print('Working');
  
  @override
  void eat() => print('Eating');
  
  @override
  void sleep() => print('Sleeping');
}

class Robot implements Workable {
  @override
  void work() => print('Working 24/7');
}

void main() {
  var human = Human();
  human.work();
  human.eat();
  human.sleep();
  
  var robot = Robot();
  robot.work();
}
\`\`\`

#### 5.2.5. Dependency Inversion Principle (DIP)

Depend on abstractions, not concretions.

\`\`\`dart
// BAD - Depends on concrete class
class MySQLDatabase {
  void save(String data) {
    print('Saving to MySQL: $data');
  }
}

class UserService {
  final MySQLDatabase database = MySQLDatabase();
  
  void createUser(String name) {
    database.save(name);
  }
}

// GOOD - Depends on abstraction
abstract class Database {
  void save(String data);
}

class MySQLDatabase implements Database {
  @override
  void save(String data) {
    print('Saving to MySQL: $data');
  }
}

class PostgreSQLDatabase implements Database {
  @override
  void save(String data) {
    print('Saving to PostgreSQL: $data');
  }
}

class UserService {
  final Database database;
  
  UserService(this.database);
  
  void createUser(String name) {
    database.save(name);
  }
}

void main() {
  // Easy to switch database
  var service1 = UserService(MySQLDatabase());
  service1.createUser('An');
  
  var service2 = UserService(PostgreSQLDatabase());
  service2.createUser('Bình');
}
\`\`\`

---

### 5.3. Design Patterns

#### 5.3.1. Singleton Pattern

\`\`\`dart
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  
  factory AppConfig() {
    return _instance;
  }
  
  AppConfig._internal();
  
  String apiUrl = 'https://api.example.com';
  int timeout = 30;
}

// Lazy singleton
class Logger {
  static Logger? _instance;
  
  Logger._internal();
  
  factory Logger() {
    _instance ??= Logger._internal();
    return _instance!;
  }
  
  void log(String message) {
    print('[LOG] $message');
  }
}

void main() {
  var config1 = AppConfig();
  var config2 = AppConfig();
  print(identical(config1, config2));  // true
  
  var logger1 = Logger();
  var logger2 = Logger();
  print(identical(logger1, logger2));  // true
}
\`\`\`

#### 5.3.2. Factory Pattern

\`\`\`dart
abstract class Vehicle {
  void drive();
  
  factory Vehicle(String type) {
    switch (type) {
      case 'car':
        return Car();
      case 'bike':
        return Bike();
      case 'truck':
        return Truck();
      default:
        throw Exception('Unknown vehicle type');
    }
  }
}

class Car implements Vehicle {
  @override
  void drive() => print('Driving a car');
}

class Bike implements Vehicle {
  @override
  void drive() => print('Riding a bike');
}

class Truck implements Vehicle {
  @override
  void drive() => print('Driving a truck');
}

void main() {
  var car = Vehicle('car');
  car.drive();
  
  var bike = Vehicle('bike');
  bike.drive();
}
\`\`\`

#### 5.3.3. Builder Pattern

\`\`\`dart
class User {
  final String name;
  final int age;
  final String? email;
  final String? phone;
  final String? address;
  
  User._({
    required this.name,
    required this.age,
    this.email,
    this.phone,
    this.address,
  });
}

class UserBuilder {
  String? _name;
  int? _age;
  String? _email;
  String? _phone;
  String? _address;
  
  UserBuilder setName(String name) {
    _name = name;
    return this;
  }
  
  UserBuilder setAge(int age) {
    _age = age;
    return this;
  }
  
  UserBuilder setEmail(String email) {
    _email = email;
    return this;
  }
  
  UserBuilder setPhone(String phone) {
    _phone = phone;
    return this;
  }
  
  UserBuilder setAddress(String address) {
    _address = address;
    return this;
  }
  
  User build() {
    if (_name == null || _age == null) {
      throw Exception('Name and age are required');
    }
    
    return User._(
      name: _name!,
      age: _age!,
      email: _email,
      phone: _phone,
      address: _address,
    );
  }
}

void main() {
  var user = UserBuilder()
      .setName('An')
      .setAge(25)
      .setEmail('an@example.com')
      .setPhone('0123456789')
      .build();
  
  print('${user.name}, ${user.age}, ${user.email}');
}
\`\`\`

#### 5.3.4. Strategy Pattern

\`\`\`dart
// Strategy interface
abstract class PaymentStrategy {
  void pay(double amount);
}

// Concrete strategies
class CreditCardPayment implements PaymentStrategy {
  final String cardNumber;
  
  CreditCardPayment(this.cardNumber);
  
  @override
  void pay(double amount) {
    print('Paid \$$amount using Credit Card: $cardNumber');
  }
}

class PayPalPayment implements PaymentStrategy {
  final String email;
  
  PayPalPayment(this.email);
  
  @override
  void pay(double amount) {
    print('Paid \$$amount using PayPal: $email');
  }
}

class CashPayment implements PaymentStrategy {
  @override
  void pay(double amount) {
    print('Paid \$$amount in cash');
  }
}

// Context
class ShoppingCart {
  PaymentStrategy? _paymentStrategy;
  
  void setPaymentStrategy(PaymentStrategy strategy) {
    _paymentStrategy = strategy;
  }
  
  void checkout(double amount) {
    if (_paymentStrategy == null) {
      throw Exception('Payment strategy not set');
    }
    _paymentStrategy!.pay(amount);
  }
}

void main() {
  var cart = ShoppingCart();
  
  cart.setPaymentStrategy(CreditCardPayment('1234-5678-9012-3456'));
  cart.checkout(100);
  
  cart.setPaymentStrategy(PayPalPayment('user@example.com'));
  cart.checkout(50);
  
  cart.setPaymentStrategy(CashPayment());
  cart.checkout(75);
}
\`\`\`

#### 5.3.5. Observer Pattern

\`\`\`dart
// Observer interface
abstract class Observer {
  void update(String message);
}

// Subject
class NewsAgency {
  final List<Observer> _observers = [];
  String _latestNews = '';
  
  void subscribe(Observer observer) {
    _observers.add(observer);
  }
  
  void unsubscribe(Observer observer) {
    _observers.remove(observer);
  }
  
  void publishNews(String news) {
    _latestNews = news;
    _notifyObservers();
  }
  
  void _notifyObservers() {
    for (var observer in _observers) {
      observer.update(_latestNews);
    }
  }
}

// Concrete observers
class NewsChannel implements Observer {
  final String name;
  
  NewsChannel(this.name);
  
  @override
  void update(String message) {
    print('[$name] Breaking news: $message');
  }
}

class NewsApp implements Observer {
  final String appName;
  
  NewsApp(this.appName);
  
  @override
  void update(String message) {
    print('[$appName] Push notification: $message');
  }
}

void main() {
  var agency = NewsAgency();
  
  var channel1 = NewsChannel('VTV');
  var channel2 = NewsChannel('HTV');
  var app = NewsApp('NewsApp');
  
  agency.subscribe(channel1);
  agency.subscribe(channel2);
  agency.subscribe(app);
  
  agency.publishNews('Dart 4.0 released!');
  
  agency.unsubscribe(channel2);
  agency.publishNews('Flutter 5.0 announced!');
}
\`\`\`

#### 5.3.6. Repository Pattern

\`\`\`dart
// Entity
class User {
  final String id;
  final String name;
  final String email;
  
  User(this.id, this.name, this.email);
}

// Repository interface
abstract class UserRepository {
  Future<List<User>> getAll();
  Future<User?> getById(String id);
  Future<void> save(User user);
  Future<void> delete(String id);
  Future<void> update(User user);
}

// Concrete repository
class UserRepositoryImpl implements UserRepository {
  final List<User> _users = [];
  
  @override
  Future<List<User>> getAll() async {
    await Future.delayed(Duration(milliseconds: 100));
    return List.unmodifiable(_users);
  }
  
  @override
  Future<User?> getById(String id) async {
    await Future.delayed(Duration(milliseconds: 50));
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> save(User user) async {
    await Future.delayed(Duration(milliseconds: 100));
    _users.add(user);
  }
  
  @override
  Future<void> delete(String id) async {
    await Future.delayed(Duration(milliseconds: 100));
    _users.removeWhere((u) => u.id == id);
  }
  
  @override
  Future<void> update(User user) async {
    await Future.delayed(Duration(milliseconds: 100));
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    }
  }
}

void main() async {
  var repo = UserRepositoryImpl();
  
  await repo.save(User('1', 'An', 'an@example.com'));
  await repo.save(User('2', 'Bình', 'binh@example.com'));
  
  var users = await repo.getAll();
  print('Total users: ${users.length}');
  
  var user = await repo.getById('1');
  print('Found: ${user?.name}');
  
  await repo.delete('2');
  users = await repo.getAll();
  print('After delete: ${users.length}');
}
\`\`\`

---

### 5.4. Advanced Topics

#### 5.4.1. Isolate & Concurrency

\`\`\`dart
import 'dart:isolate';
import 'dart:async';

// Heavy computation
int fibonacci(int n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

// Run in isolate
Future<int> computeFibonacci(int n) async {
  return await Isolate.run(() => fibonacci(n));
}

// Isolate with communication
void isolateWorker(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  
  receivePort.listen((message) {
    if (message is int) {
      final result = fibonacci(message);
      sendPort.send(result);
    }
  });
}

Future<void> useIsolateWithCommunication() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(isolateWorker, receivePort.sendPort);
  
  final sendPort = await receivePort.first as SendPort;
  
  final responsePort = ReceivePort();
  sendPort.send(35);
  
  receivePort.listen((message) {
    print('Result: $message');
  });
}

void main() async {
  print('Computing fibonacci(40)...');
  final result = await computeFibonacci(40);
  print('Result: $result');
}
\`\`\`

#### 5.4.2. Functional Programming với OOP

\`\`\`dart
// Immutable data class
class User {
  final String name;
  final int age;
  final bool isActive;
  
  const User(this.name, this.age, this.isActive);
  
  User copyWith({String? name, int? age, bool? isActive}) {
    return User(
      name ?? this.name,
      age ?? this.age,
      isActive ?? this.isActive,
    );
  }
}

// Higher-order functions
List<T> filter<T>(List<T> list, bool Function(T) predicate) {
  return list.where(predicate).toList();
}

List<R> map<T, R>(List<T> list, R Function(T) transform) {
  return list.map(transform).toList();
}

R reduce<T, R>(List<T> list, R initial, R Function(R, T) combine) {
  return list.fold(initial, combine);
}

// Function composition
Function compose(Function f, Function g) {
  return (x) => f(g(x));
}

void main() {
  final users = [
    User('An', 25, true),
    User('Bình', 30, false),
    User('Cường', 35, true),
  ];
  
  // Functional operations
  final activeUsers = filter(users, (u) => u.isActive);
  print('Active users: ${activeUsers.length}');
  
  final names = map(users, (u) => u.name);
  print('Names: $names');
  
  final totalAge = reduce(users, 0, (sum, u) => sum + u.age);
  print('Total age: $totalAge');
  
  // Function composition
  final addOne = (int x) => x + 1;
  final double = (int x) => x * 2;
  final addOneThenDouble = compose(double, addOne);
  print(addOneThenDouble(5));  // (5 + 1) * 2 = 12
}
\`\`\`

#### 5.4.3. Performance Optimization

\`\`\`dart
// 1. Const constructors
class Config {
  final String apiUrl;
  final int timeout;
  
  const Config(this.apiUrl, this.timeout);
}

// 2. Immutable objects
class ImmutableUser {
  final String name;
  final int age;
  
  const ImmutableUser(this.name, this.age);
}

// 3. Object pooling
class ObjectPool<T> {
  final List<T> _available = [];
  final T Function() _creator;
  
  ObjectPool(this._creator);
  
  T acquire() {
    if (_available.isEmpty) {
      return _creator();
    }
    return _available.removeLast();
  }
  
  void release(T object) {
    _available.add(object);
  }
}

// 4. Lazy loading
class LazyData {
  String? _data;
  
  String get data {
    _data ??= _loadData();
    return _data!;
  }
  
  String _loadData() {
    print('Loading data...');
    return 'Loaded data';
  }
}

void main() {
  // Const - compile-time constant
  const config1 = Config('https://api.com', 30);
  const config2 = Config('https://api.com', 30);
  print(identical(config1, config2));  // true - same instance
  
  // Object pool
  var pool = ObjectPool<StringBuffer>(() => StringBuffer());
  var buffer = pool.acquire();
  buffer.write('Hello');
  pool.release(buffer);
  
  // Lazy loading
  var lazy = LazyData();
  print('Before access');
  print(lazy.data);  // Loading data... Loaded data
  print(lazy.data);  // Loaded data (no loading)
}
\`\`\`

---

### 5.5. Testing OOP

\`\`\`dart
// user.dart
class User {
  final String id;
  final String name;
  final int age;
  
  User(this.id, this.name, this.age);
  
  bool get isAdult => age >= 18;
  
  User copyWith({String? name, int? age}) {
    return User(id, name ?? this.name, age ?? this.age);
  }
}

// user_repository.dart
abstract class UserRepository {
  Future<User?> getById(String id);
  Future<void> save(User user);
}

// user_service.dart
class UserService {
  final UserRepository repository;
  
  UserService(this.repository);
  
  Future<User?> getUser(String id) async {
    return await repository.getById(id);
  }
  
  Future<bool> canVote(String id) async {
    final user = await repository.getById(id);
    return user?.isAdult ?? false;
  }
}

// user_test.dart (example)
/*
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('User', () {
    test('isAdult returns true for age >= 18', () {
      final user = User('1', 'An', 18);
      expect(user.isAdult, true);
    });
    
    test('isAdult returns false for age < 18', () {
      final user = User('2', 'Bình', 17);
      expect(user.isAdult, false);
    });
    
    test('copyWith updates fields', () {
      final user = User('1', 'An', 25);
      final updated = user.copyWith(age: 26);
      
      expect(updated.id, '1');
      expect(updated.name, 'An');
      expect(updated.age, 26);
    });
  });
  
  group('UserService', () {
    late MockUserRepository mockRepo;
    late UserService service;
    
    setUp(() {
      mockRepo = MockUserRepository();
      service = UserService(mockRepo);
    });
    
    test('canVote returns true for adult user', () async {
      final user = User('1', 'An', 25);
      when(() => mockRepo.getById('1')).thenAnswer((_) async => user);
      
      final result = await service.canVote('1');
      expect(result, true);
      verify(() => mockRepo.getById('1')).called(1);
    });
    
    test('canVote returns false for minor', () async {
      final user = User('2', 'Bình', 15);
      when(() => mockRepo.getById('2')).thenAnswer((_) async => user);
      
      final result = await service.canVote('2');
      expect(result, false);
    });
    
    test('canVote returns false when user not found', () async {
      when(() => mockRepo.getById('3')).thenAnswer((_) async => null);
      
      final result = await service.canVote('3');
      expect(result, false);
    });
  });
}
*/
\`\`\`

---

### 5.6. Dependency Injection

\`\`\`dart
// Using get_it
/*
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Singleton
  getIt.registerSingleton<AppConfig>(AppConfig());
  
  // Lazy singleton
  getIt.registerLazySingleton<Logger>(() => Logger());
  
  // Factory - new instance every time
  getIt.registerFactory<UserRepository>(() => UserRepositoryImpl());
  
  // With dependencies
  getIt.registerFactory<UserService>(
    () => UserService(getIt<UserRepository>()),
  );
}

void main() {
  setupDependencies();
  
  final service = getIt<UserService>();
  final logger = getIt<Logger>();
}
*/

// Manual DI
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();
  
  final Map<Type, dynamic> _services = {};
  
  void register<T>(T service) {
    _services[T] = service;
  }
  
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered');
    }
    return service as T;
  }
}

// Usage
abstract class ApiService {
  Future<String> fetchData();
}

class ApiServiceImpl implements ApiService {
  @override
  Future<String> fetchData() async {
    return 'Data from API';
  }
}

class DataRepository {
  final ApiService apiService;
  
  DataRepository(this.apiService);
  
  Future<String> getData() async {
    return await apiService.fetchData();
  }
}

void main() async {
  final locator = ServiceLocator();
  
  // Register services
  locator.register<ApiService>(ApiServiceImpl());
  locator.register<DataRepository>(
    DataRepository(locator.get<ApiService>()),
  );
  
  // Use services
  final repo = locator.get<DataRepository>();
  final data = await repo.getData();
  print(data);
}
\`\`\`

---

### 5.7. Augmentations (Dart 3.5+)

Tính năng mới cho phép thêm functionality vào existing libraries.

\`\`\`dart
// Original library: user.dart
library user;

class User {
  final String name;
  final int age;
  
  User(this.name, this.age);
}

// Augmentation: user_extensions.dart
/*
augment library 'user.dart';

augment class User {
  // Add new method
  String get displayName => 'User: $name';
  
  // Add new property
  bool get isAdult => age >= 18;
}
*/

// Note: Augmentations syntax có thể thay đổi trong các phiên bản tương lai
\`\`\`

---

### 5.8. Best Practices & Common Pitfalls

#### Best Practices

\`\`\`dart
// 1. Prefer final for immutability
class Good {
  final String name;
  final int age;
  Good(this.name, this.age);
}

// 2. Use const constructors when possible
class Config {
  final String apiUrl;
  const Config(this.apiUrl);
}

// 3. Avoid deep inheritance
// BAD: A -> B -> C -> D -> E
// GOOD: Use composition and mixins

// 4. Keep classes small and focused (SRP)
class UserRepository {
  Future<void> save(User user) async {}
}

class UserValidator {
  bool validate(User user) => true;
}

// 5. Use named parameters for clarity
void createUser({
  required String name,
  required int age,
  String? email,
}) {}

// 6. Prefer composition over inheritance
class Engine {
  void start() {}
}

class Car {
  final Engine engine;
  Car(this.engine);
}

// 7. Use factory constructors for complex creation
class User {
  final String name;
  User._(this.name);
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User._(json['name']);
  }
}

// 8. Make classes immutable when possible
class ImmutablePoint {
  final double x, y;
  const ImmutablePoint(this.x, this.y);
}

// 9. Use sealed classes for exhaustive checking
sealed class Result {}
class Success extends Result {}
class Error extends Result {}

// 10. Leverage extension methods
extension StringExtensions on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
\`\`\`

#### Common Pitfalls

\`\`\`dart
// 1. PITFALL: Mutable collections in const
// BAD
class Bad {
  final List<int> numbers = [1, 2, 3];
  const Bad();  // ERROR - list is not const
}

// GOOD
class Good {
  final List<int> numbers;
  const Good(this.numbers);
}

// 2. PITFALL: Forgetting to override == and hashCode
class User {
  final String id;
  User(this.id);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}

// 3. PITFALL: Not using late for circular dependencies
class A {
  late B b;
}

class B {
  late A a;
}

// 4. PITFALL: Overusing inheritance
// Prefer composition and mixins

// 5. PITFALL: Not handling null safety properly
String? getName() => null;

void bad() {
  // print(getName()!.length); // CRASH if null
}

void good() {
  print(getName()?.length ?? 0);  // Safe
}
\`\`\`

---

## Tổng kết Phần 5

Phần 5 đã cover nâng cao OOP:
- ✅ Effective Dart & Clean Code (naming, immutability, composition)
- ✅ SOLID principles với ví dụ thực tế
- ✅ Design Patterns (Singleton, Factory, Builder, Strategy, Observer, Repository)
- ✅ Advanced topics (Isolates, Functional Programming, Performance)
- ✅ Testing OOP (unit test, mocking)
- ✅ Dependency Injection (get_it, manual DI)
- ✅ Augmentations (Dart 3.5+)
- ✅ Best practices & Common pitfalls

---

## 6. Tài liệu tham khảo & Mẹo thực tế

### 6.1. Tài liệu chính thức

**Dart Language:**
- **dart.dev** - https://dart.dev
  - Language tour: https://dart.dev/language
  - Effective Dart: https://dart.dev/effective-dart
  - Null safety: https://dart.dev/null-safety
  
- **API Documentation** - https://api.dart.dev
  - Core libraries
  - dart:async, dart:collection, dart:convert, dart:io
  
- **Dart SDK** - https://dart.dev/get-dart
  - Download và cài đặt

**Flutter:**
- **flutter.dev** - https://flutter.dev
  - Widget catalog
  - Cookbook
  - API reference: https://api.flutter.dev

**Dart Packages:**
- **pub.dev** - https://pub.dev
  - Tìm và publish packages

### 6.2. Công cụ hỗ trợ

**Code Generation:**
- **freezed** - Immutable classes, unions, copy-with
  ```yaml
  dependencies:
    freezed_annotation: ^2.4.1
  
  dev_dependencies:
    build_runner: ^2.4.6
    freezed: ^2.4.5
  ```

- **json_serializable** - JSON serialization
  ```yaml
  dependencies:
    json_annotation: ^4.8.1
  
  dev_dependencies:
    json_serializable: ^6.7.1
  ```

**State Management:**
- **riverpod** - Modern state management
- **bloc** - Business Logic Component pattern
- **provider** - Simple state management
- **get** - GetX state management

**Dependency Injection:**
- **get_it** - Service locator
- **injectable** - Code generation for get_it

**Testing:**
- **test** - Unit testing framework
- **mocktail** - Mocking library
- **flutter_test** - Widget testing

**Development Tools:**
- **Dart DevTools** - Debugging, profiling, inspector
- **Very Good CLI** - Project templates và tools
  ```bash
  dart pub global activate very_good_cli
  very_good create flutter_app my_app
  ```

- **dart_code_metrics** - Code quality metrics
- **dart fix** - Auto-fix code issues

### 6.3. Mẹo thực tế

**1. Hot Reload & Hot Restart:**
- Hot Reload (r): Giữ state, update UI
- Hot Restart (R): Reset state, reload app

**2. Dart DevTools:**
```bash
dart devtools
flutter pub global activate devtools
```

**3. Code Generation:**
```bash
# Run once
dart run build_runner build

# Watch mode
dart run build_runner watch

# Delete conflicting outputs
dart run build_runner build --delete-conflicting-outputs
```

**4. Linting:**
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_final_fields
    - avoid_print
```

**5. Performance Tips:**
- Dùng `const` constructors
- Avoid rebuilding widgets unnecessarily
- Use `ListView.builder` cho long lists
- Profile với DevTools

**6. Debugging:**
```dart
// Print debugging
print('Debug: $value');
debugPrint('Flutter debug');

// Assert
assert(value != null, 'Value must not be null');

// Breakpoints trong IDE
```

**7. Useful Commands:**
```bash
# Format code
dart format .

# Analyze code
dart analyze

# Run tests
dart test
flutter test

# Get dependencies
dart pub get
flutter pub get

# Upgrade dependencies
dart pub upgrade
flutter pub upgrade

# Clean build
flutter clean
```

### 6.4. Learning Resources

**Books:**
- "Dart Apprentice" - raywenderlich.com
- "Flutter & Dart: The Complete Guide" - Udemy
- "Effective Dart" - dart.dev/effective-dart

**YouTube Channels:**
- Flutter (Official)
- Reso Coder
- The Net Ninja
- Fireship

**Communities:**
- r/FlutterDev (Reddit)
- Flutter Community (Discord)
- Stack Overflow
- GitHub Discussions

**Blogs:**
- medium.com/flutter
- blog.flutter.dev
- dart.dev/blog

---

## Kết luận

Tài liệu này đã cover toàn bộ kiến thức về Dart & OOP từ cơ bản đến nâng cao:

**Phần 1: Giới thiệu** - Tổng quan về Dart và ứng dụng 2026

**Phần 2: Cơ bản ngôn ngữ Dart** - Nền tảng cần thiết
- Biến, kiểu dữ liệu, toán tử
- Control flow, functions, collections
- Import, library, null safety cơ bản

**Phần 3: Cơ bản OOP** - 4 trụ cột OOP
- Class, Object, Constructor
- Properties, Methods
- Inheritance, Polymorphism, Encapsulation, Abstraction

**Phần 4: Trung cấp OOP** - Tính năng nâng cao
- Mixins, Interfaces, Extension methods
- Generics, Null safety toàn diện
- Enhanced Enum, Records, Pattern matching
- Class modifiers (sealed, final, base, interface, mixin)

**Phần 5: Nâng cao OOP** - Best practices & Patterns
- Effective Dart & Clean Code
- SOLID principles
- Design Patterns (Singleton, Factory, Builder, Strategy, Observer, Repository)
- Isolates, Functional Programming, Performance
- Testing, Dependency Injection
- Augmentations, Best practices

**Phần 6: Tài liệu tham khảo** - Resources & Tools
- Official docs, packages, tools
- Mẹo thực tế, commands
- Learning resources

**Chúc bạn thành công với Dart & Flutter! 🎯🚀**

---

*Tài liệu được cập nhật theo Dart 3.x và các tính năng mới nhất đến năm 2026.*
