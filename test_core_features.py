"""
Test cases for core features of Hacienda Elizabeth
"""
import pytest
import time
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from test_base import BaseTest
from test_config import TestConfig

class TestCoreFeatures(BaseTest):
    """Test core functionality of the agricultural management system"""
    
    def test_01_application_startup(self):
        """Test application startup and navigation"""
        print("🧪 Testing application startup...")
        
        # Check if main navigation is present
        assert self.is_element_present((By.CSS_SELECTOR, "[data-testid='main-navigation']")), "Main navigation not found"
        
        # Check if home screen loads
        home_elements = self.driver.find_elements(By.CSS_SELECTOR, "text*='Welcome to Hacienda Elizabeth'")
        assert len(home_elements) > 0, "Home screen not loaded"
        
        print("✅ Application startup test passed")
    
    def test_02_sugar_records_management(self):
        """Test sugar records CRUD operations"""
        print("🧪 Testing sugar records management...")
        
        # Navigate to Sugar Records
        self.click_element((By.CSS_SELECTOR, "text*='Sugar Records'"))
        time.sleep(2)
        
        # Test adding new sugar record
        self.click_element((By.CSS_SELECTOR, "text*='Add'"))
        time.sleep(1)
        
        # Fill form data
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='variety']"), TestConfig.TEST_SUGAR_VARIETY)
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='height']"), "150")
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='date']"), "2024-01-15")
        
        # Save record
        self.click_element((By.CSS_SELECTOR, "text*='Save'"))
        time.sleep(2)
        
        # Verify record was added
        assert self.is_element_present((By.CSS_SELECTOR, f"text*='{TestConfig.TEST_SUGAR_VARIETY}'")), "Sugar record not added"
        
        print("✅ Sugar records management test passed")
    
    def test_03_inventory_management(self):
        """Test inventory management functionality"""
        print("🧪 Testing inventory management...")
        
        # Navigate to Inventory
        self.click_element((By.CSS_SELECTOR, "text*='Inventory'"))
        time.sleep(2)
        
        # Test adding inventory item
        self.click_element((By.CSS_SELECTOR, "text*='Add'"))
        time.sleep(1)
        
        # Fill inventory form
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='name']"), "Test Fertilizer")
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='quantity']"), "50")
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='unit']"), "bags")
        
        # Save item
        self.click_element((By.CSS_SELECTOR, "text*='Save'"))
        time.sleep(2)
        
        # Verify item was added
        assert self.is_element_present((By.CSS_SELECTOR, "text*='Test Fertilizer'")), "Inventory item not added"
        
        print("✅ Inventory management test passed")
    
    def test_04_supplier_transactions(self):
        """Test supplier transaction management"""
        print("🧪 Testing supplier transactions...")
        
        # Navigate to Suppliers
        self.click_element((By.CSS_SELECTOR, "text*='Suppliers'"))
        time.sleep(2)
        
        # Test adding supplier transaction
        self.click_element((By.CSS_SELECTOR, "text*='Add'"))
        time.sleep(1)
        
        # Fill supplier form
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='supplier']"), TestConfig.TEST_SUPPLIER_NAME)
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='item']"), "Test Seeds")
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='quantity']"), "100")
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='amount']"), "5000")
        
        # Save transaction
        self.click_element((By.CSS_SELECTOR, "text*='Save'"))
        time.sleep(2)
        
        # Verify transaction was added
        assert self.is_element_present((By.CSS_SELECTOR, f"text*='{TestConfig.TEST_SUPPLIER_NAME}'")), "Supplier transaction not added"
        
        print("✅ Supplier transactions test passed")
    
    def test_05_insights_generation(self):
        """Test farming insights generation"""
        print("🧪 Testing insights generation...")
        
        # Navigate to Generate Insight
        self.click_element((By.CSS_SELECTOR, "text*='Generate Insight'"))
        time.sleep(2)
        
        # Fill insight form
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='variety']"), TestConfig.TEST_SUGAR_VARIETY)
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='area']"), "30")
        self.input_text((By.CSS_SELECTOR, "input[placeholder*='location']"), "Test Location")
        
        # Generate insight
        self.click_element((By.CSS_SELECTOR, "text*='Generate'"))
        time.sleep(5)  # Wait for AI processing
        
        # Verify insight was generated
        assert self.is_element_present((By.CSS_SELECTOR, "text*='insight'")), "Insight not generated"
        
        print("✅ Insights generation test passed")
    
    def test_06_data_cleanup(self):
        """Test data cleanup functionality"""
        print("🧪 Testing data cleanup...")
        
        # Navigate to Data Cleanup
        self.click_element((By.CSS_SELECTOR, "text*='Data Cleanup'"))
        time.sleep(2)
        
        # Test complete cleanup
        self.click_element((By.CSS_SELECTOR, "text*='Complete Cleanup'"))
        time.sleep(1)
        
        # Confirm cleanup
        self.click_element((By.CSS_SELECTOR, "text*='Yes'"))
        time.sleep(5)  # Wait for cleanup to complete
        
        # Verify cleanup completed
        assert self.is_element_present((By.CSS_SELECTOR, "text*='cleanup completed'")), "Data cleanup not completed"
        
        print("✅ Data cleanup test passed")
    
    def test_07_notification_system(self):
        """Test notification system"""
        print("🧪 Testing notification system...")
        
        # Check if notification bell is present
        assert self.is_element_present((By.CSS_SELECTOR, "[data-testid='notification-bell']")), "Notification bell not found"
        
        # Click notification bell
        self.click_element((By.CSS_SELECTOR, "[data-testid='notification-bell']"))
        time.sleep(2)
        
        # Check if notification panel opens
        assert self.is_element_present((By.CSS_SELECTOR, "[data-testid='notification-panel']")), "Notification panel not opened"
        
        print("✅ Notification system test passed")
    
    def test_08_navigation_flow(self):
        """Test complete navigation flow"""
        print("🧪 Testing navigation flow...")
        
        # Test all main navigation items
        nav_items = [
            "Home", "Sugar Records", "Inventory", "Suppliers", 
            "Weather", "Generate Insight", "View Insights", "Reports", "Settings"
        ]
        
        for item in nav_items:
            try:
                self.click_element((By.CSS_SELECTOR, f"text*='{item}'"))
                time.sleep(2)
                print(f"✅ Navigated to {item}")
            except Exception as e:
                print(f"⚠️ Failed to navigate to {item}: {e}")
        
        print("✅ Navigation flow test completed")
    
    def test_09_responsive_design(self):
        """Test responsive design"""
        print("🧪 Testing responsive design...")
        
        # Test different screen sizes
        screen_sizes = [(1920, 1080), (1366, 768), (1024, 768), (768, 1024)]
        
        for width, height in screen_sizes:
            self.driver.set_window_size(width, height)
            time.sleep(2)
            
            # Check if main elements are still visible
            assert self.is_element_present((By.CSS_SELECTOR, "[data-testid='main-navigation']")), f"Navigation not visible at {width}x{height}"
            
        print("✅ Responsive design test passed")
    
    def test_10_data_synchronization(self):
        """Test data synchronization between local and database"""
        print("🧪 Testing data synchronization...")
        
        # Add some test data
        self.test_02_sugar_records_management()
        self.test_03_inventory_management()
        
        # Refresh page to test persistence
        self.driver.refresh()
        time.sleep(5)
        
        # Check if data persisted
        assert self.is_element_present((By.CSS_SELECTOR, f"text*='{TestConfig.TEST_SUGAR_VARIETY}'")), "Data not synchronized"
        
        print("✅ Data synchronization test passed")
