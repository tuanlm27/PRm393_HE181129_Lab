import 'dart:async';

// Classes for Exercise 1
class Product {
  int id;
  String name;
  double price;

  Product(this.id, this.name, this.price);
}

class ProductRepository {
  final StreamController<Product> _controller = StreamController<Product>.broadcast();
  Future<List<Product>> getAll() async {
    await Future.delayed(Duration(milliseconds: 1000));
    return [
      Product(1, "Laptop", 199.99),
      Product(2, "Mouse", 39.99)
    ];
  }

  Stream<Product> liveAdded() => _controller.stream;

  void addProduct(Product p) {
    _controller.sink.add(p);
  }

  void dispose() => _controller.close();
}

// Classes for Exercise 2
class User {
  String name;
  String mail;

  User(this.name, this.mail);

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        mail = json['email'];
}

class UserRepository {
  Future<List<User>> fetchUsers() async {
    List<Map<String, dynamic>> simulatedJson = [
      {"name": "Name1", "email": "name01@gmail.com"},
      {"name": "Name2", "email": "name02@gmail.com"}
    ];

    await Future.delayed(Duration(milliseconds: 1000));

    return simulatedJson.map((json) => User.fromJson(json)).toList();
  }
}

// Classes for Exercise 5
class Settings {
  static final Settings _instance = Settings._internal();

  Settings._internal();

  factory Settings() {
    return _instance;
  }
}



Future<void> main() async {
  // Exercise 1: Product Model & Repository
  print("--- Products ---");
  var productRepo = ProductRepository();

  productRepo.liveAdded().listen((p) {
    print("Live Update: Added ${p.name} for \$${p.price}");
  });

  var products = await productRepo.getAll();
  print("Initial Products:");
  for (var p in products) {
    print("- ${p.name}");
  }

  productRepo.addProduct(Product(3, "Keyboard", 69.99));

  await Future.delayed(Duration(milliseconds: 100));
  productRepo.dispose();



  // Exercise 2: User Repository with JSON
  print("\n--- JSON Parsing ---");
  var userRepo = UserRepository();
  var users = await userRepo.fetchUsers();

  for (var user in users) {
    print("Parsed User: ${user.name} (${user.mail})");
  }


  // Exercise 3: Async + Microtask Debugging
  print("\n--- event loop debug ---");
  print("1. Sync code executes first");
  Future(() => print("4. Event queue executes last"));

  scheduleMicrotask(() => print("3. Microtask queue executes before the event queue"));
  print("2. Synchronous code finishes");
  await Future.delayed(Duration(milliseconds: 100));


  // Exercise 4: Stream Transformation
  print("\n--- stream operators ---");
  Stream<int> numbers = Stream.fromIterable([1, 2, 3, 4, 5]);

  numbers
      .map((n) => n * n)
      .where((n) => n % 2 == 0)
      .listen((result) {
    print("Filtered Square Result: $result");
  });

  await Future.delayed(Duration(milliseconds: 100));


  // Exercise 5: Factory Constructors & Cache
  print("\n--- factory constructors ---");
  // Requesting two instances
  Settings config1 = Settings();
  Settings config2 = Settings();
  bool isSame = identical(config1, config2);
  print("Are config1 and config2 the same instance? $isSame");
}