import 'package:flutter/material.dart';
import 'package:sample/services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const WeatherWidget({
    Key? key,
    this.showDetails = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  WeatherData? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await WeatherService.getCurrentWeather();
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[400]!,
              Colors.blue[600]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isLoading
            ? _buildLoadingWidget()
            : _weather != null
                ? _buildWeatherContent()
                : _buildErrorWidget(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Row(
      children: [
        const Icon(
          Icons.cloud,
          color: Colors.white,
          size: 32,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loading Weather...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Talisay City',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherContent() {
    final weather = _weather!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.network(
            WeatherService.getWeatherIconUrl(weather.icon),
            width: isSmallScreen ? 28 : 32,
            height: isSmallScreen ? 28 : 32,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                _getWeatherIcon(weather.icon),
                color: Colors.white,
                size: isSmallScreen ? 28 : 32,
              );
            },
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temperature.round()}°C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                weather.description.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                weather.city,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: isSmallScreen ? 10 : 12,
                ),
              ),
            ],
          ),
        ),
        if (widget.showDetails && !isSmallScreen) ...[
          const SizedBox(width: 8),
          Column(
            children: [
                        _buildDetailItem('H', '${weather.humidity}%', Icons.water_drop),
                        const SizedBox(height: 4),
                        _buildDetailItem('W', '${weather.windSpeed.toStringAsFixed(1)}m/s', Icons.air),
                        const SizedBox(height: 4),
                        _buildDetailItem('M', '${weather.maxTemp.round()}°C', Icons.thermostat),
            ],
          ),
        ],
        const SizedBox(width: 8),
        Icon(
          Icons.chevron_right,
          color: Colors.white.withValues(alpha: 0.7),
          size: isSmallScreen ? 16 : 20,
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Row(
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 32,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weather Unavailable',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Talisay City',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _loadWeather,
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
