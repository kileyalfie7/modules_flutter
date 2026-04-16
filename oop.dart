class Device {
  String brand;
  String name;

  Device(this.brand, this.name);

  void powerOn() => print("$brand đang khởi động... $name");
}

class Smartphone extends Device {
  String model;

  Smartphone(String brand, String name, this.model) : super(brand, name);

  void call() => print("Đang gọi điện từ $model...");
}

abstract class Product {
  void describe(); // Hàm trừu tượng (không có thân hàm)
}

class Phone extends Product {
  @override
  void describe() => print("Tôi là một chiếc điện thoại di động.");
}

class Laptop extends Product {
  @override
  void describe() => print("Tôi là một chiếc máy tính xách tay mạnh mẽ.");
}

void showInfo(Product p) {
  p.describe(); // Truyền Phone thì chạy kiểu Phone, truyền Laptop chạy kiểu Laptop
}

void main() {
  var phone = Smartphone("Apple", "name", "iPhone 15");

  phone.powerOn(); // từ class cha
  phone.call(); // từ class con

  showInfo(Phone());
  showInfo(Laptop());


}
