import 'package:flutter/material.dart';
import 'models/weather_model.dart';
import 'services/weather_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thời tiết App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.fetchWeatherForCity(city);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thời tiết'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tên thành phố (vd: Hanoi)...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _fetchWeather(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isLoading ? null : _fetchWeather,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              )
            else if (_weather != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _weather!.cityName,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_weather!.temperature.toStringAsFixed(1)}°C',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _weather!.weatherDescription,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.air, color: Colors.blue),
                                  const SizedBox(height: 4),
                                  const Text('Tốc độ gió'),
                                  Text('${_weather!.windSpeed} km/h',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.water_drop, color: Colors.blue),
                                  const SizedBox(height: 4),
                                  const Text('Độ ẩm'),
                                  Text('${_weather!.humidity}%',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _weather!.recommendation,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text('Nhập tên thành phố để xem thời tiết'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}