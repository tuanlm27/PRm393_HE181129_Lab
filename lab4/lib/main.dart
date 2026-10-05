import 'package:flutter/material.dart';

/// Hàm main() - Điểm khởi chạy (Entry Point) của ứng dụng Flutter
void main() {
  runApp(const Lab4App());
}

/// Root Widget của toàn bộ ứng dụng
/// Quản lý việc chuyển đổi giữa 5 Exercise và chuyển đổi Dark/Light Mode
class Lab4App extends StatefulWidget {
  const Lab4App({super.key});

  @override
  State<Lab4App> createState() => _Lab4AppState();
}

class _Lab4AppState extends State<Lab4App> {
  // Biến quản lý trạng thái Dark Mode (Dùng cho Exercise 4)
  bool _isDarkMode = false;

  // Biến quản lý Exercise hiện tại đang được chọn (từ 0 đến 4 tương ứng 5 bài)
  int _selectedExerciseIndex = 0;

  /// Hàm hỗ trợ thay đổi chế độ Dark Mode
  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách chứa Widget của 5 Exercise
    final List<Widget> exercises = [
      const Exercise1Screen(),
      const Exercise2Screen(),
      const Exercise3Screen(),
      Exercise4Screen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleDarkMode,
      ),
      const Exercise5Screen(),
    ];

    return MaterialApp(
      title: 'Lab 4 - Flutter UI Fundamentals',
      debugShowCheckedModeBanner: false,

      // Cấu hình ThemeData cho chế độ Sáng (Light) và Tối (Dark)
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),

      // Màn hình chính chứa Menu điều hướng chuyển đổi giữa các Bài tập
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lab 4 - Bài ${_selectedExerciseIndex + 1}'),
          actions: [
            // Công tắc chuyển nhanh Dark Mode ở góc màn hình
            const Text('Dark'),
            Switch(
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
          ],
        ),
        // Hiển thị giao diện bài tập tương ứng theo index được chọn
        body: exercises[_selectedExerciseIndex],

        // Thanh điều hướng phía dưới (Bottom Navigation Bar) để dễ chuyển đổi giữa 5 Bài
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedExerciseIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            // Cập nhật lại giao diện khi nhấn chọn bài tập khác
            setState(() {
              _selectedExerciseIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.widgets), label: 'Ex 1'),
            BottomNavigationBarItem(icon: Icon(Icons.input), label: 'Ex 2'),
            BottomNavigationBarItem(icon: Icon(Icons.view_quilt), label: 'Ex 3'),
            BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Ex 4'),
            BottomNavigationBarItem(icon: Icon(Icons.bug_report), label: 'Ex 5'),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EXERCISE 1: Core Widgets Demo (Text, Icon, Image, Card, ListTile)
