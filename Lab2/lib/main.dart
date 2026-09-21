// function for Exercise 3
void printNormal() {
  print("This is a normal function.");
}

void printArrow() => print("This is an arrow function.");


// Class for Exercise 4
class Car {
  String brand;
  Car(this.brand);
  Car.named(this.brand);

  void drive() {
    print("$brand is driving on gas.");
  }
}

class ElectricCar extends Car {
  ElectricCar(String brand) : super(brand);
  @override
  void drive() {
    print("$brand is driving on the road.");
  }
}

//functions for Exercise 5
Future<void> fetchData() async {
  print("finding...");
  await Future.delayed(Duration(seconds: 1));
  print("Done finding");
}

Stream<int> numberStream() async* {
  yield 1;
  yield 2;
  yield 3;
}





void main() async {
  // Exercise 1: Basic Syntax & Data Types
  int age = 22;
  double gpa = 3.8;
  String studentName = "a name frfr";
  bool isEnrolled = true;

  print("Name: $studentName");
  print("GPA: $gpa, Enrolled: $isEnrolled");
  print("next year i'll be ${age + 1} years old.\n");


  // Exercise 2: Collections & Operators
  List<int> numbers = [10, 20, 30];
  int sum = numbers[0] + numbers[1];
  bool check = (sum == 30) && (numbers.length > 2);
  print("Sum is $sum. Check passed: ${check ? 'Yes' : 'No'}");

  Set<String> items = {"pen", "Notebook"};
  items.add("eraser");
  items.remove("pen");
  print("Set: $items");

  Map<String, int> grades = {"math": 90};
  grades["science"] = 95; // Adding to map
  print("Map: $grades\n");


  // Exercise 3: Control Flow & Functions
  int score = 85;
  if (score >= 50) {
    print("you pass");
  } else {
    print("you failed");
  }

  String today = "monday";
  switch (today) {
    case "friday":
      print("It's friday!");
      break;
    default:
      print("It's a regular day.");
  }

  List<String> food = ["bread", "milk"];

  for (int i = 0; i < food.length; i++) {
    print("For loop: ${food[i]}");
  }

  for (var pet in food) {
    print("For-in loop: $pet");
  }

  food.forEach((pet) => print("forEach loop: $pet"));

  printNormal();
  printArrow();
  print("");

  // Exercise 4: Intro to OOP
  Car myCar = Car("Potota");
  myCar.drive();

  Car secondCar = Car.named("Zonda");
  secondCar.drive();

  ElectricCar myEv = ElectricCar("VinSlow");
  myEv.drive();
  print("");

  // Exercise 5: Async, Future, Null Safety & Streams
  String? nullableString;
  print(nullableString ?? "String was null, using default");

  nullableString = "Hello world";
  print("Length is: ${nullableString?.length}");

  String forcedString = nullableString!;
  print("Forced string: $forcedString");

  await fetchData();

  await for (var number in numberStream()) {
    print("Stream emitted: $number");
  }
}