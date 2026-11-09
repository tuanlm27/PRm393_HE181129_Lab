class WeatherModel {
  final String cityName;
  final double temperature;
  final double windSpeed;
  final int humidity;
  final int weatherCode;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String city) {
    final current = json['current_weather'];
    return WeatherModel(
      cityName: city,
      temperature: (current['temperature'] as num).toDouble(),
      windSpeed: (current['windspeed'] as num).toDouble(),
      humidity: json['hourly'] != null && json['hourly']['relative_humidity_2m'] != null
          ? (json['hourly']['relative_humidity_2m'][0] as num).toInt()
          : 0,
      weatherCode: (current['weathercode'] as num).toInt(),
    );
  }

  // Đưa ra lời khuyên dựa trên dữ liệu (Purpose-driven UI)
  String get recommendation {
    if (weatherCode >= 51) {
      return "Mang theo ô/dù! Có mưa rào hoặc tuyết.";
    } else if (temperature > 32) {
      return "Thời tiết khá nóng, nên hạn chế vận động mạnh ngoài trời.";
    } else if (temperature < 15) {
      return "Trời lạnh, hãy mặc ấm trước khi ra ngoài.";
    } else {
      return "Thời tiết rất đẹp để đi dạo hoặc dã ngoại!";
    }
  }

  // Mô tả thời tiết theo Weather Code
  String get weatherDescription {
    if (weatherCode == 0) return "Trời quang";
    if (weatherCode <= 3) return "Có mây";
    if (weatherCode <= 48) return "Sương mù";
    if (weatherCode <= 67) return "Có mưa";
    if (weatherCode <= 77) return "Có tuyết rơi";
    if (weatherCode <= 99) return "Có dông bão";
    return "Không xác định";
  }
}