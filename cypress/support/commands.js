// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************

// Custom command to wait for Flutter to initialize
Cypress.Commands.add('waitForFlutter', () => {
  cy.get('flt-glass-pane', { timeout: 30000 }).should('exist');
});

// Custom command to check if Flutter app is loaded
Cypress.Commands.add('verifyFlutterApp', () => {
  cy.get('flt-glass-pane').should('exist');
  cy.get('flutter-view').should('exist');
  cy.title().should('contain', 'Hacienda Elizabeth');
});

// Custom command to take screenshot with timestamp
Cypress.Commands.add('screenshotWithTime', (name) => {
  const timestamp = Cypress.moment().format('YYYY-MM-DD_HH-mm-ss');
  cy.screenshot(`${name}_${timestamp}`);
});
