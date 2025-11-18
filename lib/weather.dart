import 'package:flutter/material.dart';
import 'package:sample/services/weather_service.dart';
import 'package:sample/screens/weather_screen.dart';
import 'package:sample/theme/mobile_theme.dart';

class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  WeatherData? _currentWeather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    try {
      final weather = await WeatherService.getCurrentWeather();
      setState(() {
        _currentWeather = weather;
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
    final scheme = Theme.of(context).colorScheme;
    final isMobile = MobileTheme.isMobile(context);
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            if (!isMobile) ...[
              const Icon(Icons.agriculture, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hacienda Elizabeth',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Weather Forecast',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: scheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeatherData,
            tooltip: 'Refresh Weather',
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeatherScreen(),
                ),
              );
            },
            tooltip: 'Detailed Weather',
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          final isMobile = MobileTheme.isMobile(context);
          final isSmallScreen = screenHeight < 700;
          
          // Responsive sizes
          final iconSize = isSmallScreen ? screenWidth * 0.2 : screenWidth * 0.25;
          final titleFontSize = isSmallScreen ? 20.0 : (isMobile ? 24.0 : 28.0);
          final tempFontSize = isSmallScreen ? 28.0 : (isMobile ? 32.0 : 36.0);
          final descFontSize = isSmallScreen ? 14.0 : (isMobile ? 16.0 : 18.0);
          final buttonHeight = isSmallScreen ? 40.0 : 50.0;
          
          return Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E3A8A),
                  const Color(0xFF3B82F6),
                  const Color(0xFF60A5FA),
                ],
              ),
            ),
            child: Column(
              children: [
                // Top section - Weather display (takes remaining space)
                Flexible(
                  flex: isSmallScreen ? 1 : 2,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 24,
                      vertical: isSmallScreen ? 8 : 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: isSmallScreen ? 8 : 16),
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? Icon(
                                  Icons.cloud,
                                  size: iconSize * 0.6,
                                  color: Colors.white,
                                )
                              : _currentWeather != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Image.network(
                                        WeatherService.getWeatherIconUrl(_currentWeather!.icon),
                                        width: iconSize * 0.6,
                                        height: iconSize * 0.6,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            _getWeatherIcon(_currentWeather!.icon),
                                            size: iconSize * 0.6,
                                            color: Colors.white,
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      Icons.cloud,
                                      size: iconSize * 0.6,
                                      color: Colors.white,
                                    ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 16),
                        Text(
                          'Weather Forecast',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                          child: Text(
                            _isLoading
                                ? 'Loading weather data...'
                                : _currentWeather != null
                                    ? 'Current conditions in ${_currentWeather!.city}'
                                    : 'Check weather conditions for your farm',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : (isMobile ? 14 : 16),
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_currentWeather != null) ...[
                          SizedBox(height: isSmallScreen ? 8 : 16),
                          Text(
                            '${_currentWeather!.temperature.round()}°C',
                            style: TextStyle(
                              fontSize: tempFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 8),
                          Text(
                            _currentWeather!.description.toUpperCase(),
                            style: TextStyle(
                              fontSize: descFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 8),
                          Text(
                            'Feels like ${_currentWeather!.feelsLike.round()}°C',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        SizedBox(height: isSmallScreen ? 12 : 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WeatherScreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: buttonHeight,
                            width: screenWidth * (isMobile ? 0.75 : 0.7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_outlined,
                                    color: Colors.blue[700],
                                    size: isSmallScreen ? 18 : 24,
                                  ),
                                  SizedBox(width: isSmallScreen ? 6 : 10),
                                  Text(
                                    'Detailed Weather',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: isSmallScreen ? 14 : (isMobile ? 16 : 18),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 16),
                      ],
                    ),
                  ),
                ),
                // Weather info preview - Constrained to ~50% of screen height
                Flexible(
                  flex: 1,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.5,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 20,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, -15),
                  ),
                ],
              ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _currentWeather?.city ?? 'Talisay City',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : (isMobile ? 16 : 18),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Today, ${DateTime.now().day} ${_getMonth(DateTime.now().month)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isSmallScreen ? 10 : (isMobile ? 12 : 14),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        Expanded(
                          child: _currentWeather != null
                              ? LayoutBuilder(
                                  builder: (context, innerConstraints) {
                                    final innerIsMobile = innerConstraints.maxWidth < 600;
                                    final crossAxisCount = innerIsMobile ? 2 : 4;
                                    final itemSpacing = isSmallScreen ? 4.0 : (innerIsMobile ? 6.0 : 10.0);
                                    final aspectRatio = isSmallScreen ? 1.8 : (innerIsMobile ? 1.6 : 1.8);
                                    
                                    return SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GridView.count(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: itemSpacing,
                                            mainAxisSpacing: itemSpacing,
                                            childAspectRatio: aspectRatio,
                                            children: [
                                              _buildWeatherPreview(
                                                'Humidity',
                                                '${_currentWeather!.humidity}%',
                                                Icons.water_drop,
                                                Colors.blue,
                                                isSmallScreen,
                                              ),
                                              _buildWeatherPreview(
                                                'Wind',
                                                '${_currentWeather!.windSpeed.toStringAsFixed(1)} m/s',
                                                Icons.air,
                                                Colors.green,
                                                isSmallScreen,
                                              ),
                                              _buildWeatherPreview(
                                                'Pressure',
                                                '${_currentWeather!.pressure.round()} hPa',
                                                Icons.compress,
                                                Colors.orange,
                                                isSmallScreen,
                                              ),
                                              _buildWeatherPreview(
                                                'UV Index',
                                                _currentWeather!.uvIndex.toStringAsFixed(1),
                                                Icons.wb_sunny,
                                                Colors.red,
                                                isSmallScreen,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: isSmallScreen ? 6 : 10),
                                          GridView.count(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: itemSpacing,
                                            mainAxisSpacing: itemSpacing,
                                            childAspectRatio: aspectRatio,
                                            children: [
                                              _buildWeatherPreview(
                                                'Sunrise',
                                                _currentWeather!.sunrise,
                                                Icons.wb_sunny_outlined,
                                                Colors.amber,
                                                isSmallScreen,
                                              ),
                                              _buildWeatherPreview(
                                                'Sunset',
                                                _currentWeather!.sunset,
                                                Icons.wb_sunny_outlined,
                                                Colors.deepOrange,
                                                isSmallScreen,
                                              ),
                                              _buildWeatherPreview(
                                                'Visibility',
                                                '${(_currentWeather!.visibility / 1000).toStringAsFixed(1)} km',
                                                Icons.visibility,
                                                Colors.purple,
                                                isSmallScreen,
                                              ),
                                              _buildWeatherPreview(
                                                'Max Temp',
                                                '${_currentWeather!.maxTemp.round()}°C',
                                                Icons.thermostat,
                                                Colors.teal,
                                                isSmallScreen,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : LayoutBuilder(
                                  builder: (context, innerConstraints) {
                                    final innerIsMobile = innerConstraints.maxWidth < 600;
                                    final crossAxisCount = innerIsMobile ? 2 : 4;
                                    final itemSpacing = isSmallScreen ? 4.0 : (innerIsMobile ? 6.0 : 10.0);
                                    final aspectRatio = isSmallScreen ? 1.8 : (innerIsMobile ? 1.6 : 1.8);
                                    
                                    return GridView.count(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: itemSpacing,
                                      mainAxisSpacing: itemSpacing,
                                      childAspectRatio: aspectRatio,
                                      children: [
                                        _buildWeatherPreview(
                                          'Morning', '28°', Icons.wb_sunny_outlined, Colors.amber, isSmallScreen),
                                        _buildWeatherPreview('Afternoon', '32°', Icons.wb_sunny, Colors.orange, isSmallScreen),
                                        _buildWeatherPreview(
                                          'Evening', '27°', Icons.nights_stay_outlined, Colors.indigo, isSmallScreen),
                                        _buildWeatherPreview('Night', '25°', Icons.nights_stay, Colors.blue, isSmallScreen),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildWeatherPreview(String time, String temp, IconData icon, Color color, bool isSmallScreen) {
    final labelSize = isSmallScreen ? 9.0 : 10.0;
    final iconSize = isSmallScreen ? 16.0 : 18.0;
    final valueSize = isSmallScreen ? 12.0 : 13.0;
    final spacing = isSmallScreen ? 3.0 : 4.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          time,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: labelSize,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: spacing),
        Icon(
          icon,
          color: color,
          size: iconSize,
        ),
        SizedBox(height: spacing),
        Text(
          temp,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: valueSize,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
