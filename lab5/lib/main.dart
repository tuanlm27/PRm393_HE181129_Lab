import 'package:flutter/material.dart';

// ==========================================
// 1. DATA MODELS (Cấu trúc dữ liệu)
// ==========================================

/// Lớp đại diện cho một video Trailer của phim
class Trailer {
  final String id;
  final String title;

  Trailer({required this.id, required this.title});
}

/// Lớp đại diện cho thông tin một bộ phim (Movie)
class Movie {
  final String id; // Mã định danh phim
  final String title; // Tên phim
  final String posterUrl; // Đường dẫn ảnh poster/banner
  final String overview; // Tóm tắt nội dung phim
  final List<String> genres; // Danh sách thể loại (Sci-Fi, Action,...)
  final double rating; // Điểm đánh giá (vd: 8.6)
  final List<Trailer> trailers; // Danh sách trailer
  bool isFavorite; // Trạng thái đã lưu yêu thích hay chưa

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.overview,
    required this.genres,
    required this.rating,
    required this.trailers,
    this.isFavorite = false, // Mặc định ban đầu chưa yêu thích
  });
}

// ==========================================
// 2. SAMPLE DATA (Dữ liệu mẫu)
// ==========================================

/// Danh sách phim mẫu dùng để hiển thị (không gọi API bên ngoài)
final List<Movie> sampleMovies = [
  Movie(
    id: '1',
    title: 'Dune: Part Two',
    posterUrl: 'https://picsum.photos/id/10/800/400',
    overview:
    'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.',
    genres: ['Sci-Fi', 'Adventure', 'Drama'],
    rating: 8.6,
    trailers: [
      Trailer(id: 't1', title: 'Official Trailer #1'),
      Trailer(id: 't2', title: 'IMAX Sneak Peek'),
    ],
  ),
  Movie(
    id: '2',
    title: 'Deadpool & Wolverine',
    posterUrl: 'https://picsum.photos/id/1062/800/400',
    overview:
    'The multiverse gets messy when Wade Wilson teams up with Wolverine for a not-so-family-friendly mission.',
    genres: ['Action', 'Comedy'],
    rating: 8.3,
    trailers: [
      Trailer(id: 't3', title: 'Red Band Trailer'),
      Trailer(id: 't4', title: 'Behind the Scenes'),
    ],
  ),
];

// ==========================================
// 3. MAIN APP (Điểm khởi chạy ứng dụng)
// ==========================================

/// Hàm main: Khởi chạy ứng dụng Flutter
void main() {
  runApp(const MovieApp());
}

/// Widget gốc thiết lập Theme và màn hình khởi đầu
class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt biểu tượng "Debug" ở góc trên
      title: 'Movie Detail App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Đặt HomeScreen làm màn hình chính ban đầu
    );
  }
}

// ==========================================
// 4. HOME SCREEN (Màn hình danh sách phim)
// ==========================================

/// Màn hình chính dạng StatefulWidget để cập nhật lại giao diện khi quay về từ màn hình chi tiết
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thanh ứng dụng hiển thị tiêu đề "Movies"
      appBar: AppBar(
        title: const Text('Movies'),
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],

      // ListView.builder: Dựng danh sách cuộn tối ưu hiệu năng
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: sampleMovies.length, // Số lượng phần tử trong danh sách
        itemBuilder: (context, index) {
          final movie = sampleMovies[index]; // Lấy dữ liệu phim tại vị trí index

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // InkWell: Tạo hiệu ứng gợn sóng (ripple effect) khi người dùng bấm vào
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                // Điều hướng Navigator.push sang màn hình MovieDetailScreen
                // Đồng thời truyền object `movie` được chọn sang màn hình đó
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(movie: movie),
                  ),
                );

                // Sau khi từ màn hình Detail bấm back trở về, gọi setState để reload lại UI (cập nhật biểu tượng Favorite nếu có thay đổi)
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // ClipRRect: Bỏ góc cong cho hình ảnh poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.posterUrl,
                        width: 90,
                        height: 65,
                        fit: BoxFit.cover,
                        // errorBuilder: Hiển thị hình ảnh thay thế nếu không tải được ảnh từ URL
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              width: 90,
                              height: 65,
                              color: Colors.grey[300],
                              child: const Icon(Icons.movie),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Cột chứa Tiêu đề, Điểm số và Thể loại phim
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '⭐ ${movie.rating} •${movie.genres.join(', ')}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis, // Hiện dấu "..." nếu văn bản quá dài
                          ),
                        ],
                      ),
                    ),

                    // Mũi tên chuyển trang ở góc phải
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 5. MOVIE DETAIL SCREEN (Màn hình chi tiết)
// ==========================================

