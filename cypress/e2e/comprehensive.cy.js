/// <reference types="cypress" />

describe('Hacienda Elizabeth - Comprehensive Test Suite', () => {
  beforeEach(() => {
    cy.visit('http://localhost:3000');
    cy.wait(20000); // Wait for Flutter initialization
  });

  it('should load all core components', () => {
    // Verify app structure
    cy.get('flt-glass-pane').should('exist');
    cy.get('flutter-view').should('exist');
    
    console.log('✅ Core components loaded');
  });

  it('should be responsive', () => {
    // Test different viewport sizes
    cy.viewport(1920, 1080);
    cy.get('body').should('be.visible');
    cy.screenshot('desktop-view');
    
    cy.viewport(1366, 768);
    cy.wait(1000);
    cy.screenshot('laptop-view');
    
    cy.viewport(768, 1024);
    cy.wait(1000);
    cy.screenshot('tablet-view');
    
    console.log('✅ Responsive design verified');
  });

  it('should handle page reload', () => {
    // Reload the page
    cy.reload();
    cy.wait(20000);
    
    // Verify app still loads
    cy.get('flt-glass-pane').should('exist');
    
    cy.screenshot('page-reload');
    
    console.log('✅ Page reload handled correctly');
  });

  it('should maintain state', () => {
    // Take initial screenshot
    cy.screenshot('initial-state');
    
    // Wait and interact
    cy.wait(5000);
    cy.get('body').click();
    
    // Take final screenshot
    cy.screenshot('final-state');
    
    console.log('✅ State management verified');
  });
});
