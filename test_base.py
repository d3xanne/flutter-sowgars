"""
Base test class for Selenium testing
"""
import time
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
from test_config import TestConfig

class BaseTest:
    """Base test class with common functionality"""
    
    @pytest.fixture(autouse=True)
    def setup(self):
        """Setup for each test"""
        # Setup Chrome driver
        service = Service(ChromeDriverManager().install())
        self.driver = webdriver.Chrome(service=service, options=TestConfig.get_chrome_options())
        self.driver.implicitly_wait(TestConfig.IMPLICIT_WAIT)
        self.wait = WebDriverWait(self.driver, TestConfig.EXPLICIT_WAIT)
        self.actions = ActionChains(self.driver)
        
        # Navigate to the application
        self.driver.get(TestConfig.BASE_URL)
        
        # Wait for Flutter app to load
        self.wait_for_flutter_app()
        
        yield
        
        # Cleanup
        self.driver.quit()
    
    def wait_for_flutter_app(self):
        """Wait for Flutter app to load completely"""
        try:
            # Wait for the main app container
            self.wait.until(EC.presence_of_element_located((By.TAG_NAME, "flt-glass-pane")))
            time.sleep(3)  # Additional wait for Flutter to initialize
            print("✅ Flutter app loaded successfully")
        except Exception as e:
            print(f"⚠️ Flutter app loading timeout: {e}")
    
    def wait_for_element(self, locator, timeout=10):
        """Wait for element to be present and visible"""
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located(locator)
        )
    
    def wait_for_clickable(self, locator, timeout=10):
        """Wait for element to be clickable"""
        return WebDriverWait(self.driver, timeout).until(
            EC.element_to_be_clickable(locator)
        )
    
    def click_element(self, locator):
        """Click element with wait"""
        element = self.wait_for_clickable(locator)
        element.click()
        time.sleep(1)  # Small delay for UI updates
    
    def input_text(self, locator, text):
        """Input text into element"""
        element = self.wait_for_element(locator)
        element.clear()
        element.send_keys(text)
        time.sleep(0.5)
    
    def get_text(self, locator):
        """Get text from element"""
        element = self.wait_for_element(locator)
        return element.text
    
    def is_element_present(self, locator):
        """Check if element is present"""
        try:
            self.driver.find_element(*locator)
            return True
        except:
            return False
    
    def scroll_to_element(self, locator):
        """Scroll to element"""
        element = self.wait_for_element(locator)
        self.driver.execute_script("arguments[0].scrollIntoView(true);", element)
        time.sleep(1)
    
    def take_screenshot(self, name):
        """Take screenshot for debugging"""
        self.driver.save_screenshot(f"screenshots/{name}.png")
        print(f"📸 Screenshot saved: {name}.png")
