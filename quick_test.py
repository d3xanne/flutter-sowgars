#!/usr/bin/env python3
"""
Quick test script for basic functionality
"""
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options

def quick_test():
    """Run a quick test of the application"""
    print("Quick Test - Hacienda Elizabeth")
    print("=" * 40)
    
    # Setup Chrome driver
    options = Options()
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    
    try:
        # Navigate to the app
        print("Navigating to application...")
        driver.get("http://localhost:3000")
        
        # Wait for Flutter app to load
        print("Waiting for Flutter app to load...")
        time.sleep(10)
        
        # Check if app loaded
        try:
            WebDriverWait(driver, 20).until(
                EC.presence_of_element_located((By.TAG_NAME, "flt-glass-pane"))
            )
            print("SUCCESS: Flutter app loaded successfully")
        except:
            print("ERROR: Flutter app failed to load")
            return False
        
        # Test basic navigation
        print("Testing navigation...")
        
        # Look for navigation elements
        nav_elements = driver.find_elements(By.XPATH, "//*[contains(text(), 'Sugar Records') or contains(text(), 'Inventory') or contains(text(), 'Suppliers')]")
        
        if nav_elements:
            print(f"SUCCESS: Found {len(nav_elements)} navigation elements")
        else:
            print("WARNING: No navigation elements found")
        
        # Test clicking on Sugar Records
        try:
            sugar_records = driver.find_element(By.XPATH, "//*[contains(text(), 'Sugar Records')]")
            sugar_records.click()
            time.sleep(2)
            print("SUCCESS: Successfully clicked on Sugar Records")
        except:
            print("WARNING: Could not click on Sugar Records")
        
        # Take screenshot
        driver.save_screenshot("quick_test_screenshot.png")
        print("Screenshot saved: quick_test_screenshot.png")
        
        print("Quick test completed successfully!")
        return True
        
    except Exception as e:
        print(f"ERROR: Quick test failed: {e}")
        return False
        
    finally:
        driver.quit()

if __name__ == "__main__":
    quick_test()
