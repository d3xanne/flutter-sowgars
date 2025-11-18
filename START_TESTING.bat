@echo off
echo ==========================================
echo Cypress Testing Helper
echo ==========================================
echo.
echo Starting Cypress Test Runner...
echo.
echo Make sure your Flutter app is running on port 3000!
echo If not, run: flutter run -d chrome --web-port=3000
echo.
timeout /t 2 /nobreak > nul
start cmd /c "npx cypress open"
echo.
echo Cypress is opening now!
echo You should see the Cypress window appear shortly.
echo.
pause

