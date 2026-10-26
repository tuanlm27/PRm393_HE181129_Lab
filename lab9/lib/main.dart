import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 9 - Local JSON Storage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const JsonStorageScreen(),
    );
  }
}

// =============================================================================
// 1. MODEL CLASS (Cấu trúc dữ liệu JSON)
// =============================================================================
class Item {
  final String id;
  String name;
  String description;

  Item({
    required this.id,
    required this.name,
    required this.description,
  });

  // Chuyển JSON Map sang Đối tượng Item
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  // Chuyển Đối tượng Item sang Map để lưu lại JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

// =============================================================================
// 2. STORAGE SERVICE (Quản lý đọc/ghi file local bằng path_provider)
// =============================================================================
class StorageService {
  static const String _fileName = 'items.json';

  // Lấy đường dẫn file local trong thư mục tài liệu ứng dụng
  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  // Khởi tạo & Tải dữ liệu (Lab 9.1 & Lab 9.2)
  static Future<List<Item>> loadItems() async {
    try {
      final file = await _getLocalFile();

      // Nếu file local đã tồn tại, đọc từ file local (Lab 9.2)
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((item) => Item.fromJson(item)).toList();
      } else {
        // Nếu file chưa tồn tại, khởi tạo từ file Assets (Lab 9.1)
        String jsonString = await rootBundle.loadString('assets/data/items.json');
        List<dynamic> jsonList = jsonDecode(jsonString);
        List<Item> items = jsonList.map((item) => Item.fromJson(item)).toList();

        // Lưu lần đầu xuống bộ nhớ thiết bị
        await saveItems(items);
        return items;
      }
    } catch (e) {
      return [];
    }
  }

  // Lưu danh sách dữ liệu vào file local (Lab 9.2 & 9.3 Auto-save)
  static Future<void> saveItems(List<Item> items) async {
    final file = await _getLocalFile();
    List<Map<String, dynamic>> mapList = items.map((e) => e.toJson()).toList();
    String jsonString = jsonEncode(mapList);
    await file.writeAsString(jsonString);
  }
}

// =============================================================================
// 3. UI SCREEN (Giao diện CRUD & Tìm kiếm - Lab 9.3)
// =============================================================================
class JsonStorageScreen extends StatefulWidget {
  const JsonStorageScreen({super.key});

  @override
  State<JsonStorageScreen> createState() => _JsonStorageScreenState();
}

class _JsonStorageScreenState extends State<JsonStorageScreen> {
  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Tải dữ liệu ban đầu
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    List<Item> loaded = await StorageService.loadItems();
    setState(() {
      _allItems = loaded;
      _filteredItems = loaded;
      _isLoading = false;
    });
  }

  // Tự động lưu và cập nhật danh sách tìm kiếm (Auto-save)
  Future<void> _saveAndRefresh() async {
    await StorageService.saveItems(_allItems);
    _filterItems(_searchController.text);
  }

  // Tìm kiếm / Lọc dữ liệu theo từ khóa (Lab 9.3)
  void _filterItems(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems = _allItems.where((item) {
          return item.name.toLowerCase().contains(keyword.toLowerCase()) ||
              item.description.toLowerCase().contains(keyword.toLowerCase());
        }).toList();
      }
    });
  }

  // Dialog Thêm mới hoặc Chỉnh sửa (Add / Edit Item)
  void _showFormDialog({Item? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final isEditing = item != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Sửa mục' : 'Thêm mục mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên (Name)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả (Description)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              Navigator.pop(context);

              if (isEditing) {
                // Cập nhật (Edit)
                item.name = nameController.text.trim();
                item.description = descController.text.trim();
              } else {
                // Thêm mới (Add - tự sinh ID)
                String newId = DateTime.now().millisecondsSinceEpoch.toString();
                _allItems.add(Item(
                  id: newId,
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                ));
              }

              await _saveAndRefresh();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing ? 'Đã cập nhật!' : 'Đã thêm thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  // Xóa mục với Dialog xác nhận (Delete Item)
  void _deleteItem(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              _allItems.removeWhere((element) => element.id == item.id);
              await _saveAndRefresh();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa dữ liệu!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 9 - Local JSON Storage'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Ô tìm kiếm (Search Bar)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc mô tả...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterItems('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Danh sách hiển thị (ListView.builder)
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(child: Text('Không tìm thấy dữ liệu'))
                : ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(item.id.length > 3
                          ? item.id.substring(item.id.length - 2)
                          : item.id),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(item.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nút Sửa (Edit)
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.blue),
                          onPressed: () =>
                              _showFormDialog(item: item),
                        ),
                        // Nút Xóa (Delete)
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () => _deleteItem(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Nút Thêm mới (Add Item)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}