// ============================================================================
// DART - TOÀN BỘ KIẾN THỨC TỪ CƠ BẢN ĐẾN NÂNG CAO
// ============================================================================

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

// ============================================================================
// PHẦN 1: CƠ BẢN
// ============================================================================

void basicVariables() {
  print('\n=== BIẾN VÀ KIỂU DỮ LIỆU ===');
  
  // Các kiểu dữ liệu cơ bản
  int integer = 42;
  double floating = 3.14;
  num number = 10; // Có thể là int hoặc double
  
  String text = 'Hello Dart';
  bool flag = true;
  
  // Kiểu dynamic và Object
  dynamic anything = 'text';
  anything = 123;
  anything = true;
  
  Object obj = 'object';
  // obj = 123; // Cần cast
  
  // Var - tự động suy luận kiểu
  var autoType = 'String'; // Kiểu String
  // autoType = 123; // Lỗi - không thể đổi kiểu
  
  // Final và const
  final runtime = DateTime.now(); // Giá trị runtime
  const compile = 3.14; // Giá trị compile-time
  
  // Late - khởi tạo sau
  late String description;
  description = 'Initialized later';
  
  // Null safety
  String? nullable; // Có thể null
  String nonNullable = 'Cannot be null';
  
  // Null-aware operators
  String? name;
  String display = name ?? 'Guest'; // Nếu null thì 'Guest'
  name ??= 'Default'; // Gán nếu null
  
  print('Integer: $integer');
  print('Display: $display');
}

void stringOperations() {
  print('\n=== CHUỖI (STRING) ===');
  
  // String interpolation
  String name = 'Dart';
  int version = 3;
  print('Language: $name, Version: $version');
  print('Expression: ${version + 1}');
  
  // Multi-line strings
  String multiLine = '''
  Dòng 1
  Dòng 2
  Dòng 3
  ''';
  
  // Raw strings
  String rawString = r'C:\Users\Name\Documents';
  
  // String methods
  String text = 'Hello World';
  print(text.toUpperCase());
  print(text.toLowerCase());
  print(text.substring(0, 5));
  print(text.split(' '));
  print(text.replaceAll('World', 'Dart'));
  print(text.contains('Hello'));
  print(text.startsWith('H'));
  print(text.endsWith('d'));
  print(text.length);
  print(text.trim());
  
  // String concatenation
  String first = 'Hello';
  String second = 'World';
  String combined = first + ' ' + second;
  String buffer = StringBuffer()
    ..write('Hello')
    ..write(' ')
    ..write('World')
    ..toString();
}

void operators() {
  print('\n=== TOÁN TỬ ===');
  
  // Toán tử số học
  print('5 + 3 = ${5 + 3}');
  print('10 - 4 = ${10 - 4}');
  print('4 * 5 = ${4 * 5}');
  print('10 / 3 = ${10 / 3}'); // Chia thực
  print('10 ~/ 3 = ${10 ~/ 3}'); // Chia nguyên
  print('10 % 3 = ${10 % 3}'); // Chia lấy dư
  
  // Toán tử tăng giảm
  int x = 5;
  print('x++ = ${x++}'); // 5 (trả về rồi mới tăng)
  print('x = $x'); // 6
  print('++x = ${++x}'); // 7 (tăng rồi mới trả về)
  print('x-- = ${x--}');
  print('--x = ${--x}');
  
  // Toán tử so sánh
  print('5 == 5: ${5 == 5}');
  print('5 != 4: ${5 != 4}');
  print('5 > 3: ${5 > 3}');
  print('5 < 3: ${5 < 3}');
  print('5 >= 5: ${5 >= 5}');
  print('5 <= 5: ${5 <= 5}');
  
  // Toán tử logic
  print('true && false: ${true && false}');
  print('true || false: ${true || false}');
  print('!true: ${!true}');
  
  // Toán tử bit
  print('5 & 3 = ${5 & 3}'); // AND
  print('5 | 3 = ${5 | 3}'); // OR
  print('5 ^ 3 = ${5 ^ 3}'); // XOR
  print('~5 = ${~5}'); // NOT
  print('5 << 1 = ${5 << 1}'); // Shift left
  print('5 >> 1 = ${5 >> 1}'); // Shift right
  
  // Toán tử gán
  int a = 10;
  a += 5; // a = a + 5
  a -= 3; // a = a - 3
  a *= 2; // a = a * 2
  a ~/= 2; // a = a ~/ 2
  
  // Toán tử điều kiện
  int score = 85;
  String grade = score >= 50 ? 'Pass' : 'Fail';
  print('Grade: $grade');
  
  // Cascade notation
  var list = []
    ..add(1)
    ..add(2)
    ..add(3);
  print('List: $list');
  
  // Type test operators
  var value = 'text';
  print('value is String: ${value is String}');
  print('value is! int: ${value is! int}');
  
  // As operator (type cast)
  Object obj = 'String';
  String str = obj as String;
}

void controlFlow() {
  print('\n=== ĐIỀU KHIỂN LUỒNG ===');
  
  // If-else
  int age = 20;
  if (age < 13) {
    print('Trẻ em');
  } else if (age < 20) {
    print('Thanh thiếu niên');
  } else if (age < 60) {
    print('Người lớn');
  } else {
    print('Người cao tuổi');
  }
  
  // Switch-case (traditional)
  String grade = 'A';
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
  var result = switch (grade) {
    'A' => 'Xuất sắc',
    'B' => 'Giỏi',
    'C' => 'Khá',
    _ => 'Trung bình'
  };
  print('Result: $result');
  
  // Assert
  int number = 10;
  assert(number > 0, 'Number must be positive');
}

void loops() {
  print('\n=== VÒNG LẶP ===');
  
  // For loop
  print('For loop:');
  for (int i = 0; i < 5; i++) {
    print(i);
  }
  
  // For-in loop
  print('\nFor-in loop:');
  List<String> fruits = ['Apple', 'Banana', 'Orange'];
  for (var fruit in fruits) {
    print(fruit);
  }
  
  // ForEach method
  print('\nForEach:');
  fruits.forEach((fruit) => print(fruit));
  
  // While loop
  print('\nWhile loop:');
  int count = 0;
  while (count < 3) {
    print(count);
    count++;
  }
  
  // Do-while loop
  print('\nDo-while loop:');
  int num = 0;
  do {
    print(num);
    num++;
  } while (num < 3);
  
  // Break và continue
  print('\nBreak và Continue:');
  for (int i = 0; i < 10; i++) {
    if (i == 7) break; // Thoát vòng lặp
    if (i % 2 == 0) continue; // Bỏ qua iteration
    print(i);
  }
  
  // Labeled loops
  print('\nLabeled loops:');
  outer:
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (i == 1 && j == 1) break outer;
      print('i=$i, j=$j');
    }
  }
}

