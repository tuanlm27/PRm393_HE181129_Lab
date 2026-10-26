import 'dart:convert'; // Đã xử lý import chuẩn
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 8 - API List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PostListScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. MODEL CLASS (Chuyển đổi JSON -> Model)
// -----------------------------------------------------------------------------
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  // Factory chuyển dữ liệu JSON thành đối tượng Post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['userId'] is int ? json['userId'] : 1,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
    );
  }
}

// -----------------------------------------------------------------------------
// 2. SERVICE LAYER (Sử dụng http: ^1.0.8)
// -----------------------------------------------------------------------------
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  // Hàm lấy danh sách bài viết (GET Request)
  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((item) => Post.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải dữ liệu (Mã lỗi: ${response.statusCode})');
    }
  }

  // Hàm tạo bài viết mới (POST Request - Optional)
  Future<bool> createPost(String title, String body) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'body': body,
        'userId': 1,
      }),
    );

    return response.statusCode == 201;
  }
}

// -----------------------------------------------------------------------------
// 3. UI SCREEN (Màn hình hiển thị danh sách)
// -----------------------------------------------------------------------------
class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Hàm tải lại dữ liệu
  void _refreshData() {
    setState(() {
      _postsFuture = _apiService.fetchPosts();
    });
  }

  // Dialog nhập Form để tạo POST
  void _showAddDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thêm bài viết mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Nội dung'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;

              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang gửi dữ liệu...')),
              );

              bool isSuccess = await _apiService.createPost(
                titleController.text,
                bodyController.text,
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSuccess ? 'Tạo bài viết thành công!' : 'Tạo thất bại!',
                  ),
                  backgroundColor: isSuccess ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Gửi (POST)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 8 - API Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
        },
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            // Trạng thái 1: Đang tải
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Trạng thái 2: Có lỗi
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 10),
                      Text(
                        'Lỗi: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: _refreshData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại (Retry)'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Trạng thái 3: Hiển thị danh sách
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final posts = snapshot.data!;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${post.id}'),
                      ),
                      title: Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(child: Text('Không có dữ liệu.'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}