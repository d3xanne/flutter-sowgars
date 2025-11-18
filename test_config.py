"""
Configuration file for Selenium testing
"""
import os
from selenium.webdriver.chrome.options import Options

class TestConfig:
    # Application URL
    BASE_URL = "http://localhost:3000"  # Your Flutter web app URL
    
    # Browser settings
    HEADLESS = False  # Set to True for headless testing
    WINDOW_SIZE = (1920, 1080)
    
    # Test data
    TEST_FARM_NAME = "Hacienda Elizabeth Test"
    TEST_SUGAR_VARIETY = "Phil 2018"
    TEST_SUPPLIER_NAME = "Test Supplier"
    
    # Timeouts
    IMPLICIT_WAIT = 10
    EXPLICIT_WAIT = 20
    
    @staticmethod
    def get_chrome_options():
        """Get Chrome options for testing"""
        options = Options()
        
        if TestConfig.HEADLESS:
            options.add_argument("--headless")
        
        options.add_argument(f"--window-size={TestConfig.WINDOW_SIZE[0]},{TestConfig.WINDOW_SIZE[1]}")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--disable-gpu")
        options.add_argument("--disable-extensions")
        options.add_argument("--disable-logging")
        options.add_argument("--disable-web-security")
        options.add_argument("--allow-running-insecure-content")
        
        # For Flutter web apps
        options.add_argument("--disable-features=VizDisplayCompositor")
        options.add_argument("--enable-features=NetworkService,NetworkServiceLogging")
        
        return options