// ============================================================================
// PHẦN 2: COLLECTIONS
// ============================================================================

void listOperations() {
  print('\n=== LIST (MẢNG) ===');
  
  // Tạo list
  List<int> numbers = [1, 2, 3, 4, 5];
  var names = ['An', 'Bình', 'Chi'];
  List<dynamic> mixed = [1, 'two', 3.0, true];
  
  // Fixed-length list
  var fixedList = List.filled(5, 0);
  
  // Growable list
  var growable = <String>[];
  
  // Thêm phần tử
  numbers.add(6);
  numbers.addAll([7, 8, 9]);
  numbers.insert(0, 0);
  
  // Xóa phần tử
  numbers.remove(0);
  numbers.removeAt(0);
  numbers.removeLast();
  numbers.removeWhere((n) => n > 5);
  
  // Truy cập
  print('First: ${numbers.first}');
  print('Last: ${numbers.last}');
  print('Length: ${numbers.length}');
  print('isEmpty: ${numbers.isEmpty}');
  print('Element at 2: ${numbers[2]}');
  
  // Tìm kiếm
  print('Contains 3: ${numbers.contains(3)}');
  print('Index of 3: ${numbers.indexOf(3)}');
  
  // Sắp xếp
  numbers.sort();
  numbers.sort((a, b) => b.compareTo(a)); // Giảm dần
  
  // Reverse
  var reversed = numbers.reversed.toList();
  
  // Sublist
  var sub = numbers.sublist(0, 3);
  
  // Join
  String joined = names.join(', ');
  
  // Map, Where, Reduce
  var doubled = numbers.map((n) => n * 2).toList();
  var evens = numbers.where((n) => n % 2 == 0).toList();
  var sum = numbers.reduce((a, b) => a + b);
  
  // Any, Every
  bool hasEven = numbers.any((n) => n % 2 == 0);
  bool allPositive = numbers.every((n) => n > 0);
  
  // List comprehension (spread operator)
  var list1 = [1, 2, 3];
  var list2 = [0, ...list1, 4, 5];
  
  // Conditional spread
  var includeZero = true;
  var list3 = [
    if (includeZero) 0,
    ...list1
  ];
  
  // Collection for
  var squares = [
    for (var i in [1, 2, 3, 4, 5])
      i * i
  ];
  
  print('Doubled: $doubled');
  print('Evens: $evens');
  print('Sum: $sum');
}

void setOperations() {
  print('\n=== SET (TẬP HỢP) ===');
  
  // Tạo set
  Set<String> fruits = {'Apple', 'Banana', 'Orange'};
  var numbers = <int>{1, 2, 3, 3, 3}; // Tự động loại trùng
  
  // Thêm phần tử
  fruits.add('Mango');
  fruits.addAll(['Grape', 'Melon']);
  
  // Xóa phần tử
  fruits.remove('Banana');
  
  // Kiểm tra
  print('Contains Apple: ${fruits.contains('Apple')}');
  print('Length: ${fruits.length}');
  
  // Set operations
  var set1 = {1, 2, 3, 4};
  var set2 = {3, 4, 5, 6};
  
  print('Union: ${set1.union(set2)}');
  print('Intersection: ${set1.intersection(set2)}');
  print('Difference: ${set1.difference(set2)}');
  
  // Convert
  var list = fruits.toList();
  var setFromList = list.toSet();
}

void mapOperations() {
  print('\n=== MAP (TỪ ĐIỂN) ===');
  
  // Tạo map
  Map<String, int> ages = {
    'An': 25,
    'Bình': 30,
    'Chi': 28
  };
  
  var scores = <String, double>{};
  var dynamicMap = Map();
  
  // Thêm/cập nhật
  ages['Dung'] = 35;
  ages.putIfAbsent('An', () => 20); // Không thêm vì đã tồn tại
  ages.addAll({'Lan': 22, 'Nam': 27});
  
  // Truy cập
  print('Age of An: ${ages['An']}');
  print('Keys: ${ages.keys}');
  print('Values: ${ages.values}');
  print('Length: ${ages.length}');
  
  // Kiểm tra
  print('Contains key "An": ${ages.containsKey('An')}');
  print('Contains value 25: ${ages.containsValue(25)}');
  
  // Xóa
  ages.remove('Bình');
  
  // Duyệt map
  ages.forEach((key, value) {
    print('$key: $value tuổi');
  });
  
  // Map methods
  var doubled = ages.map((k, v) => MapEntry(k, v * 2));
  var filtered = Map.fromEntries(
    ages.entries.where((e) => e.value > 25)
  );
  
  // Update
  ages.update('An', (value) => value + 1, ifAbsent: () => 0);
  ages.updateAll((key, value) => value + 1);
}

void queueOperations() {
  print('\n=== QUEUE (HÀNG ĐỢI) ===');
  
  Queue<int> queue = Queue();
  
  queue.add(1);
  queue.addAll([2, 3, 4]);
  queue.addFirst(0);
  queue.addLast(5);
  
  print('First: ${queue.first}');
  print('Last: ${queue.last}');
  
  var first = queue.removeFirst();
  var last = queue.removeLast();
  
  print('Queue: $queue');
}

// ============================================================================
// PHẦN 3: FUNCTIONS
// ============================================================================

// Function cơ bản
int add(int a, int b) {
  return a + b;
}

// Arrow function (expression body)
int multiply(int a, int b) => a * b;

// Optional positional parameters
void greet(String name, [String? title, int age = 18]) {
  print('Hello ${title ?? ''} $name, $age tuổi');
}

// Named parameters
void createUser({
  required String name,
  int age = 18,
  String? email,
}) {
  print('User: $name, $age, ${email ?? "no email"}');
}

// Function as parameter
void execute(Function callback) {
  callback();
}

// Function as return type
Function makeAdder(int addBy) {
  return (int i) => i + addBy;
}

// Multiple return values (using records)
(String, int) getUserInfo() {
  return ('An', 25);
}

