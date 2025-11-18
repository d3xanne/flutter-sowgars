// REPLACE THE ENTIRE FILE: lib/ui/homes.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sample/models/city.dart';
import 'package:sample/models/constants.dart';
import 'package:sample/services/weather_service.dart';
import 'package:sample/ui/detail_page.dart';
import 'package:sample/widgets/weather_item.dart';

class Homes extends StatefulWidget {
  final List<City> selectedCities;

  const Homes({Key? key, required this.selectedCities}) : super(key: key);

  @override
  State<Homes> createState() => _HomesState();
}

class _HomesState extends State<Homes> with SingleTickerProviderStateMixin {
  Constants myConstants = Constants();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Initialization
  int temperature = 0;
  int maxTemp = 0;
  String weatherStateName = 'Loading..';
  int humidity = 0;
  int windSpeed = 0;

  var currentDate = 'Loading..';
  String imageUrl = '';
  String location = 'Talisay City'; // Locked city

  // Get the cities and selected cities data
  var selectedCities = [City(city: 'Talisay City', isDefault: true)];
  List<String> cities = ['Talisay City'];

  List consolidatedWeatherList = []; // To hold our weather data

  void fetchWeatherData() async {
    try {
      // Use our new WeatherService
      var weatherData = await WeatherService.getCurrentWeather();
      var forecastData = await WeatherService.getForecast();

      setState(() {
        // Current weather
        temperature = weatherData.temperature.round();
        weatherStateName = weatherData.description;
        humidity = weatherData.humidity;
        windSpeed = weatherData.windSpeed.round();
        maxTemp = weatherData.temperature.round(); // Using current temp as max for now

        // Date formatting
        var now = DateTime.now();
        currentDate = DateFormat('EEEE, d MMMM').format(now);

        // Set the image url
        imageUrl = _mapWeatherCondition(weatherStateName).toLowerCase();

        // Process forecast data
        consolidatedWeatherList = forecastData.map((day) {
          return {
            'applicable_date': DateFormat('yyyy-MM-dd').format(day.lastUpdated),
            'the_temp': day.temperature,
            'max_temp': day.temperature,
            'min_temp': day.temperature - 2, // Simple min temp calculation
            'humidity': day.humidity,
            'wind_speed': day.windSpeed,
            'weather_state_name': day.description,
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching weather data: $e');
      // Show error state or fallback to mock data
    }
  }

  String _mapWeatherCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'sunny';
      case 'clouds':
        return 'cloudy';
      case 'rain':
        return 'rainy';
      case 'snow':
        return 'snowy';
      case 'thunderstorm':
        return 'stormy';
      case 'mist':
      case 'fog':
        return 'foggy';
      default:
        return 'sunny';
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();

    fetchWeatherData();

    // For all the selected cities from our City model, extract the city and add it to our original cities list
    for (int i = 0; i < widget.selectedCities.length; i++) {
      if (!cities.contains(widget.selectedCities[i].city)) {
        cities.add(widget.selectedCities[i].city);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffABCFF2), Color(0xff9AC6F3)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    // Create a size variable for the media query
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Home',
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Colors.blue[800],
                size: 20,
              ),
              const SizedBox(width: 6),
              const Text(
                'Talisay City',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              fetchWeatherData();
              _animationController.forward(from: 0.0);
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
              Text(
                currentDate,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                width: size.width,
                height: 200,
                decoration: BoxDecoration(
                    color: myConstants.primaryColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: myConstants.primaryColor.withValues(alpha: .5),
                        offset: const Offset(0, 25),
                        blurRadius: 10,
                        spreadRadius: -12,
                      )
                    ]),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -40,
                      left: 20,
                      child: imageUrl == ''
                          ? const Text('')
                          : Icon(
                              _getWeatherIcon(imageUrl),
                              size: 150,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 20,
                      child: Text(
                        weatherStateName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              temperature.toString(),
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()..shader = linearGradient,
                              ),
                            ),
                          ),
                          Text(
                            'o',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = linearGradient,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    weatherItem(
                      text: 'Wind Speed',
                      value: windSpeed,
                      unit: 'km/h',
                      imageUrl: 'assets/windspeed.png',
                      icon: Icons.air_rounded,
                    ),
                    weatherItem(
                      text: 'Humidity',
                      value: humidity,
                      unit: '',
                      imageUrl: 'assets/humidity.png',
                      icon: Icons.water_drop_outlined,
                    ),
                    weatherItem(
                      text: 'Max Temp',
                      value: maxTemp,
                      unit: 'C',
                      imageUrl: 'assets/max-temp.png',
                      icon: Icons.thermostat_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'Next 7 Days',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: myConstants.primaryColor),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: consolidatedWeatherList.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: consolidatedWeatherList.length,
                          itemBuilder: (BuildContext context, int index) {
                            String today =
                                DateTime.now().toString().substring(0, 10);
                            var selectedDay = consolidatedWeatherList[index]
                                ['applicable_date'];
                            var futureWeatherName =
                                consolidatedWeatherList[index]
                                    ['weather_state_name'];
                            var weatherUrl = _mapWeatherCondition(futureWeatherName)
                                .toLowerCase();

                            var parsedDate = DateTime.parse(
                                consolidatedWeatherList[index]
                                    ['applicable_date']);
                            var newDate = DateFormat('EEEE')
                                .format(parsedDate)
                                .substring(0, 3); //formatted date

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          DetailPage(
                                        consolidatedWeatherList:
                                            consolidatedWeatherList,
                                        selectedId: index,
                                        location: location,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        var offsetAnimation =
                                            animation.drive(tween);
                                        return SlideTransition(
                                            position: offsetAnimation,
                                            child: child);
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 500),
                                    ));
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                margin: const EdgeInsets.only(
                                    right: 20, bottom: 10, top: 10),
                                width: 80,
                                decoration: BoxDecoration(
                                    color: selectedDay == today
                                        ? myConstants.primaryColor
                                        : Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, 1),
                                        blurRadius: 5,
                                        color: selectedDay == today
                                            ? myConstants.primaryColor
                                            : Colors.black54.withValues(alpha: .2),
                                      ),
                                    ]),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      consolidatedWeatherList[index]['the_temp']
                                              .round()
                                              .toString() +
                                          "C",
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: selectedDay == today
                                            ? Colors.white
                                            : myConstants.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Icon(
                                      _getWeatherIcon(weatherUrl),
                                      color: selectedDay == today
                                          ? Colors.white
                                          : myConstants.primaryColor,
                                    ),
                                    Text(
                                      newDate,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: selectedDay == today
                                            ? Colors.white
                                            : myConstants.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }))
            ],
          ),
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String weatherState) {
    switch (weatherState) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'lightcloud':
        return Icons.wb_cloudy_rounded;
      case 'heavycloud':
        return Icons.cloud_rounded;
      case 'lightrain':
        return Icons.grain_rounded;
      case 'heavyrain':
        return Icons.water_rounded;
      case 'showers':
        return Icons.beach_access_rounded;
      case 'thunderstorm':
        return Icons.flash_on_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      default:
        return Icons.cloud_rounded;
    }
  }
}
