@echo off
REM SonarQube Scanner Runner
REM This script runs the SonarScanner analysis for the flutter-sowgars project

echo Setting up SonarQube Scanner...
set SONAR_TOKEN=e0990c76a4e0bb81bf40c230c2afb4e6889b88db

echo Running SonarScanner analysis...
call ".\sonar-scanner-7.2.0.5079-windows-x64\bin\sonar-scanner.bat"

echo.
echo Analysis complete! Check results at: https://sonarcloud.io/dashboard?id=d3xanne_flutter-sowgars
pause