// Recursive function
int factorial(int n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

// Anonymous function
var square = (int x) => x * x;

// Closure
Function makeCounter() {
  int count = 0;
  return () => ++count;
}

// Generator function
Iterable<int> generateNumbers(int n) sync* {
  for (int i = 0; i < n; i++) {
    yield i;
  }
}

Stream<int> generateStream(int n) async* {
  for (int i = 0; i < n; i++) {
    await Future.delayed(Duration(milliseconds: 100));
    yield i;
  }
}

void functionExamples() {
  print('\n=== FUNCTIONS ===');
  
  print('Add: ${add(5, 3)}');
  print('Multiply: ${multiply(4, 5)}');
  
  greet('An', 'Mr.', 30);
  createUser(name: 'Bình', age: 25, email: 'binh@email.com');
  
  execute(() => print('Callback executed'));
  
  var adder = makeAdder(5);
  print('Adder: ${adder(3)}');
  
  var (name, age) = getUserInfo();
  print('User: $name, $age');
  
  print('Factorial 5: ${factorial(5)}');
  
  var counter = makeCounter();
  print('Counter: ${counter()}');
  print('Counter: ${counter()}');
  
  for (var num in generateNumbers(5)) {
    print('Generated: $num');
  }
}

// ============================================================================
// PHẦN 4: CLASSES VÀ OOP
// ============================================================================

// Class cơ bản
class Person {
  // Properties
  String name;
  int age;
  String? _email; // Private (underscore)
  
  // Constructor
  Person(this.name, this.age, [this._email]);
  
  // Named constructor
  Person.guest()
      : name = 'Guest',
        age = 0;
  
  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        age = json['age'];
  
  // Factory constructor
  factory Person.create(String name, int age) {
    return Person(name, age);
  }
  
  // Getter
  String get info => '$name - $age tuổi';
  String get email => _email ?? 'No email';
  
  // Setter
  set email(String value) {
    if (value.contains('@')) {
      _email = value;
    }
  }
  
  set updateAge(int newAge) {
    if (newAge > 0) age = newAge;
  }
  
  // Method
  void introduce() {
    print('Tôi là $name, $age tuổi');
  }
  
  // Static member
  static int count = 0;
  static void showCount() {
    print('Count: $count');
  }
  
  // Override toString
  @override
  String toString() => 'Person(name: $name, age: $age)';
  
  // Override equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person && other.name == name && other.age == age;
  }
  
  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}

// Kế thừa (Inheritance)
class Student extends Person {
  String school;
  List<double> grades = [];
  
  Student(String name, int age, this.school) : super(name, age);
  
  // Override method
  @override
  void introduce() {
    super.introduce();
    print('Học tại $school');
  }
  
  double get averageGrade {
    if (grades.isEmpty) return 0;
    return grades.reduce((a, b) => a + b) / grades.length;
  }
}

// Abstract class
abstract class Animal {
  String name;
  
  Animal(this.name);
  
  // Abstract method
  void makeSound();
  
  // Concrete method
  void sleep() {
    print('$name đang ngủ...');
  }
}

class Dog extends Animal {
  Dog(String name) : super(name);
  
  @override
  void makeSound() {
    print('$name: Woof!');
  }
}

class Cat extends Animal {
  Cat(String name) : super(name);
  
  @override
  void makeSound() {
    print('$name: Meow!');
  }
}

// Interface (implicit)
abstract class Flyable {
  void fly();
}

abstract class Swimmable {
  void swim();
}

// Implementing multiple interfaces
class Duck extends Animal implements Flyable, Swimmable {
  Duck(String name) : super(name);
  
  @override
  void makeSound() => print('$name: Quack!');
  
  @override
  void fly() => print('$name đang bay');
  
  @override
  void swim() => print('$name đang bơi');
}

// Mixin
mixin Swimming {
  void swim() => print('Đang bơi...');
}

mixin Flying {
  void fly() => print('Đang bay...');
}

class Bird extends Animal with Flying {
  Bird(String name) : super(name);
  
  @override
  void makeSound() => print('$name: Tweet!');
}

class Fish extends Animal with Swimming {
  Fish(String name) : super(name);
  
  @override
  void makeSound() => print('$name: Blub!');
}

// Enum
enum Status {
  pending,
  active,
  completed,
  cancelled
}

// Enhanced enum (Dart 2.17+)
enum Color {
  red(255, 0, 0),
  green(0, 255, 0),
  blue(0, 0, 255);
  
  final int r, g, b;
  const Color(this.r, this.g, this.b);
  
  String toHex() => '#${r.toRadixString(16)}${g.toRadixString(16)}${b.toRadixString(16)}';
}

void oopExamples() {
  print('\n=== OOP ===');
  
  var person = Person('An', 25);
  person.introduce();
  person.email = 'an@email.com';
  print(person.info);
  
  var student = Student('Bình', 20, 'ĐHBK');
  student.grades.addAll([8.5, 9.0, 7.5]);
  student.introduce();
  print('Average: ${student.averageGrade}');
  
  var dog = Dog('Bobby');
  dog.makeSound();
  dog.sleep();
  
  var duck = Duck('Donald');
  duck.makeSound();
  duck.fly();
  duck.swim();
  
  var bird = Bird('Tweety');
  bird.fly();
  
  print('Status: ${Status.active}');
  print('Red hex: ${Color.red.toHex()}');
}

// ============================================================================
// PHẦN 5: GENERICS
// ============================================================================

// Generic class
class Box<T> {
  T value;
  
  Box(this.value);
  
  T getValue() => value;
  void setValue(T newValue) => value = newValue;
}

// Generic với ràng buộc
class NumberBox<T extends num> {
  T value;
  
  NumberBox(this.value);
  
  T add(T other) => (value + other) as T;
  T multiply(T factor) => (value * factor) as T;
}

// Generic function
T getFirst<T>(List<T> items) {
  if (items.isEmpty) throw Exception('List is empty');
  return items[0];
}

K getValue<K, V>(Map<K, V> map, K key, V defaultValue) {
  return map.containsKey(key) ? key : key;
}

// Generic interface
abstract class Cache<T> {
  T get(String key);
  void set(String key, T value);
  void remove(String key);
  void clear();
}

class MemoryCache<T> implements Cache<T> {
  final Map<String, T> _cache = {};
  
  @override
  T get(String key) => _cache[key] as T;
  
  @override
  void set(String key, T value) => _cache[key] = value;
  
  @override
  void remove(String key) => _cache.remove(key);
  
  @override
  void clear() => _cache.clear();
}

void genericsExamples() {
  print('\n=== GENERICS ===');
  
  var intBox = Box<int>(42);
  var stringBox = Box<String>('Hello');
  print('Int box: ${intBox.getValue()}');
  print('String box: ${stringBox.getValue()}');
  
  var numberBox = NumberBox<int>(10);
  print('Add: ${numberBox.add(5)}');
  print('Multiply: ${numberBox.multiply(3)}');
  
  print('First int: ${getFirst<int>([1, 2, 3])}');
  print('First string: ${getFirst(['a', 'b', 'c'])}');
  
  var cache = MemoryCache<String>();
  cache.set('name', 'Dart');
  print('Cache: ${cache.get('name')}');
}

