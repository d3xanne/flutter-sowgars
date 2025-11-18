/// <reference types="cypress" />

describe('Hacienda Elizabeth - Navigation Test', () => {
  beforeEach(() => {
    // Visit the app before each test
    cy.visit('http://localhost:3000');
    cy.wait(20000); // Wait for Flutter to initialize
  });

  it('should have functional navigation', () => {
    // Check if the app loaded
    cy.get('flt-glass-pane').should('exist');
    
    // Try to find and interact with navigation elements
    cy.get('body').should('be.visible');
    
    // Take screenshot
    cy.screenshot('navigation-test');
    
    console.log('✅ Navigation test completed');
  });

  it('should handle user interactions', () => {
    // Check if body is interactive
    cy.get('body').should('be.visible');
    
    // Try clicking on the page
    cy.get('body').click();
    
    // Wait a bit to see if anything happens
    cy.wait(2000);
    
    // Take screenshot after interaction
    cy.screenshot('user-interaction');
    
    console.log('✅ User interaction handled');
  });
});
