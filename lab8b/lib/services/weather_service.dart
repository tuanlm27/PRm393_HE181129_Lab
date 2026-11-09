import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  // 1. Lấy tọa độ lat, lon từ tên thành phố
  Future<Map<String, dynamic>?> _getCoordinates(String cityName) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$cityName&count=1&language=en&format=json',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return {
          'lat': data['results'][0]['latitude'],
          'lon': data['results'][0]['longitude'],
          'name': data['results'][0]['name'],
        };
      }
    }
    return null;
  }

  // 2. Lấy dữ liệu thời tiết dựa trên thành phố
  Future<WeatherModel> fetchWeatherForCity(String cityName) async {
    final location = await _getCoordinates(cityName);
    if (location == null) {
      throw Exception('Không tìm thấy thành phố "$cityName"');
    }

    final double lat = (location['lat'] as num).toDouble();
    final double lon = (location['lon'] as num).toDouble();
    final String officialName = location['name'] as String;

    final weatherUrl = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=relative_humidity_2m',
    );

    final response = await http.get(weatherUrl);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherModel.fromJson(data, officialName);
    } else {
      throw Exception('Không thể tải dữ liệu thời tiết từ máy chủ.');
    }
  }
}