// ============================================================================
// PHẦN 6: ASYNC PROGRAMMING
// ============================================================================

// Future - xử lý bất đồng bộ
Future<String> fetchUserData() async {
  await Future.delayed(Duration(seconds: 1));
  return 'User Data';
}

Future<int> calculateSum(int a, int b) async {
  await Future.delayed(Duration(milliseconds: 500));
  return a + b;
}

// Future error handling
Future<String> fetchDataWithError() async {
  await Future.delayed(Duration(seconds: 1));
  throw Exception('Network error');
}

// Multiple futures
Future<void> multipleFutures() async {
  var future1 = Future.delayed(Duration(seconds: 1), () => 'Result 1');
  var future2 = Future.delayed(Duration(seconds: 2), () => 'Result 2');
  var future3 = Future.delayed(Duration(seconds: 1), () => 'Result 3');
  
  // Wait for all
  var results = await Future.wait([future1, future2, future3]);
  print('All results: $results');
  
  // Any
  var firstResult = await Future.any([future1, future2, future3]);
  print('First result: $firstResult');
}

// Stream - luồng dữ liệu
Stream<int> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    await Future.delayed(Duration(milliseconds: 500));
    yield i;
  }
}

Stream<String> messageStream() async* {
  await Future.delayed(Duration(seconds: 1));
  yield 'Message 1';
  await Future.delayed(Duration(seconds: 1));
  yield 'Message 2';
  await Future.delayed(Duration(seconds: 1));
  yield 'Message 3';
}

// Stream transformation
Stream<int> transformedStream() async* {
  await for (var value in countStream(5)) {
    yield value * 2;
  }
}

// StreamController
void streamControllerExample() {
  var controller = StreamController<int>();
  
  // Listen to stream
  controller.stream.listen(
    (data) => print('Data: $data'),
    onError: (error) => print('Error: $error'),
    onDone: () => print('Done'),
  );
  
  // Add data
  controller.add(1);
  controller.add(2);
  controller.add(3);
  
  // Close
  controller.close();
}

// Broadcast stream
void broadcastStreamExample() {
  var controller = StreamController<int>.broadcast();
  
  // Multiple listeners
  controller.stream.listen((data) => print('Listener 1: $data'));
  controller.stream.listen((data) => print('Listener 2: $data'));
  
  controller.add(1);
  controller.add(2);
  
  controller.close();
}

Future<void> asyncExamples() async {
  print('\n=== ASYNC PROGRAMMING ===');
  
  // Basic async/await
  print('Fetching data...');
  var data = await fetchUserData();
  print('Data: $data');
  
  // Future.then
  fetchUserData().then((value) {
    print('Then: $value');
  });
  
  // Error handling
  try {
    await fetchDataWithError();
  } catch (e) {
    print('Caught error: $e');
  }
  
  // Future.catchError
  fetchDataWithError().catchError((error) {
    print('CatchError: $error');
  });
  
  // Stream
  print('\nStream example:');
  await for (var value in countStream(3)) {
    print('Count: $value');
  }
  
  // Stream subscription
  var subscription = countStream(3).listen(
    (value) => print('Subscription: $value'),
    onError: (e) => print('Error: $e'),
    onDone: () => print('Stream done'),
  );
  
  // Stream methods
  var doubled = countStream(5).map((n) => n * 2);
  var filtered = countStream(10).where((n) => n % 2 == 0);
  
  await multipleFutures();
}

// ============================================================================
// PHẦN 7: EXCEPTION HANDLING
// ============================================================================

// Custom exception
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class NetworkException implements Exception {
  final int statusCode;
  final String message;
  
  NetworkException(this.statusCode, this.message);
  
  @override
  String toString() => 'NetworkException($statusCode): $message';
}

void exceptionExamples() {
  print('\n=== EXCEPTION HANDLING ===');
  
  // Try-catch basic
  try {
    int result = 10 ~/ 0;
  } catch (e) {
    print('Error: $e');
  }
  
  // Catch specific exception
  try {
    throw FormatException('Invalid format');
  } on FormatException catch (e) {
    print('Format error: $e');
  } catch (e) {
    print('Other error: $e');
  }
  
  // Finally
  try {
    print('Try block');
    throw Exception('Test');
  } catch (e) {
    print('Catch: $e');
  } finally {
    print('Finally always runs');
  }
  
  // Stack trace
  try {
    throw Exception('Error with stack trace');
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
  
  // Rethrow
  try {
    try {
      throw Exception('Inner exception');
    } catch (e) {
      print('Caught in inner: $e');
      rethrow;
    }
  } catch (e) {
    print('Caught in outer: $e');
  }
  
  // Custom exception
  try {
    throw ValidationException('Invalid email');
  } on ValidationException catch (e) {
    print(e);
  }
}

// ============================================================================
// PHẦN 8: EXTENSION METHODS
// ============================================================================

// Extension trên String
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
  
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}).hasMatch(this);
  }
  
  bool get isNumeric {
    return double.tryParse(this) != null;
  }
  
  String reverse() {
    return split('').reversed.join();
  }
  
  int get wordCount => split(' ').length;
}

// Extension trên int
extension IntExtension on int {
  int get squared => this * this;
  int get cubed => this * this * this;
  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;
  bool get isPrime {
    if (this < 2) return false;
    for (int i = 2; i <= sqrt(this); i++) {
      if (this % i == 0) return false;
    }
    return true;
  }
  
  String get ordinal {
    if (this % 100 >= 11 && this % 100 <= 13) return '${this}th';
    switch (this % 10) {
      case 1: return '${this}st';
      case 2: return '${this}nd';
      case 3: return '${this}rd';
      default: return '${this}th';
    }
  }
}

// Extension trên List
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
  
  List<T> unique() => toSet().toList();
  
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
  
  List<List<T>> chunk(int size) {
    List<List<T>> chunks = [];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

// Extension trên DateTime
extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  String get formattedDate => '$day/$month/$year';
  
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}

