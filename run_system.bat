@echo off
echo Starting Sowgars Sugar Monitoring System...
echo.

echo [1/4] Cleaning previous builds...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Clean failed
    pause
    exit /b 1
)

echo [2/4] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Pub get failed
    pause
    exit /b 1
)

echo [3/4] Analyzing code...
call flutter analyze
if %errorlevel% neq 0 (
    echo WARNING: Code analysis found issues
    echo Continuing anyway...
)

echo [4/4] Running application...
echo.
echo Starting Chrome browser...
call flutter run -d chrome --web-port=8080

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Application failed to start
    echo.
    echo Troubleshooting steps:
    echo 1. Make sure Chrome is installed
    echo 2. Check if port 8080 is available
    echo 3. Try running: flutter doctor
    echo.
    pause
    exit /b 1
)

echo.
echo Application started successfully!
echo Open your browser to: http://localhost:8080
pause
