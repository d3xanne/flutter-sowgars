// IMPROVE THIS FILE: lib/models/city.dart
class City {
  final String city;
  final bool isDefault;
  bool isSelected;

  City({
    required this.city,
    this.isDefault = false,
    this.isSelected = false,
  });

  // Improved copyWith method with better type safety
  City copyWith({
    String? city,
    bool? isDefault,
    bool? isSelected,
  }) {
    return City(
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Expanded city list with more options
  static List<City> get citiesList => [
        City(city: 'Talisay City', isDefault: true),
        City(city: 'Bacolod City'),
        City(city: 'Silay City'),
        City(city: 'Victorias City'),
        City(city: 'Cadiz City'),
        City(city: 'Sagay City'),
        City(city: 'Escalante City'),
        City(city: 'San Carlos City'),
        City(city: 'Kabankalan City'),
        City(city: 'Himamaylan City'),
        City(city: 'Manila'),
        City(city: 'Cebu City'),
        City(city: 'Davao City'),
        City(city: 'Iloilo City'),
        City(city: 'Cagayan de Oro'),
        // Add more cities as needed
      ];

  // Improved method to get selected cities
  static List<City> getSelectedCities() {
    return citiesList.where((city) => city.isSelected).toList();
  }

  // New method to find a city by name
  static City? findCityByName(String name) {
    try {
      return citiesList.firstWhere((city) => city.city == name);
    } catch (e) {
      return null;
    }
  }

  // New method to get default city
  static City getDefaultCity() {
    return citiesList.firstWhere((city) => city.isDefault);
  }
}