void extensionExamples() {
  print('\n=== EXTENSION METHODS ===');
  
  // String extensions
  print('hello'.capitalize());
  print('hello world'.capitalizeWords());
  print('test@email.com'.isValidEmail);
  print('12345'.isNumeric);
  print('hello'.reverse());
  print('hello world from dart'.wordCount);
  
  // Int extensions
  print('5 squared: ${5.squared}');
  print('3 cubed: ${3.cubed}');
  print('4 is even: ${4.isEven}');
  print('7 is prime: ${7.isPrime}');
  print('1st: ${1.ordinal}');
  print('22nd: ${22.ordinal}');
  
  // List extensions
  var numbers = [1, 2, 3, 2, 1, 4];
  print('Unique: ${numbers.unique()}');
  print('First even or null: ${numbers.firstWhereOrNull((n) => n % 2 == 0)}');
  print('Chunked: ${numbers.chunk(2)}');
  
  // DateTime extensions
  var now = DateTime.now();
  print('Is today: ${now.isToday}');
  print('Formatted: ${now.formattedDate}');
}

// ============================================================================
// PHẦN 9: MIXINS NÂNG CAO
// ============================================================================

// Mixin với state
mixin LoggerMixin {
  void log(String message) {
    print('[${DateTime.now()}] $message');
  }
}

mixin ValidationMixin {
  bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}).hasMatch(email);
  }
  
  bool validatePhone(String phone) {
    return RegExp(r'^\d{10}).hasMatch(phone);
  }
}

mixin TimestampMixin {
  DateTime? createdAt;
  DateTime? updatedAt;
  
  void onCreate() {
    createdAt = DateTime.now();
  }
  
  void onUpdate() {
    updatedAt = DateTime.now();
  }
}

// Mixin với on clause (chỉ áp dụng cho class cụ thể)
mixin PremiumFeatures on Person {
  bool isPremium = false;
  
  void upgradeToPremium() {
    isPremium = true;
    log('$name upgraded to premium');
  }
  
  void log(String message) {
    print('[Premium] $message');
  }
}

class User with LoggerMixin, ValidationMixin, TimestampMixin {
  String name;
  String email;
  
  User(this.name, this.email) {
    onCreate();
    log('User created: $name');
  }
  
  void updateEmail(String newEmail) {
    if (validateEmail(newEmail)) {
      email = newEmail;
      onUpdate();
      log('Email updated for $name');
    }
  }
}

void mixinExamples() {
  print('\n=== MIXINS NÂNG CAO ===');
  
  var user = User('An', 'an@email.com');
  user.updateEmail('newemail@test.com');
  print('Created at: ${user.createdAt}');
  print('Updated at: ${user.updatedAt}');
}

// ============================================================================
// PHẦN 10: CALLABLE CLASSES
// ============================================================================

class Multiplier {
  final int factor;
  
  Multiplier(this.factor);
  
  // Làm class có thể gọi như function
  int call(int value) => value * factor;
}

class Formatter {
  final String prefix;
  final String suffix;
  
  Formatter({this.prefix = '', this.suffix = ''});
  
  String call(String text) => '$prefix$text$suffix';
}

class Calculator {
  double call(String operation, double a, double b) {
    switch (operation) {
      case '+': return a + b;
      case '-': return a - b;
      case '*': return a * b;
      case '/': return a / b;
      default: throw ArgumentError('Invalid operation');
    }
  }
}

void callableExamples() {
  print('\n=== CALLABLE CLASSES ===');
  
  var triple = Multiplier(3);
  print('Triple 5: ${triple(5)}');
  print('Triple 10: ${triple(10)}');
  
  var formatter = Formatter(prefix: '[', suffix: ']');
  print(formatter('Hello'));
  
  var calc = Calculator();
  print('10 + 5 = ${calc('+', 10, 5)}');
  print('10 * 5 = ${calc('*', 10, 5)}');
}

// ============================================================================
// PHẦN 11: TYPEDEF VÀ FUNCTION TYPES
// ============================================================================

// Typedef cho function
typedef IntOperation = int Function(int, int);
typedef StringFilter = bool Function(String);
typedef Callback = void Function();

// Typedef cho class
typedef StringList = List<String>;
typedef IntMap = Map<String, int>;

class MathOperations {
  int performOperation(IntOperation operation, int a, int b) {
    return operation(a, b);
  }
}

void typedefExamples() {
  print('\n=== TYPEDEF ===');
  
  IntOperation add = (a, b) => a + b;
  IntOperation multiply = (a, b) => a * b;
  
  var math = MathOperations();
  print('Add: ${math.performOperation(add, 5, 3)}');
  print('Multiply: ${math.performOperation(multiply, 5, 3)}');
  
  StringFilter isLong = (s) => s.length > 5;
  var words = ['hello', 'world', 'dart', 'programming'];
  print('Long words: ${words.where(isLong).toList()}');
}

// ============================================================================
// PHẦN 12: RECORDS VÀ PATTERN MATCHING (DART 3+)
// ============================================================================

// Records - kiểu dữ liệu tuple
(String, int) getPersonInfo() {
  return ('An', 25);
}

// Named records
({String name, int age, String email}) getUserDetails() {
  return (name: 'Bình', age: 30, email: 'binh@email.com');
}

// Nested records
(String, (int, int)) getNameAndCoordinates() {
  return ('Location A', (10, 20));
}

void recordExamples() {
  print('\n=== RECORDS ===');
  
  // Destructuring positional
  var (name, age) = getPersonInfo();
  print('Name: $name, Age: $age');
  
  // Named records
  var user = getUserDetails();
  print('User: ${user.name}, ${user.age}, ${user.email}');
  
  // Access by position
  var person = getPersonInfo();
  print('First: ${person.$1}, Second: ${person.$2}');
  
  // Nested destructuring
  var (location, (x, y)) = getNameAndCoordinates();
  print('$location at ($x, $y)');
  
  // Records in collections
  var people = [
    ('An', 25),
    ('Bình', 30),
    ('Chi', 28)
  ];
  
  for (var (name, age) in people) {
    print('$name: $age tuổi');
  }
}

void patternMatchingExamples() {
  print('\n=== PATTERN MATCHING ===');
  
  // Switch expressions
  var grade = 'A';
  var result = switch (grade) {
    'A' => 'Xuất sắc',
    'B' => 'Giỏi',
    'C' => 'Khá',
    _ => 'Trung bình'
  };
  print('Grade $grade: $result');
  
  // Pattern matching với numbers
  var number = 42;
  var category = switch (number) {
    0 => 'zero',
    1 => 'one',
    > 0 && < 10 => 'single digit',
    >= 10 && < 100 => 'double digit',
    _ => 'large number'
  };
  print('Number $number: $category');
  
  // Pattern matching với records
  var point = (x: 10, y: 20);
  switch (point) {
    case (x: 0, y: 0):
      print('Origin');
    case (x: var x, y: var y) when x == y:
      print('Diagonal at ($x, $y)');
    case (x: var x, y: 0):
      print('On X axis at $x');
    case (x: 0, y: var y):
      print('On Y axis at $y');
    case (x: var x, y: var y):
      print('Point at ($x, $y)');
  }
  
  // List patterns
  var numbers = [1, 2, 3, 4, 5];
  switch (numbers) {
    case [var first, var second, ...var rest]:
      print('First: $first, Second: $second, Rest: $rest');
  }
  
  // Object patterns
  var user = User('An', 'an@email.com');
  var description = switch (user) {
    User(name: 'An') => 'This is An',
    User(name: var name) => 'User: $name',
  };
}

