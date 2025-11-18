const { exec } = require('child_process');

console.log('Starting Cypress test for app-loading...');
console.log('Make sure your Flutter app is running on http://localhost:3000\n');

exec('C:\\Program Files\\nodejs\\npx.cmd cypress run --spec "cypress/e2e/app-loading.cy.js" --headed', (error, stdout, stderr) => {
  if (error) {
    console.error(`Error: ${error.message}`);
    return;
  }
  
  if (stderr) {
    console.error(`Stderr: ${stderr}`);
  }
  
  console.log(stdout);
});

console.log('Test is running... This may take a few minutes.');
