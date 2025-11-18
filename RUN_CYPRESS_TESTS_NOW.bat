@echo off
echo ============================================================
echo Cypress Testing for Hacienda Elizabeth
echo ============================================================
echo.
echo Your Flutter app should be running on http://localhost:3000
echo.
echo Starting Cypress tests...
echo This will take a few minutes. Please wait...
echo.
"C:\Program Files\nodejs\npx.cmd" cypress run --spec "cypress/e2e/app-loading.cy.js"
echo.
echo ============================================================
echo Tests completed!
echo.
echo Check results in:
echo - Screenshots: cypress\screenshots\
echo - Videos: cypress\videos\
echo ============================================================
pause