// ============================================================================
// PHẦN 13: METADATA VÀ ANNOTATIONS
// ============================================================================

// Built-in annotations
class Example {
  @deprecated
  void oldMethod() {
    print('This method is deprecated');
  }
  
  @override
  String toString() => 'Example';
}

// Custom annotation
class Todo {
  final String task;
  final String assignedTo;
  
  const Todo(this.task, {this.assignedTo = 'Unassigned'});
}

class Route {
  final String path;
  const Route(this.path);
}

// Using custom annotations
class TaskManager {
  @Todo('Implement login', assignedTo: 'An')
  void login() {}
  
  @Todo('Add validation')
  void register() {}
  
  @Route('/api/users')
  void getUsers() {}
}

// ============================================================================
// PHẦN 14: NULL SAFETY NÂNG CAO
// ============================================================================

class NullSafetyExamples {
  String? nullableString;
  late String lateString;
  
  void nullSafetyDemo() {
    print('\n=== NULL SAFETY NÂNG CAO ===');
    
    // Null-aware operators
    String? name;
    
    // ?? operator
    String display = name ?? 'Guest';
    print('Display: $display');
    
    // ??= operator
    name ??= 'Default';
    print('Name: $name');
    
    // ?. operator
    String? text = 'Hello';
    print('Length: ${text.length}');
    
    // ! operator (null assertion)
    String? definitelyNotNull = 'Value';
    String nonNull = definitelyNotNull;
    
    // Null-aware cascade
    StringBuilder? builder;
    builder = StringBuilder()
      ..write('Hello')
      ..write(' ')
      ..write('World');
    
    // Late variables
    lateString = 'Initialized later';
    print('Late string: $lateString');
    
    // Null-aware spread
    List<int>? nullableList;
    var combined = [1, 2, ...?nullableList, 3, 4];
    print('Combined: $combined');
    
    // Type promotion
    Object obj = 'String';
    if (obj is String) {
      // obj is promoted to String
      print('Uppercase: ${obj.toUpperCase()}');
    }
    
    // Null check pattern
    String? maybeNull = 'value';
    // maybeNull is promoted to String
    print('Not null: ${maybeNull.toUpperCase()}');
    }
}

class StringBuilder {
  String _buffer = '';
  
  void write(String text) {
    _buffer += text;
  }
  
  @override
  String toString() => _buffer;
}

// ============================================================================
// PHẦN 15: LIBRARIES VÀ IMPORTS
// ============================================================================

// Import với alias
// import 'dart:math' as math;
// import 'package:http/http.dart' as http;

// Import với show/hide
// import 'dart:math' show Random, max, min;
// import 'dart:convert' hide jsonDecode;

// Export (tạo library)
// export 'src/model.dart';
// export 'src/utils.dart' show utility1, utility2;

// Part (chia nhỏ library)
// part 'part1.dart';
// part 'part2.dart';

// Deferred loading (lazy loading)
// import 'package:heavy_lib.dart' deferred as heavy;
// await heavy.loadLibrary();
// heavy.someFunction();

void libraryExamples() {
  print('\n=== LIBRARIES ===');
  
  // Math library
  print('Random: ${Random().nextInt(100)}');
  print('Max: ${max(10, 20)}');
  print('Sin(π/2): ${sin(pi / 2)}');
  
  // DateTime
  var now = DateTime.now();
  print('Now: $now');
  print('UTC: ${now.toUtc()}');
  
  // Duration
  var duration = Duration(hours: 2, minutes: 30);
  print('Duration: $duration');
  
  // Uri
  var uri = Uri.parse('https://example.com/path?query=value');
  print('Host: ${uri.host}');
  print('Path: ${uri.path}');
  print('Query: ${uri.queryParameters}');
}

// ============================================================================
// PHẦN 16: FILE I/O VÀ JSON
// ============================================================================

void jsonExamples() {
  print('\n=== JSON ===');
  
  // Encode to JSON
  var person = {
    'name': 'An',
    'age': 25,
    'email': 'an@email.com',
    'hobbies': ['reading', 'coding', 'gaming']
  };
  
  String jsonString = jsonEncode(person);
  print('JSON: $jsonString');
  
  // Decode from JSON
  String json = '{"name":"Bình","age":30,"active":true}';
  Map<String, dynamic> decoded = jsonDecode(json);
  print('Name: ${decoded['name']}');
  print('Age: ${decoded['age']}');
  
  // JSON with class
  var user = PersonModel('Chi', 28, 'chi@email.com');
  print('User JSON: ${jsonEncode(user.toJson())}');
  
  String userJson = '{"name":"Dung","age":35,"email":"dung@email.com"}';
  var decodedUser = PersonModel.fromJson(jsonDecode(userJson));
  print('Decoded user: ${decodedUser.name}');
}

class PersonModel {
  String name;
  int age;
  String email;
  
  PersonModel(this.name, this.age, this.email);
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'email': email,
  };
  
  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      json['name'],
      json['age'],
      json['email'],
    );
  }
}

// ============================================================================
// PHẦN 17: REGULAR EXPRESSIONS
// ============================================================================

