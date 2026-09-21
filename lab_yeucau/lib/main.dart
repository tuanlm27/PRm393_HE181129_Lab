class Vehicle{
  String brand;
  int year;
  Vehicle(this.brand,this.year);

  void startEngine() => print("Khởi động phương tiện...");
}
class Car extends Vehicle{
  bool isElectric;
  Car(String brand, int year, this.isElectric) : super(brand, year);
  Car.tesla(int year) : isElectric = true,super("Tesla", year);

  @override
  void startEngine(){
    if (isElectric) {
      print("$brand ($year) - Xe này là Xe điện");
    } else {
      print("$brand ($year) - Xe này là xe gas");
    }
  }
}
void main(){
  Car GasCar = Car("Honda", 1998, false);
  GasCar.startEngine();

  Car EletricCar = Car.tesla(2026);
  EletricCar.startEngine();
}