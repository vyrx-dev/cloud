import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // api key
  late final WeatherService _weatherService;
  Weather? _weather;

  // dark mode
  bool _isDarkMode = false;

  // initialize weather service and fetch weather
  Future<void> _loadEnvAndFetchWeather() async {
    try {
      // initialize weather service with API key (dotenv already loaded in main)
      _weatherService = WeatherService();

      // fetch weather on startup
      await fetchWeather();
    } catch (e) {
      debugPrint('Error loading environment: $e');
      if (mounted) {
        setState(() {
          _weather = null;
        });
      }
    }
  }

  // fetch weather
  Future<void> fetchWeather() async {
    // get the current city
    String cityName = await _weatherService.getCurrentCity();

    // get Weather for city
    try {
      final weather = await _weatherService.getWeather(cityName);
      if (mounted) {
        setState(() {
          _weather = weather;
        });
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      if (mounted) {
        setState(() {
          _weather = null;
        });
      }
    }
  }

  // greeting based on time of day
  String getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return "Good morning! ☀️";
    } else if (hour >= 12 && hour < 18) {
      return "Good afternoon! 🌤️";
    } else if (hour >= 18 && hour < 22) {
      return "Good evening! 🌅";
    } else {
      return "Good night! 🌙";
    }
  }

  // weather animations
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return "assets/cloud.json"; //default to cloud

    switch (mainCondition.toLowerCase()) {
      case "cloud":
      case "mist":
      case "smoke":
      case "haze":
      case "dust":
      case "fog":
        return 'assets/cloud.json';
      case "rain":
      case "drizzle":
      case "shower rain":
        return 'assets/rain.json';
      case "thunderstorm":
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    // load environment variables
    _loadEnvAndFetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        color: _isDarkMode ? Colors.grey.shade900 : Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // top bar with greeting and dark mode toggle
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // greeting
                    Text(
                      getGreeting(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: _isDarkMode ? Colors.white : Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    // dark mode toggle
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: _isDarkMode
                              ? Colors.amber
                              : Colors.grey.shade700,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // weather content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // location with city name
                      _weather == null
                          ? Text(
                              'Loading city...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: _isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: _isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _weather?.cityName ?? "",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: _isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),

                      // animation
                      _weather == null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: _isDarkMode
                                        ? Colors.blue.shade300
                                        : Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            )
                          : Lottie.asset(
                              getWeatherAnimation(_weather?.mainCondition),
                            ),
                      SizedBox(height: 16),

                      // temperature
                      _weather == null
                          ? Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            )
                          : Text(
                              '${_weather?.temperature.round()}°C',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),

                      SizedBox(height: 8),

                      // weather condition
                      _weather == null
                          ? Text(
                              '',
                              style: TextStyle(
                                color: _isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            )
                          : Text(
                              _weather?.mainCondition ?? "",
                              style: TextStyle(
                                color: _isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