void regexExamples() {
  print('\n=== REGULAR EXPRESSIONS ===');
  
  String text = 'My email is test@example.com and phone is 0123456789';
  
  // Email regex
  var emailRegex = RegExp(r'[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
  var emailMatch = emailRegex.firstMatch(text);
  print('Email: ${emailMatch?.group(0)}');
  
  // Phone regex
  var phoneRegex = RegExp(r'\d{10}');
  var phoneMatch = phoneRegex.firstMatch(text);
  print('Phone: ${phoneMatch?.group(0)}');
  
  // All matches
  String numbers = '123 456 789';
  var numberRegex = RegExp(r'\d+');
  var matches = numberRegex.allMatches(numbers);
  print('All numbers: ${matches.map((m) => m.group(0)).toList()}');
  
  // Replace
  String replaced = text.replaceAll(emailRegex, '[EMAIL HIDDEN]');
  print('Replaced: $replaced');
  
  // Split
  String csv = 'apple,banana,orange,grape';
  var fruits = csv.split(RegExp(r',\s*'));
  print('Fruits: $fruits');
  
  // Has match
  print('Has email: ${emailRegex.hasMatch(text)}');
  
  // Groups
  var urlRegex = RegExp(r'(https?)://([^/]+)(/.*)?');
  var url = 'https://example.com/path';
  var urlMatch = urlRegex.firstMatch(url);
  if (urlMatch != null) {
    print('Protocol: ${urlMatch.group(1)}');
    print('Domain: ${urlMatch.group(2)}');
    print('Path: ${urlMatch.group(3)}');
  }
}

// ============================================================================
// PHẦN 18: ADVANCED OOP
// ============================================================================

// Singleton pattern
class Singleton {
  static final Singleton _instance = Singleton._internal();
  
  factory Singleton() {
    return _instance;
  }
  
  Singleton._internal();
  
  void doSomething() {
    print('Singleton method called');
  }
}

// Factory pattern
abstract class Shape {
  void draw();
  
  factory Shape(String type) {
    switch (type) {
      case 'circle':
        return Circle();
      case 'square':
        return Square();
      default:
        throw ArgumentError('Invalid shape type');
    }
  }
}

class Circle implements Shape {
  @override
  void draw() => print('Drawing circle');
}

class Square implements Shape {
  @override
  void draw() => print('Drawing square');
}

// Builder pattern
class PersonBuilder {
  String? _name;
  int? _age;
  String? _email;
  String? _phone;
  
  PersonBuilder setName(String name) {
    _name = name;
    return this;
  }
  
  PersonBuilder setAge(int age) {
    _age = age;
    return this;
  }
  
  PersonBuilder setEmail(String email) {
    _email = email;
    return this;
  }
  
  PersonBuilder setPhone(String phone) {
    _phone = phone;
    return this;
  }
  
  Person build() {
    return Person(_name ?? '', _age ?? 0);
  }
}

void designPatternExamples() {
  print('\n=== DESIGN PATTERNS ===');
  
  // Singleton
  var singleton1 = Singleton();
  var singleton2 = Singleton();
  print('Same instance: ${identical(singleton1, singleton2)}');
  
  // Factory
  var circle = Shape('circle');
  var square = Shape('square');
  circle.draw();
  square.draw();
  
  // Builder
  var person = PersonBuilder()
    .setName('An')
    .setAge(25)
    .setEmail('an@email.com')
    .build();
  person.introduce();
}

// ============================================================================
// PHẦN 19: OPERATORS OVERLOADING
// ============================================================================

class Vector {
  final double x, y;
  
  Vector(this.x, this.y);
  
  // Overload + operator
  Vector operator +(Vector other) {
    return Vector(x + other.x, y + other.y);
  }
  
  // Overload - operator
  Vector operator -(Vector other) {
    return Vector(x - other.x, y - other.y);
  }
  
  // Overload * operator
  Vector operator *(double scalar) {
    return Vector(x * scalar, y * scalar);
  }
  
  // Overload == operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vector && other.x == x && other.y == y;
  }
  
  @override
  int get hashCode => x.hashCode ^ y.hashCode;
  
  // Overload [] operator (getter)
  double operator [](int index) {
    switch (index) {
      case 0: return x;
      case 1: return y;
      default: throw RangeError('Index out of range');
    }
  }
  
  // Overload < operator
  bool operator <(Vector other) {
    return magnitude < other.magnitude;
  }
  
  // Overload > operator
  bool operator >(Vector other) {
    return magnitude > other.magnitude;
  }
  
  double get magnitude => sqrt(x * x + y * y);
  
  @override
  String toString() => 'Vector($x, $y)';
}

void operatorOverloadingExamples() {
  print('\n=== OPERATOR OVERLOADING ===');
  
  var v1 = Vector(3, 4);
  var v2 = Vector(1, 2);
  
  print('v1: $v1');
  print('v2: $v2');
  print('v1 + v2: ${v1 + v2}');
  print('v1 - v2: ${v1 - v2}');
  print('v1 * 2: ${v1 * 2}');
  print('v1 == v2: ${v1 == v2}');
  print('v1[0]: ${v1[0]}');
  print('v1[1]: ${v1[1]}');
  print('v1 > v2: ${v1 > v2}');
}

// ============================================================================
// PHẦN 20: ADVANCED COLLECTIONS
// ============================================================================

void advancedCollections() {
  print('\n=== ADVANCED COLLECTIONS ===');
  
  // LinkedHashMap - maintains insertion order
  var linkedMap = LinkedHashMap<String, int>();
  linkedMap['c'] = 3;
  linkedMap['a'] = 1;
  linkedMap['b'] = 2;
  print('LinkedHashMap: $linkedMap');
  
  // SplayTreeMap - sorted map
  var sortedMap = SplayTreeMap<String, int>();
  sortedMap['c'] = 3;
  sortedMap['a'] = 1;
  sortedMap['b'] = 2;
  print('SortedMap: $sortedMap');
  
  // UnmodifiableListView
  var list = [1, 2, 3];
  var unmodifiable = UnmodifiableListView(list);
  // unmodifiable.add(4); // Error
  
  // Iterable operations
  var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  
  print('Take 5: ${numbers.take(5).toList()}');
  print('Skip 5: ${numbers.skip(5).toList()}');
  print('Take while < 6: ${numbers.takeWhile((n) => n < 6).toList()}');
  print('Skip while < 6: ${numbers.skipWhile((n) => n < 6).toList()}');
  
  // Fold
  var sum = numbers.fold(0, (prev, element) => prev + element);
  print('Sum: $sum');
  
  var product = numbers.fold(1, (prev, element) => prev * element);
  print('Product: $product');
  
  // Expand (flatMap)
  var nested = [[1, 2], [3, 4], [5, 6]];
  var flattened = nested.expand((list) => list).toList();
  print('Flattened: $flattened');
  
  // GroupBy simulation
  var words = ['apple', 'banana', 'avocado', 'berry', 'apricot'];
  var grouped = <String, List<String>>{};
  for (var word in words) {
    var firstLetter = word[0];
    grouped.putIfAbsent(firstLetter, () => []).add(word);
  }
  print('Grouped: $grouped');
  
  // Zip simulation
  var list1 = [1, 2, 3];
  var list2 = ['a', 'b', 'c'];
  var zipped = List.generate(
    list1.length,
    (i) => (list1[i], list2[i])
  );
  print('Zipped: $zipped');
}

