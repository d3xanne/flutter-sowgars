# Hacienda Elizabeth - Sugarcane Farming System Setup Guide

## 🚀 Quick Start

Your Flutter environment is already set up and ready to go! Here's how to run the mobile app:

### Option 1: Run on Web Browser (Recommended for quick testing)
```bash
flutter run -d chrome
```
The app should automatically open in your Chrome browser.

### Option 2: Run on Windows Desktop
```bash
flutter run -d windows
```

### Option 3: Run on Android Device/Emulator
```bash
# First, check available devices
flutter devices

# If you have an Android device connected via USB:
flutter run -d <device-id>

# If you want to create an Android emulator:
flutter emulators --create --name my_android_emulator
flutter emulators --launch my_android_emulator
flutter run -d <emulator-id>
```

## 📱 About the App

This is a **Sugarcane Farming Management System** for Hacienda Elizabeth in Talisay City, Negros Occidental. The app includes:

### Key Features:
- **🏠 Home Dashboard** - Main overview with quick access buttons
- **🌾 Sugarcane Monitoring** - Track sugarcane growth and health
- **📦 Inventory Management** - Manage farming supplies and equipment
- **🏪 Supplier Management** - Track suppliers and transactions
- **🌤️ Weather Forecast** - Real-time weather data for farming decisions
- **📊 Insights & Analytics** - Data-driven farming insights
- **📈 Realtime Reports** - Live monitoring and reporting
- **🚨 Alerts System** - Important notifications and warnings

### Navigation:
- Use the **hamburger menu** (☰) in the top-left for full navigation
- **Quick access buttons** on the home screen for main features
- **Floating action button** for quick sugarcane monitoring

## 🛠️ Development Setup

### Prerequisites (Already Installed ✅)
- Flutter 3.35.6
- Dart 3.9.2
- Android SDK 35.0.1
- Android Studio 2025.1.4
- VS Code 1.100.2
- Chrome browser

### Project Structure:
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── screens/                  # Main app screens
├── services/                 # Backend services
├── state/                    # App state management
├── ui/                       # UI components
├── utils/                    # Utility functions
└── widgets/                  # Reusable widgets
```

### Dependencies:
- `supabase_flutter` - Backend database (currently disabled)
- `http` - API calls
- `shared_preferences` - Local storage
- `connectivity_plus` - Network connectivity
- `flutter_spinkit` - Loading animations
- `intl` - Internationalization

## 🔧 Configuration

### Supabase Integration (Optional)
The app supports Supabase for cloud data storage. To enable:

1. Create a Supabase project at https://supabase.com
2. Get your project URL and anon key
3. Uncomment the Supabase initialization code in `main.dart`
4. Add your credentials:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

### Local Development
The app works perfectly without Supabase using local storage for development and testing.

## 🚀 Running the App

### Start Development Server:
```bash
# Navigate to project directory
cd C:\Users\User\Desktop\lucky\tumabs\sowgars

# Get dependencies (already done)
flutter pub get

# Run on web
flutter run -d chrome

# Or run on Windows desktop
flutter run -d windows
```

### Hot Reload:
- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

## 📱 Testing on Mobile Devices

### Android Device:
1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter run -d <device-id>`

### Android Emulator:
1. Open Android Studio
2. Go to AVD Manager
3. Create a new Virtual Device
4. Start the emulator
5. Run: `flutter run -d <emulator-id>`

## 🐛 Troubleshooting

### Common Issues:
1. **"No devices found"** - Make sure you have a device connected or emulator running
2. **"Build failed"** - Run `flutter clean` then `flutter pub get`
3. **"Dependencies error"** - Check your internet connection and run `flutter pub get`

### Useful Commands:
```bash
flutter doctor -v          # Detailed environment check
flutter clean              # Clean build cache
flutter pub get            # Get dependencies
flutter devices            # List available devices
flutter emulators          # List available emulators
```

## 📞 Support

If you encounter any issues:
1. Check the Flutter documentation: https://flutter.dev/docs
2. Run `flutter doctor -v` for detailed diagnostics
3. Check the console output for specific error messages

---

**Happy Farming! 🌾** - Your Sugarcane Management System is ready to help optimize Hacienda Elizabeth's operations.
