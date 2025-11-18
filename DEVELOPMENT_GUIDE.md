# Development Configuration for Sowgars Sugar Monitoring System

## Quick Start Commands

### Run System
```bash
# Option 1: Use the batch script (Windows)
run_system.bat

# Option 2: Manual commands
flutter clean
flutter pub get
flutter run -d chrome
```

### Troubleshooting Commands
```bash
# Check Flutter installation
flutter doctor

# Check for issues
flutter analyze

# Clean and rebuild
flutter clean
flutter pub get
flutter run -d chrome
```

## Common Issues & Solutions

### 1. Compilation Errors
- **Solution**: Run `flutter clean` then `flutter pub get`
- **Cause**: Cached build files or dependency conflicts

### 2. setState After Dispose
- **Solution**: Added `mounted` checks in all StatefulWidgets
- **Prevention**: Use SafeStateMixin for new widgets

### 3. Layout Overflow
- **Solution**: Use `Expanded`, `Flexible`, or `SingleChildScrollView`
- **Prevention**: Test on different screen sizes

### 4. Chrome Connection Issues
- **Solution**: Try different port: `flutter run -d chrome --web-port=8081`
- **Alternative**: Use `flutter run -d web-server --web-port=8080`

## Performance Optimizations Applied

1. **Error Handling**: Global error handler prevents crashes
2. **State Management**: Mounted checks prevent memory leaks
3. **Performance**: Debouncing and memoization for expensive operations
4. **Layout**: Responsive design with overflow protection

## Development Tips

1. **Hot Reload**: Use `r` in terminal for quick updates
2. **Hot Restart**: Use `R` in terminal for full restart
3. **Debug Mode**: Check browser console for detailed errors
4. **Performance**: Use Flutter DevTools for performance monitoring

## Production Deployment

```bash
# Build for web
flutter build web

# Serve locally
cd build/web
python -m http.server 8080
```

## System Requirements

- Flutter SDK 3.0+
- Chrome browser
- Windows 10/11
- 4GB RAM minimum
- Internet connection (for Supabase)
