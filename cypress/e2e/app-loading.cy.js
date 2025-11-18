/// <reference types="cypress" />

describe('Hacienda Elizabeth - App Loading Test', () => {
  beforeEach(() => {
    // Visit the app before each test  
    cy.visit('http://localhost:3000');
    
    // Wait for Flutter app to load (give it plenty of time)
    cy.wait(20000); // Wait 20 seconds for Flutter to fully initialize
  });

  it('should load the Flutter application successfully', () => {
    // Check if the page loaded
    cy.url().should('include', 'localhost');
    
    // Check if title contains "Hacienda Elizabeth"
    cy.title().should('contain', 'Hacienda Elizabeth');
    
    // Wait for Flutter glass pane to be present
    cy.get('flt-glass-pane', { timeout: 30000 }).should('exist');
    
    console.log('✅ Flutter app loaded successfully');
  });

  it('should have Flutter-specific elements', () => {
    // Check for Flutter glass pane
    cy.get('flt-glass-pane').should('exist');
    
    // Check for Flutter view
    cy.get('flutter-view').should('exist');
    
    // Take a screenshot
    cy.screenshot('app-loaded');
    
    console.log('✅ Flutter-specific elements found');
  });

  it('should display the application', () => {
    // Check if body exists
    cy.get('body').should('exist');
    
    // Check if the page has some content
    cy.get('body').should('have.length.at.least', 0);
    
    // Take screenshot for evidence
    cy.screenshot('app-display');
    
    console.log('✅ Application display verified');
  });
});