// =============================================================================
class Exercise1Screen extends StatelessWidget {
  const Exercise1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView giúp cuộn trang nếu màn hình nhỏ
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tiêu đề chính (Text)
          const Text(
            'Welcome to Flutter UI',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 2. Icon sử dụng bộ Material Icons
          const Center(
            child: Icon(
              Icons.movie_creation_rounded,
              size: 64,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // 3. Hiển thị hình ảnh từ đường dẫn mạng (Image.network)
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              'https://picsum.photos/400/200', // URL ảnh minh họa
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          // 4. Card chứa ListTile bên trong
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const ListTile(
              leading: Icon(Icons.star, color: Colors.amber),
              title: Text('Movie Item'),
              subtitle: Text('This is a sample ListTile inside a Card.'),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EXERCISE 2: Input Widgets Demo (Slider, Switch, RadioListTile, DatePicker)
// =============================================================================
class Exercise2Screen extends StatefulWidget {
  const Exercise2Screen({super.key});

  @override
  State<Exercise2Screen> createState() => _Exercise2ScreenState();
}

class _Exercise2ScreenState extends State<Exercise2Screen> {
  // --- Các biến lưu trữ trạng thái (State) ---
  double _ratingValue = 50.0;       // Giá trị của Slider (0 - 100)
  bool _isMovieActive = false;      // Trạng thái Bật/Tắt của Switch
  String _selectedGenre = 'None';   // Thể loại được chọn từ Radio
  DateTime? _selectedDate;          // Ngày được chọn từ DatePicker

  /// Hàm kích hoạt Dialog chọn ngày (DatePicker)
  Future<void> _openDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    // Nếu người dùng chọn ngày hợp lệ, cập nhật trạng thái UI
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Section 1: Rating (Slider) ---
          const Text('Rating (Slider)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Slider(
            value: _ratingValue,
            min: 0,
            max: 100,
            divisions: 100,
            label: _ratingValue.round().toString(),
            onChanged: (double newValue) {
              // Gọi setState để làm mới màn hình khi kéo Slider
              setState(() {
                _ratingValue = newValue;
              });
            },
          ),
          Text('Current value: ${_ratingValue.round()}'),
          const SizedBox(height: 20),

          // --- Section 2: Active (Switch) ---
          const Text('Active (Switch)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SwitchListTile(
            title: const Text('Is movie active?'),
            value: _isMovieActive,
            onChanged: (bool newValue) {
              setState(() {
                _isMovieActive = newValue;
              });
            },
          ),
          const SizedBox(height: 10),

          // --- Section 3: Genre (RadioListTile) ---
          const Text('Genre (RadioListTile)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          RadioListTile<String>(
            title: const Text('Action'),
            value: 'Action',
            groupValue: _selectedGenre,
            onChanged: (value) {
              setState(() {
                _selectedGenre = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Comedy'),
            value: 'Comedy',
            groupValue: _selectedGenre,
            onChanged: (value) {
              setState(() {
                _selectedGenre = value!;
              });
            },
          ),
          Text('Selected genre: $_selectedGenre'),
          const SizedBox(height: 20),

          // --- Section 4: Open DatePicker Button ---
          Center(
            child: ElevatedButton(
              onPressed: () => _openDatePicker(context),
              child: Text(
                _selectedDate == null
                    ? 'Open Date Picker'
                    : 'Selected Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EXERCISE 3: Layout Basics (Column, Row, Padding, ListView)
// =============================================================================
class Exercise3Screen extends StatelessWidget {
  const Exercise3Screen({super.key});

  // Mảng dữ liệu mẫu danh sách phim
  final List<String> movies = const ['Avatar', 'Inception', 'Interstellar', 'Joker', 'Avengers'];

  @override
  Widget build(BuildContext context) {
    // Áp dụng Padding 16px xung quanh màn hình
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          const Text(
            'Now Playing',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12), // Khoảng cách cố định (12px)

          // ListView hiển thị danh sách động.
          // Lưu ý: Phải bọc Expanded ở đây vì ListView nằm bên trong Column!
          Expanded(
            child: ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movieTitle = movies[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0), // Khoảng cách giữa các phần tử (8px)
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(movieTitle[0]), // Lấy chữ cái đầu tiên làm Avatar
                    ),
                    title: Text(movieTitle),
                    subtitle: const Text('Sample description'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EXERCISE 4: App Structure (Scaffold, FloatingActionButton, Theme)
// =============================================================================
class Exercise4Screen extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const Exercise4Screen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Scaffold dựng cấu hình giao diện chuẩn
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This is a simple screen with theme toggle.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Dark Mode: '),
                Switch(
                  value: isDarkMode,
                  onChanged: onThemeChanged, // Gọi callback để đổi theme toàn app
                ),
              ],
            ),
          ],
        ),
      ),

      // Nút Floating Action Button (FAB) góc dưới bên phải
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Hiển thị thông báo nhanh bằng SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Floating Action Button Tapped!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =============================================================================
// EXERCISE 5: Debug & Fix Common UI Errors
// =============================================================================
class Exercise5Screen extends StatefulWidget {
  const Exercise5Screen({super.key});

  @override
  State<Exercise5Screen> createState() => _Exercise5ScreenState();
}

class _Exercise5ScreenState extends State<Exercise5Screen> {
  final List<String> _items = ['Movie A', 'Movie B', 'Movie C', 'Movie D'];
  DateTime? _selectedDate;

  /// SỬA LỖI 4 (DatePicker Context Error):
  /// Đảm bảo truyền context hợp lệ khi mở DatePicker từ Cây Widget đã mount thành công
  Future<void> _pickDateSafely(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      /// SỬA LỖI 3 (State Update Issue):
      /// Phải gọi setState() thì Flutter mới nhận biết biến _selectedDate đã đổi và render lại màn hình.
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// SỬA LỖI 2 (Overflow on small screens):
    /// Bọc SingleChildScrollView giúp chống tràn màn hình (vệt vàng đen) khi chạy trên máy màn hình nhỏ hoặc khi bật bàn phím
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Correct ListView inside Column using Expanded / SizedBox',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          /// SỬA LỖI 1 (ListView inside Column):
          /// ListView mặc định không giới hạn chiều cao (Unbounded height).
          /// Khi đặt trong Column, ta phải ấn định chiều cao bằng SizedBox (hoặc dùng Expanded nếu nằm trong chiều cao cố định của màn hình).
          SizedBox(
            height: 220, // Đặt chiều cao xác định cho ListView
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.movie),
                  title: Text(_items[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Nút gọi chọn ngày được sửa lỗi thành công
          ElevatedButton(
            onPressed: () => _pickDateSafely(context),
            child: const Text('Pick Date Safely'),
          ),
          const SizedBox(height: 8),

          // Hiển thị ngày đã chọn
          if (_selectedDate != null)
            Text('Selected: ${_selectedDate.toString().split(' ')[0]}'),
        ],
      ),
    );
  }
}