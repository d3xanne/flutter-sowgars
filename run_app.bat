@echo off
echo Starting Hacienda Elizabeth App...
echo.

echo Cleaning previous build...
flutter clean

echo.
echo Getting dependencies...
flutter pub get

echo.
echo Running app on Chrome...
flutter run -d chrome --web-port=8080

pause