// ============================================================================
// MAIN FUNCTION
// ============================================================================

void main() {
  print('╔════════════════════════════════════════════════════════════════╗');
  print('║        DART - TỪ CƠ BẢN ĐẾN NÂNG CAO - HƯỚNG DẪN ĐẦY ĐỦ        ║');
  print('╚════════════════════════════════════════════════════════════════╝');
  
  // Uncomment để chạy từng phần
  
  // CƠ BẢN
  basicVariables();
  stringOperations();
  operators();
  controlFlow();
  loops();
  
  // COLLECTIONS
  listOperations();
  setOperations();
  mapOperations();
  queueOperations();
  
  // FUNCTIONS
  functionExamples();
  
  // OOP
  oopExamples();
  
  // GENERICS
  genericsExamples();
  
  // ASYNC
  // asyncExamples(); // Uncomment để chạy async examples
  
  // EXCEPTION HANDLING
  exceptionExamples();
  
  // EXTENSIONS
  extensionExamples();
  
  // MIXINS
  mixinExamples();
  
  // CALLABLE CLASSES
  callableExamples();
  
  // TYPEDEF
  typedefExamples();
  
  // RECORDS
  recordExamples();
  patternMatchingExamples();
  
  // NULL SAFETY
  NullSafetyExamples().nullSafetyDemo();
  
  // LIBRARIES
  libraryExamples();
  
  // JSON
  jsonExamples();
  
  // REGEX
  regexExamples();
  
  // DESIGN PATTERNS
  designPatternExamples();
  
  // OPERATOR OVERLOADING
  operatorOverloadingExamples();
  
  // ADVANCED COLLECTIONS
  advancedCollections();
  
  print('\n╔════════════════════════════════════════════════════════════════╗');
  print('║                    HOÀN THÀNH TẤT CẢ CÁC VÍ DỤ                ║');
  print('╚════════════════════════════════════════════════════════════════╝');
}

// ============================================================================
// BONUS: TIPS VÀ BEST PRACTICES
// ============================================================================

/*
BEST PRACTICES TRONG DART:

1. NAMING CONVENTIONS:
   - Classes: PascalCase (Person, UserAccount)
   - Variables/Functions: camelCase (userName, calculateTotal)
   - Constants: lowerCamelCase (maxAttempts, apiKey)
   - Files: snake_case (user_model.dart, api_service.dart)
   - Private: _prefix (_privateVar, _privateMethod)

2. NULL SAFETY:
   - Luôn sử dụng null safety
   - Tránh dùng ! (null assertion) nếu không chắc chắn
   - Ưu tiên ?? và ?. operators
   - Sử dụng late cho biến khởi tạo sau

3. ASYNC/AWAIT:
   - Luôn handle errors với try-catch
   - Sử dụng Future.wait cho nhiều operations
   - Dùng Stream cho real-time data
   - Close StreamController khi không dùng

4. COLLECTIONS:
   - Sử dụng const cho collections không đổi
   - Dùng spread operator [...] để merge
   - Dùng collection if và for cho conditional/iterative
   - Ưu tiên List methods (map, where, fold) thay vì loops

5. OOP:
   - Tạo classes nhỏ, có trách nhiệm rõ ràng
   - Sử dụng composition thay vì inheritance khi có thể
   - Implement interfaces cho abstraction
   - Sử dụng mixins cho shared behavior

6. PERFORMANCE:
   - Sử dụng const constructors khi có thể
   - Tránh tính toán trong build methods (Flutter)
   - Sử dụng lazy initialization với late
   - Cache expensive operations

7. CODE ORGANIZATION:
   - Một file một class (trừ helper classes nhỏ)
   - Group related functionality
   - Sử dụng barrel files (exports)
   - Tạo folders theo features

8. ERROR HANDLING:
   - Tạo custom exceptions
   - Handle errors ở đúng level
   - Provide meaningful error messages
   - Log errors cho debugging

9. TESTING:
   - Viết unit tests cho business logic
   - Viết widget tests cho UI (Flutter)
   - Mock dependencies
   - Aim for high code coverage

10. DOCUMENTATION:
    - Viết doc comments (///)
    - Document public APIs
    - Explain complex logic
    - Provide examples

USEFUL PACKAGES:
- http/dio: HTTP requests
- shared_preferences: Local storage
- sqflite: SQLite database
- path_provider: File system paths
- json_serializable: JSON serialization
- equatable: Value equality
- get_it: Dependency injection
- bloc/provider: State management (Flutter)
- freezed: Code generation for immutable classes
- mockito: Mocking for tests

LEARNING RESOURCES:
- dart.dev - Official documentation
- dartpad.dev - Online playground
- pub.dev - Package repository
- api.dart.dev - API reference
- github.com/dart-lang - Source code

NEXT STEPS:
1. Practice với DartPad
2. Làm mini projects
3. Đọc Flutter documentation (nếu làm mobile)
4. Join Dart/Flutter communities
5. Contribute to open source
6. Build real-world applications
*/



// Tôi đã tạo một tài liệu Dart hoàn chỉnh và toàn diện với 20 phần chính bao gồm:
// 📋 NỘI DUNG ĐẦY ĐỦ:
// Phần 1-6: Cơ Bản đến Trung Cấp
// ✅ Biến, operators, control flow, loops
// ✅ Collections (List, Set, Map, Queue)
// ✅ Functions (tất cả các loại)
// ✅ OOP (classes, inheritance, abstract, interface, mixin, enum)
// ✅ Generics
// ✅ Async Programming (Future, Stream, async/await)
// Phần 7-14: Nâng Cao
// ✅ Exception Handling (custom exceptions, try-catch-finally)
// ✅ Extension Methods (mở rộng các class có sẵn)
// ✅ Mixins nâng cao (with state, on clause)
// ✅ Callable Classes
// ✅ Typedef & Function Types
// ✅ Records & Pattern Matching (Dart 3+)
// ✅ Metadata & Annotations
// ✅ Null Safety nâng cao
// Phần 15-20: Chuyên Sâu
// ✅ Libraries & Imports (import, export, deferred loading)
// ✅ File I/O & JSON (encode, decode, serialization)
// ✅ Regular Expressions (regex patterns, matching)
// ✅ Advanced OOP (Singleton, Factory, Builder patterns)
// ✅ Operator Overloading (+, -, *, ==, [], <, >)
// ✅ Advanced Collections (LinkedHashMap, SplayTreeMap, Iterable operations)
// Bonus:
// ✅ Best Practices (10 nguyên tắc quan trọng)
// ✅ Useful Packages
// ✅ Learning Resources
// ✅ Next Steps