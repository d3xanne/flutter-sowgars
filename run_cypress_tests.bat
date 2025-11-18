@echo off
echo ========================================
echo Running Cypress Tests for Hacienda Elizabeth
echo ========================================
echo.
echo Flutter app should be running on http://localhost:3000
echo.
echo Running comprehensive test suite...
"C:\Program Files\nodejs\npx.cmd" cypress run --spec "cypress/e2e/app-loading.cy.js"
echo.
echo Test completed!
pause
