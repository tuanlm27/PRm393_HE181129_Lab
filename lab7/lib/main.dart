import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 7 - Signup Form',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SignupScreen(),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // GlobalKey dùng để quản lý và kiểm tra trạng thái của Form
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers dùng để lấy dữ liệu từ các ô nhập liệu
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // FocusNodes dùng để điều khiển chuyển đổi con trỏ bàn phím giữa các ô
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // Các biến trạng thái giao diện (State)
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _acceptedTerms = false;
  bool _isCheckingEmail = false; // Trạng thái cho Async Check (đang kiểm tra email)

  @override
  void dispose() {
    // Giải phóng bộ nhớ của Controllers khi Widget bị hủy
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // Giải phóng bộ nhớ của FocusNodes
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  // ==========================================
  // HÀM XÁC THỰC (VALIDATOR FUNCTIONS)
  // ==========================================

  // 1. Kiểm tra Họ và Tên
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    return null;
  }

  // 2. Kiểm tra Email (Bắt buộc phải chứa @ và dấu .)
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Email không hợp lệ (phải chứa ký tự @ và dấu .)';
    }
    return null;
  }

  // 3. Kiểm tra Mật khẩu (Tối thiểu 8 ký tự và chứa ít nhất 1 chữ số)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    }
    return null;
  }

  // 4. Kiểm tra Mật khẩu xác nhận (Phải trùng khớp với mật khẩu ở trên)
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận lại mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không trùng khớp';
    }
    return null;
  }

  // Tính năng bổ sung: Đo độ mạnh của mật khẩu
  String _getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score <= 2) return 'Độ mạnh: Yếu (Weak)';
    if (score == 3) return 'Độ mạnh: Trung bình (Medium)';
    return 'Độ mạnh: Mạnh (Strong)';
  }

  // ==========================================
  // XỬ LÝ SUBMIT FORM & CHECK EMAIL ASYNC (Lab 7.4)
  // ==========================================
  Future<void> _submitForm() async {
    // Ẩn bàn phím khi bấm gửi
    FocusScope.of(context).unfocus();

    // Bước 1: Chạy kiểm tra tính hợp lệ tại chỗ (Synchronous Validation)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Kiểm tra đã tích chọn Điều khoản chưa
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đồng ý với Điều khoản & Điều kiện trước khi tiếp tục!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Bước 2: Đặt trạng thái đang tải (Loading) để kiểm tra Async
    setState(() {
      _isCheckingEmail = true;
    });

    // Bước 3: Giả lập gọi API kiểm tra Email mất 2 giây (Future.delayed)
    await Future.delayed(const Duration(seconds: 2));

    final emailText = _emailController.text.trim().toLowerCase();

    // Bước 5: Luôn đưa trạng thái isCheckingEmail về false dù kết quả ra sao
    if (!mounted) return;
    setState(() {
      _isCheckingEmail = false;
    });

    // Quy tắc giả lập: Nếu email bắt đầu bằng từ "taken" -> Báo lỗi đã tồn tại
    if (emailText.startsWith('taken')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email này đã được sử dụng (already taken)!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Dừng lại, không hiện thông báo thành công
    }

    // Bước 4: Nếu hợp lệ và email chưa bị chiếm -> Lưu dữ liệu và báo thành công
    _formKey.currentState!.save();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đăng ký tài khoản thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passwordStrength = _getPasswordStrength(_passwordController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
        centerTitle: true,
      ),
      // GestureDetector giúp ẩn bàn phím khi bấm ra ngoài các ô nhập liệu
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            // Sử dụng autovalidateMode để kiểm tra khi người dùng tương tác theo yêu cầu Lab 7.2
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Ô nhập Họ và Tên (Full Name)
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: _validateName,
                  onFieldSubmitted: (_) {
                    // Chuyển con trỏ xuống ô Email
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  },
                ),
                const SizedBox(height: 16),

                // 2. Ô nhập Email
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Ví dụ: user@example.com',
                  ),
                  validator: _validateEmail,
                  onFieldSubmitted: (_) {
                    // Chuyển con trỏ xuống ô Mật khẩu
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),
                const SizedBox(height: 16),

                // 3. Ô nhập Mật khẩu (Password)
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _isPasswordObscured,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        // Nút ẩn/hiện mật khẩu
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) {
                    // Chuyển con trỏ xuống ô Xác nhận mật khẩu
                    FocusScope.of(context)
                        .requestFocus(_confirmPasswordFocusNode);
                  },
                ),

                // Văn bản hiển thị độ mạnh của mật khẩu
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    passwordStrength,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: passwordStrength.contains('Yếu')
                          ? Colors.red
                          : passwordStrength.contains('Trung bình')
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // 4. Ô nhập Xác nhận mật khẩu (Confirm Password)
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  obscureText: _isConfirmPasswordObscured,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordObscured
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordObscured =
                          !_isConfirmPasswordObscured;
                        });
                      },
                    ),
                  ),
                  validator: _validateConfirmPassword,
                  onFieldSubmitted: (_) => _submitForm(),
                ),
                const SizedBox(height: 12),

                // 5. Checkbox Đồng ý điều khoản (Terms & Conditions)
                CheckboxListTile(
                  value: _acceptedTerms,
                  title: const Text('Tôi đồng ý với Điều khoản & Điều kiện'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _acceptedTerms = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 6. Nút Submit (Hiển thị Vòng xoay tải khi đang Check Async)
                ElevatedButton(
                  onPressed: _isCheckingEmail ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isCheckingEmail
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}