/// Màn hình hiển thị thông tin chi tiết của bộ phim được chọn
class MovieDetailScreen extends StatefulWidget {
  final Movie movie; // Nhận đối tượng phim truyền từ HomeScreen sang

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Truy cập thông tin movie thông qua widget.movie
    final movie = widget.movie;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title), // Tiêu đề AppBar là tên phim
      ),
      // SingleChildScrollView: Cho phép toàn bộ nội dung trang cuộn được theo chiều dọc
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // PHẦN 1: Hero Banner (Ảnh nền + Hiệu ứng Gradient mờ + Tên phim)
            // ----------------------------------------------------
            Stack(
              children: [
                // Ảnh Banner lớn
                Image.network(
                  movie.posterUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.grey[300],
                    child: const Icon(Icons.movie, size: 50),
                  ),
                ),
                // Lớp phủ Gradient làm tối phần dưới của ảnh giúp chữ dễ nhìn hơn
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Tên phim đè lên phía trên ảnh banner (ở góc dưới bên trái)
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ----------------------------------------------------
            // PHẦN 2: Danh sách thể loại dạng Chips
            // ----------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0, // Khoảng cách giữa các Chip
                // Chuyển đổi danh sách chuỗi genres thành danh sách Widget Chip
                children: movie.genres
                    .map((genre) => Chip(
                  label: Text(genre),
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ))
                    .toList(),
              ),
            ),

            // ----------------------------------------------------
            // PHẦN 3: Tóm tắt nội dung (Overview)
            // ----------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                movie.overview,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),

            // ----------------------------------------------------
            // PHẦN 4: Hàng các nút chức năng (Favorite / Rate / Share)
            // ----------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Nút Favorite: Có xử lý đổi trạng thái và màu sắc biểu tượng
                IconButton(
                  icon: Icon(
                    movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: movie.isFavorite ? Colors.red : Colors.grey[700],
                  ),
                  onPressed: () {
                    // setState: Đổi trạng thái Yêu thích và dựng lại UI của màn hình
                    setState(() {
                      movie.isFavorite = !movie.isFavorite;
                    });

                    // Hiển thị thông báo nhỏ (SnackBar) ở dưới cùng màn hình
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          movie.isFavorite
                              ? 'Added to favorites'
                              : 'Removed from favorites',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                // Nút Rate (Đánh giá)
                IconButton(
                  icon: const Icon(Icons.star_border),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rating dialog...')),
                    );
                  },
                ),

                // Nút Share (Chia sẻ)
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share functionality...')),
                    );
                  },
                ),
              ],
            ),

            // Nhãn văn bản hiển thị ngay bên dưới các biểu tượng nút bấm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Text('Favorite', style: TextStyle(fontSize: 12)),
                Text('Rate', style: TextStyle(fontSize: 12)),
                Text('Share', style: TextStyle(fontSize: 12)),
              ],
            ),

            const Divider(height: 32), // Đường gạch ngang phân cách

            // ----------------------------------------------------
            // PHẦN 5: Danh sách Video Trailer
            // ----------------------------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Trailers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ListView.builder dựng danh sách các Trailer
            ListView.builder(
              shrinkWrap: true, // Cho phép ListView thu gọn kích thước vừa bằng nội dung bên trong
              physics: const NeverScrollableScrollPhysics(), // Vô hiệu hóa tính năng cuộn riêng của ListView này để dùng tính năng cuộn chung của SingleChildScrollView
              itemCount: movie.trailers.length,
              itemBuilder: (context, index) {
                final trailer = movie.trailers[index];
                return ListTile(
                  leading: const Icon(Icons.play_circle_fill, size: 30),
                  title: Text(trailer.title),
                  onTap: () {
                    // Xử lý khi nhấn xem trailer (nếu cần mở rộng)
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}