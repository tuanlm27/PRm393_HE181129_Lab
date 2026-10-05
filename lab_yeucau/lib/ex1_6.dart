class User {
  int id;
  String name;
  // TODO 1: Khai báo biến email có thể mang giá trị null (nullable variable)
  String? email;

  // Constructor
  User({required this.id, required this.name, this.email});

  // TODO 2: Khai báo factory User.fromJson(Map<String, dynamic> json)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? 'Khách', // Nếu json['name'] bị null thì lấy giá trị mặc định 'Khách'
      email: json['email'],
    );
  }

  void showProfile() {
    // TODO 3: In ra thông tin. Dùng toán tử ?? để xử lý email nếu bị null.
    String emailDisplay = email ?? 'Chưa cập nhật';
    print("ID: $id | Tên: $name | Email: $emailDisplay");
  }
}

void main() {
  // Giả lập dữ liệu JSON trả về từ API
  Map<String, dynamic> rawData1 = {
    "id": 1,
    "name": "Nam",
    "email": "nam@fpt.edu.vn"
  };
  Map<String, dynamic> rawData2 = {
    "id": 2,
    "name": null,
    "email": null
  };

  // TODO 4: Khởi tạo user1 và user2 từ 2 Map trên bằng User.fromJson() và gọi showProfile()
  User user1 = User.fromJson(rawData1);
  User user2 = User.fromJson(rawData2);

  user1.showProfile();
  user2.showProfile();
}