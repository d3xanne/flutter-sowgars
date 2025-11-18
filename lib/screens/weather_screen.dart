import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:sample/services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  WeatherData? _currentWeather;
  List<WeatherData> _forecast = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadWeatherData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final weather = await WeatherService.getCurrentWeather();
      final forecast = await WeatherService.getForecast();

      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshWeather() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadWeatherData();

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (_isLoading)
            SliverFillRemaining(
              child: _buildLoadingState(),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: _buildErrorState(),
            )
          else
            SliverList(
              delegate: SliverChildListDelegate([
                _buildCurrentWeatherCard(),
                _buildWeatherChart(),
                _buildHourlyForecast(),
                _buildWeatherDetailsGrid(),
                _buildForecastCards(),
                const SizedBox(height: 100), // Bottom padding
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E3A8A).withValues(alpha: 0.9),
                const Color(0xFF3B82F6).withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentWeather?.city ?? 'Talisay City',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Weather Forecast',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _refreshWeather,
                    icon: _isRefreshing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: Colors.blue[400],
            size: 60.0,
          ),
          const SizedBox(height: 20),
          AnimatedTextKit(
            animatedTexts: [
              FadeAnimatedText(
                'Loading weather data...',
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
            isRepeatingAnimation: true,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to load weather data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _loadWeatherData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    if (_currentWeather == null) return const SizedBox.shrink();

    final weather = _currentWeather!;
    final tempColor = WeatherService.getTemperatureColor(weather.temperature);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tempColor.withValues(alpha: 0.2),
              tempColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.round()}°C',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: tempColor,
                        ),
                      ),
                      Text(
                        weather.description.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Feels like ${weather.feelsLike.round()}°C',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.network(
                      WeatherService.getWeatherIconUrl(weather.icon),
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _getWeatherIcon(weather.icon),
                          size: 80,
                          color: tempColor,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeatherMetric(
                    Icons.water_drop,
                    'Humidity',
                    '${weather.humidity}%',
                    Colors.blue,
                  ),
                  _buildWeatherMetric(
                    Icons.air,
                    'Wind',
                    '${weather.windSpeed.toStringAsFixed(1)} m/s',
                    Colors.green,
                  ),
                  _buildWeatherMetric(
                    Icons.compress,
                    'Pressure',
                    '${weather.pressure.round()} hPa',
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherChart() {
    if (_forecast.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temperature Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _forecast.length) {
                            return Text(
                              DateFormat('E').format(_forecast[value.toInt()].lastUpdated),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}°',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _forecast.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.temperature);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue[400]!,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blue[400]!,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecast() {
    if (_forecast.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hourly Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _forecast.length,
                itemBuilder: (context, index) {
                  final weather = _forecast[index];
                  final tempColor = WeatherService.getTemperatureColor(weather.temperature);
                  
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(weather.lastUpdated),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Image.network(
                          WeatherService.getWeatherIconUrl(weather.icon),
                          width: 30,
                          height: 30,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _getWeatherIcon(weather.icon),
                              size: 30,
                              color: tempColor,
                            );
                          },
                        ),
                        Text(
                          '${weather.temperature.round()}°',
                          style: TextStyle(
                            color: tempColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${weather.humidity}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsGrid() {
    if (_currentWeather == null) return const SizedBox.shrink();

    final weather = _currentWeather!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildDetailCard(
                  Icons.visibility,
                  'Visibility',
                  '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                  Colors.purple,
                ),
                _buildDetailCard(
                  Icons.wb_sunny,
                  'UV Index',
                  weather.uvIndex.toStringAsFixed(1),
                  Colors.red,
                ),
                _buildDetailCard(
                  Icons.wb_sunny_outlined,
                  'Sunrise',
                  weather.sunrise,
                  Colors.amber,
                ),
                _buildDetailCard(
                  Icons.wb_sunny_outlined,
                  'Sunset',
                  weather.sunset,
                  Colors.deepOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCards() {
    if (_forecast.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '5-Day Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            ..._forecast.map((weather) => _buildForecastCard(weather)),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastCard(WeatherData weather) {
    final date = DateFormat('EEEE, MMM d').format(weather.lastUpdated);
    final tempColor = WeatherService.getTemperatureColor(weather.temperature);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  weather.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Image.network(
                WeatherService.getWeatherIconUrl(weather.icon),
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _getWeatherIcon(weather.icon),
                    size: 40,
                    color: tempColor,
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${weather.temperature.round()}°C',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: tempColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 16,
                      color: Colors.blue[300],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${weather.humidity}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode.substring(0, 2)) {
      case '01':
        return Icons.wb_sunny;
      case '02':
      case '03':
        return Icons.wb_cloudy;
      case '04':
        return Icons.cloud;
      case '09':
        return Icons.grain;
      case '10':
        return Icons.beach_access;
      case '11':
        return Icons.flash_on;
      case '13':
        return Icons.ac_unit;
      case '50':
        return Icons.blur_on;
      default:
        return Icons.wb_sunny;
    }
  }
}