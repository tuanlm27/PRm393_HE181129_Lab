import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// -----------------------------------------------------------------------------
// KHỞI TẠO BIẾN TOÀN CỤC CHO LOCAL NOTIFICATION
// -----------------------------------------------------------------------------
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  // Đảm bảo các dịch vụ Flutter Engine đã sẵn sàng trước khi chạy các tác vụ async
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase (Nếu chưa cài file google-services.json thì dùng try-catch để tránh crash app)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Bỏ qua Firebase nếu chưa kết nối cấu hình: $e");
  }

  // Cấu hình cài đặt ban đầu cho Local Notification trên hệ điều hành Android
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10 Full - Auth & Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// =============================================================================
// 1. NOTIFICATION SERVICE (Lab 10.5 - Quản lý hiển thị Thông báo Nội bộ)
// =============================================================================
class NotificationService {
  // Hàm hiển thị thông báo với tiêu đề và nội dung tùy chỉnh
  static Future<void> showNotification({required String title, required String body}) async {
    // Xin quyền hiển thị thông báo đối với thiết bị chạy Android 13 (API level 33+) trở lên
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    // Thiết lập kênh thông báo (Notification Channel) với độ ưu tiên cao nhất
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'auth_channel',
      'Authentication Notifications',
      channelDescription: 'Kênh gửi thông báo khi Đăng nhập / Đăng xuất',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // Kích hoạt hiển thị thông báo lên hệ thống
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

// =============================================================================
// 2. SPLASH SCREEN (Lab 10.3 - Màn hình chờ & Kiểm tra Tự động Đăng nhập)
// =============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi hàm kiểm tra phiên làm việc ngay khi màn hình vừa khởi tạo
    _checkAutoLogin();
  }

  // HÀM QUAN TRỌNG: Kiểm tra Session Token được lưu trong bộ nhớ máy
  Future<void> _checkAutoLogin() async {
    await Future.delayed(const Duration(seconds: 2)); // Tạo độ trễ 2 giây để giả lập hiệu ứng SplashScreen

    // Truy cập vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    final username = prefs.getString('user_name') ?? 'User';

    if (!mounted) return;

    // KIỂM TRA ĐIỀU KIỆN AUTO-LOGIN:
    // Nếu token tồn tại -> Bỏ qua màn hình Login và vào thẳng HomeScreen
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
      );
    } else {
      // Nếu chưa có token -> Đưa người dùng về màn hình Đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_person, size: 80, color: Colors.indigo),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Đang kiểm tra phiên đăng nhập...'),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 3. LOGIN SCREEN (Lab 10.1, 10.2, 10.4 - Xử lý Đăng nhập REST API & Google)
// =============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Tài khoản & Mật khẩu mẫu của DummyJSON REST API (chuẩn theo đề bài)
  final TextEditingController _usernameController =
  TextEditingController(text: 'emilys');
  final TextEditingController _passwordController =
  TextEditingController(text: 'emilyspass');

  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // HÀM 1: Đăng nhập bằng Real REST API POST Request (Lab 10.2)
  // ---------------------------------------------------------------------------
  Future<void> _loginWithApi() async {
    // Validate kiểm tra dữ liệu đầu vào của Form
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Gửi yêu cầu POST tới endpoint xác thực của DummyJSON
      final response = await http.post(
        Uri.parse('https://dummyjson.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      // Xử lý khi Server phản hồi Thành công (HTTP status 200)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['accessToken'] ?? data['token'] ?? 'mock_token_12345';
        String username = data['username'] ?? _usernameController.text;

        // BƯỚC LƯU SESSION (Lab 10.3): Ghi nhớ token và tên người dùng vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);
        await prefs.setString('user_name', username);

        // BƯỚC THÔNG BÁO (Lab 10.5): Phát Local Notification khi đăng nhập thành công
        await NotificationService.showNotification(
          title: 'Đăng nhập thành công! 🎉',
          body: 'Chào mừng $username đã quay trở lại.',
        );

        if (!mounted) return;
        // Điều hướng sang Trang chủ HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
        );
      } else {
        // Xử lý khi nhập sai tài khoản/mật khẩu (HTTP STATUS != 200)
        _showErrorDialog('Tài khoản hoặc mật khẩu không chính xác!');
      }
    } catch (e) {
      // Xử lý khi gặp lỗi mạng / kết nối
      _showErrorDialog('Lỗi kết nối Server: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // HÀM 2: Đăng nhập bằng Google / Firebase Authentication (Lab 10.4)
  // ---------------------------------------------------------------------------
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // Mở Popup chọn tài khoản Google của thiết bị
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // Người dùng ấn Hủy chọn tài khoản
      }

      // Lấy thông tin xác thực từ tài khoản Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase bằng Credential vừa lấy
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      String username = userCredential.user?.displayName ?? 'Google User';

      // Lưu Session vào bộ nhớ máy
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', userCredential.user?.uid ?? 'google_token');
      await prefs.setString('user_name', username);

      // Phát thông báo thành công
      await NotificationService.showNotification(
        title: 'Google Sign-In thành công!',
        body: 'Xin chào $username',
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
      );
    } catch (e) {
      _showErrorDialog('Google Sign-In yêu cầu cấu hình Firebase SHA-1.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // HÀM HIỂN THỊ DIALOG BÁO LỖI VỚI GIAO DIỆN THÂN THIỆN
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi Đăng Nhập'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 10 - Login Screen')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.account_circle, size: 90, color: Colors.indigo),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Vui lòng nhập Username' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Vui lòng nhập Mật khẩu' : null,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _loginWithApi,
                  child: const Text('ĐĂNG NHẬP REST API', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                  label: const Text('Đăng nhập bằng Google'),
                  onPressed: _signInWithGoogle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 4. HOME SCREEN (Trang Chủ & Xử lý Đăng xuất Session Logout - Lab 10.3)
// =============================================================================
class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  // HÀM QUAN TRỌNG: Xử lý Đăng xuất (Logout)
  Future<void> _logout(BuildContext context) async {
    // 1. Xóa sạch Session (Token & Username) lưu trong SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 2. Đăng xuất khỏi Firebase & Google (nếu có)
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (_) {}

    // 3. Hiển thị thông báo Đăng xuất
    await NotificationService.showNotification(
      title: 'Đã đăng xuất',
      body: 'Phiên làm việc của bạn đã kết thúc.',
    );

    if (!context.mounted) return;
    // 4. Đưa người dùng quay trở lại LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Chủ (Home)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              Text(
                'Xin chào, $username!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Bạn đã đăng nhập thành công và Session đã được lưu tự động!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.exit_to_app),
                label: const Text('ĐĂNG XUẤT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}