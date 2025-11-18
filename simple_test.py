#!/usr/bin/env python3
"""
Simple test script for basic functionality
"""
import time
import os
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options

def simple_test():
    """Run a simple test of the application"""
    print("Simple Test - Hacienda Elizabeth")
    print("=" * 40)
    
    # Setup Chrome driver with better options
    options = Options()
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-logging")
    options.add_argument("--disable-web-security")
    options.add_argument("--allow-running-insecure-content")
    options.add_argument("--remote-debugging-port=9222")
    
    # Try to find Chrome executable
    chrome_paths = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    ]
    
    chrome_path = None
    for path in chrome_paths:
        if os.path.exists(path):
            chrome_path = path
            break
    
    if chrome_path:
        options.binary_location = chrome_path
        print(f"Found Chrome at: {chrome_path}")
    else:
        print("Chrome not found in standard locations")
    
    driver = None
    try:
        # Try to create driver
        print("Creating Chrome driver...")
        driver = webdriver.Chrome(options=options)
        print("SUCCESS: Chrome driver created")
        
        # Navigate to the app
        print("Navigating to application...")
        driver.get("http://localhost:3000")
        
        # Wait for page to load
        print("Waiting for page to load...")
        time.sleep(15)  # Give more time for Flutter to load
        
        # Check page title
        title = driver.title
        print(f"Page title: {title}")
        
        # Check if Flutter app loaded
        try:
            # Look for Flutter-specific elements
            flutter_elements = driver.find_elements(By.TAG_NAME, "flt-glass-pane")
            if flutter_elements:
                print("SUCCESS: Flutter app elements found")
            else:
                print("WARNING: Flutter app elements not found")
        except Exception as e:
            print(f"WARNING: Error checking Flutter elements: {e}")
        
        # Look for any text content
        try:
            body_text = driver.find_element(By.TAG_NAME, "body").text
            if body_text:
                print(f"SUCCESS: Page content loaded ({len(body_text)} characters)")
                print(f"First 200 characters: {body_text[:200]}")
            else:
                print("WARNING: No text content found")
        except Exception as e:
            print(f"WARNING: Error getting page content: {e}")
        
        # Take screenshot
        screenshot_path = "simple_test_screenshot.png"
        driver.save_screenshot(screenshot_path)
        print(f"Screenshot saved: {screenshot_path}")
        
        print("Simple test completed successfully!")
        return True
        
    except Exception as e:
        print(f"ERROR: Simple test failed: {e}")
        return False
        
    finally:
        if driver:
            driver.quit()

if __name__ == "__main__":
    simple_test()
