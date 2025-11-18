// IMPROVE THIS FILE: lib/ui/welcome.dart
import 'package:flutter/material.dart';
import 'package:sample/models/city.dart';
import 'package:sample/models/constants.dart';
import 'package:sample/ui/homes.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with SingleTickerProviderStateMixin {
  late List<City> _filteredCities;
  late List<City> _allCities;
  final Constants _constants = Constants();
  final double _itemHeight = 60.0;
  final EdgeInsets _itemPadding = const EdgeInsets.symmetric(horizontal: 16);
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    // Initialize cities
    _allCities = City.citiesList
        .where((city) => !city.isDefault)
        .map((city) => city.copyWith())
        .toList();
    _filteredCities = List.from(_allCities);

    // Add search listener
    _searchController.addListener(_filterCities);
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = List.from(_allCities);
      } else {
        _filteredCities = _allCities
            .where((city) => city.city.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCities = _filteredCities.where((c) => c.isSelected).toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Cities'),
        centerTitle: true,
        backgroundColor: _constants.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _constants.primaryColor.withValues(alpha: 0.1),
              ),
              child: Column(
                children: [
                  Text(
                    'Select cities to monitor weather information',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search cities...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredCities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_city_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No cities found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      itemCount: _filteredCities.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _CityListItem(
                        city: _filteredCities[index],
                        onTap: () => _toggleCitySelection(index),
                        constants: _constants,
                        height: _itemHeight,
                        padding: _itemPadding,
                      ),
                    ),
            ),
            // Selected cities counter
            if (selectedCities.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: _constants.primaryColor.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedCities.length} ${selectedCities.length == 1 ? 'city' : 'cities'} selected',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _constants.primaryColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          for (var city in _filteredCities) {
                            city.isSelected = false;
                          }
                          for (var city in _allCities) {
                            city.isSelected = false;
                          }
                        });
                      },
                      icon: const Icon(Icons.clear_all_rounded),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: _constants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.pin_drop_rounded),
        label: const Text('View Weather'),
        backgroundColor: _constants.secondaryColor,
        onPressed: () => _navigateToHomes(context, selectedCities),
      ),
    );
  }

  void _toggleCitySelection(int index) {
    final cityName = _filteredCities[index].city;

    // Update both filtered and all cities lists
    setState(() {
      _filteredCities[index] = _filteredCities[index].copyWith(
        isSelected: !_filteredCities[index].isSelected,
      );

      // Find and update the same city in the all cities list
      final allCitiesIndex = _allCities.indexWhere((c) => c.city == cityName);
      if (allCitiesIndex != -1) {
        _allCities[allCitiesIndex] = _allCities[allCitiesIndex].copyWith(
          isSelected: !_allCities[allCitiesIndex].isSelected,
        );
      }
    });
  }

  void _navigateToHomes(BuildContext context, List<City> selectedCities) {
    if (selectedCities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one city'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Get the default city (Talisay)
    final defaultCity = City.getDefaultCity();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Homes(
          selectedCities: [defaultCity, ...selectedCities],
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

class _CityListItem extends StatelessWidget {
  final City city;
  final VoidCallback onTap;
  final Constants constants;
  final double height;
  final EdgeInsets padding;

  const _CityListItem({
    required this.city,
    required this.onTap,
    required this.constants,
    required this.height,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: city.isSelected
            ? BorderSide(
                color: constants.secondaryColor.withValues(alpha: 0.8),
                width: 1.5,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: height,
          padding: padding,
          child: Row(
            children: [
              Checkbox(
                value: city.isSelected,
                onChanged: (_) => onTap(),
                activeColor: constants.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.location_city_rounded,
                color: city.isSelected ? constants.primaryColor : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  city.city,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight:
                        city.isSelected ? FontWeight.bold : FontWeight.w500,
                    color: city.isSelected
                        ? constants.primaryColor
                        : theme.textTheme.titleMedium?.color,
                  ),
                ),
              ),
              if (city.isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: constants.secondaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
