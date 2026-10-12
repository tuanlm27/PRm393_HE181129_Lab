import 'package:flutter/material.dart';

// ==========================================
// 1. MOVIE MODEL (Mô hình dữ liệu Phim)
// ==========================================

class Movie {
  final String title; // Tên phim
  final int year; // Năm sản xuất
  final List<String> genres; // Danh sách thể loại
  final String posterUrl; // Đường dẫn hình ảnh poster
  final double rating; // Điểm đánh giá (để phục vụ sắp xếp/hiển thị)

  Movie({
    required this.title,
    required this.year,
    required this.genres,
    required this.posterUrl,
    required this.rating,
  });
}

// ==========================================
// 2. SAMPLE DATA (Dữ liệu mẫu)
// ==========================================

final List<Movie> allMovies = [
  Movie(
    title: 'Dune: Part Two',
    year: 2024,
    genres: ['Sci-Fi', 'Adventure', 'Drama'],
    posterUrl: 'https://picsum.photos/id/10/400/600',
    rating: 8.6,
  ),
  Movie(
    title: 'Deadpool & Wolverine',
    year: 2024,
    genres: ['Action', 'Comedy'],
    posterUrl: 'https://picsum.photos/id/1062/400/600',
    rating: 8.3,
  ),
  Movie(
    title: 'Oppenheimer',
    year: 2023,
    genres: ['Biography', 'Drama', 'History'],
    posterUrl: 'https://picsum.photos/id/1069/400/600',
    rating: 8.9,
  ),
  Movie(
    title: 'Spider-Man: Across the Spider-Verse',
    year: 2023,
    genres: ['Action', 'Animation', 'Adventure'],
    posterUrl: 'https://picsum.photos/id/1025/400/600',
    rating: 8.7,
  ),
  Movie(
    title: 'Interstellar',
    year: 2014,
    genres: ['Sci-Fi', 'Drama', 'Adventure'],
    posterUrl: 'https://picsum.photos/id/1015/400/600',
    rating: 8.7,
  ),
  Movie(
    title: 'The Dark Knight',
    year: 2008,
    genres: ['Action', 'Crime', 'Drama'],
    posterUrl: 'https://picsum.photos/id/1040/400/600',
    rating: 9.0,
  ),
];

// Danh sách thể loại có sẵn để lọc
final List<String> availableGenres = [
  'Action',
  'Adventure',
  'Animation',
  'Biography',
  'Comedy',
  'Crime',
  'Drama',
  'History',
  'Sci-Fi',
];

// ==========================================
// 3. MAIN APP (Điểm khởi chạy ứng dụng)
// ==========================================

void main() {
  runApp(const ResponsiveMovieApp());
}

class ResponsiveMovieApp extends StatelessWidget {
  const ResponsiveMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Responsive Movie App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const GenreScreen(),
    );
  }
}

// ==========================================
// 4. GENRE SCREEN (Màn hình chính lọc theo thể loại)
// ==========================================

class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  // Trạng thái quản lý tìm kiếm, lọc thể loại và sắp xếp
  String searchQuery = '';
  final Set<String> selectedGenres = {};
  String selectedSort = 'A–Z';

  // Danh sách các tùy chọn sắp xếp
  final List<String> sortOptions = ['A–Z', 'Z–A', 'Year', 'Rating'];

  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------
    // Xử lý Lọc (Filter) & Sắp xếp (Sort) Dữ liệu
    // ----------------------------------------------------
    List<Movie> visibleMovies = allMovies.where((movie) {
      // 1. Kiểm tra từ khóa tìm kiếm (không phân biệt hoa/thường)
      final matchesSearch =
      movie.title.toLowerCase().contains(searchQuery.toLowerCase());

      // 2. Kiểm tra lọc thể loại (Nếu chọn genre nào thì phim phải chứa ít nhất 1 genre đó)
      final matchesGenre = selectedGenres.isEmpty ||
          movie.genres.any((genre) => selectedGenres.contains(genre));

      return matchesSearch && matchesGenre;
    }).toList();

    // 3. Thực hiện sắp xếp danh sách visibleMovies
    visibleMovies.sort((a, b) {
      switch (selectedSort) {
        case 'A–Z':
          return a.title.compareTo(b.title);
        case 'Z–A':
          return b.title.compareTo(a.title);
        case 'Year':
          return b.year.compareTo(a.year); // Mới nhất lên đầu
        case 'Rating':
          return b.rating.compareTo(a.rating); // Điểm cao nhất lên đầu
        default:
          return 0;
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // SafeArea để tránh bị lẹm viền notch / camera cutouts
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------
              // TIÊU ĐỀ "Find a Movie"
              // ----------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Find a Movie',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Badge hiển thị số lượng thể loại đang chọn (Bonus enhancement)
                  if (selectedGenres.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.filter_alt, size: 16),
                      label: Text('${selectedGenres.length} selected'),
                      backgroundColor: Colors.indigo.shade100,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------
              // SEARCH BAR (Ô tìm kiếm phim)
              // ----------------------------------------------------
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search movies by title...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                      });
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------
              // GENRE CHIPS (Dùng Wrap để tự động xuống dòng responsive)
              // ----------------------------------------------------
              const Text(
                'Genres',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: availableGenres.map((genre) {
                  final isSelected = selectedGenres.contains(genre);
                  return FilterChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedGenres.add(genre);
                        } else {
                          selectedGenres.remove(genre);
                        }
                      });
                    },
                    selectedColor: Colors.indigo.shade200,
                    checkmarkColor: Colors.indigo.shade900,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // ----------------------------------------------------
              // SORT DROPDOWN & CLEAR BUTTON BAR
              // ----------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Sort by: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      DropdownButton<String>(
                        value: selectedSort,
                        underline: const SizedBox(), // Tắt đường gạch chân mặc định
                        items: sortOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedSort = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  // Nút Xóa Bộ Lọc (Bonus enhancement)
                  if (selectedGenres.isNotEmpty || searchQuery.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedGenres.clear();
                          searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Clear Filters'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // ----------------------------------------------------
              // RESPONSIVE MOVIE LIST (Dùng Expanded + LayoutBuilder)
              // Breakpoint: maxWidth < 800px -> 1 cột (ListView)
              //             maxWidth >= 800px -> 2 cột (GridView)
              // ----------------------------------------------------
              Expanded(
                child: visibleMovies.isEmpty
                    ? const Center(
                  child: Text(
                    'No movies found matching your criteria.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    // Kiểm tra chiều rộng màn hình khả dụng
                    final isWideScreen = constraints.maxWidth >= 800;

                    if (isWideScreen) {
                      // Layout Dạng Lưới (Grid) 2 cột cho màn hình Tablet / Web
                      return GridView.builder(
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: visibleMovies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(movie: visibleMovies[index]);
                        },
                      );
                    } else {
                      // Layout Dạng Danh Sách (List) 1 cột cho màn hình Điện thoại nhỏ
                      return ListView.builder(
                        itemCount: visibleMovies.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: MovieCard(movie: visibleMovies[index]),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. MOVIE CARD WIDGET (Thẻ thông tin phim)
// ==========================================

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Ảnh Poster Phim
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                movie.posterUrl,
                width: 80,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 110,
                  color: Colors.grey[300],
                  child: const Icon(Icons.movie, size: 40),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Thông tin Phim
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Year: ${movie.year}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.rating}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Render các genre tag nhỏ bên trong card
                  Wrap(
                    spacing: 4,
                    children: movie.genres.map((g) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          g,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}