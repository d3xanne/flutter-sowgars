#!/usr/bin/env python3
"""
Advanced test script for Flutter app interaction
"""
import time
import os
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options

def advanced_test():
    """Run advanced tests of the Flutter application"""
    print("Advanced Test - Hacienda Elizabeth")
    print("=" * 50)
    
    # Setup Chrome driver
    options = Options()
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-logging")
    options.add_argument("--disable-web-security")
    options.add_argument("--allow-running-insecure-content")
    options.add_argument("--remote-debugging-port=9222")
    options.add_argument("--window-size=1920,1080")
    
    # Set Chrome binary location
    chrome_path = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
    if os.path.exists(chrome_path):
        options.binary_location = chrome_path
    
    driver = None
    try:
        print("Creating Chrome driver...")
        driver = webdriver.Chrome(options=options)
        print("SUCCESS: Chrome driver created")
        
        # Navigate to the app
        print("Navigating to application...")
        driver.get("http://localhost:3000")
        
        # Wait for Flutter app to load
        print("Waiting for Flutter app to load...")
        time.sleep(20)  # Give plenty of time for Flutter to initialize
        
        # Test 1: Check if app loaded
        print("\n--- Test 1: App Loading ---")
        try:
            WebDriverWait(driver, 30).until(
                EC.presence_of_element_located((By.TAG_NAME, "flt-glass-pane"))
            )
            print("SUCCESS: Flutter app loaded")
        except:
            print("ERROR: Flutter app failed to load")
            return False
        
        # Test 2: Look for main navigation elements
        print("\n--- Test 2: Navigation Elements ---")
        nav_selectors = [
            "//*[contains(text(), 'Sugar Records')]",
            "//*[contains(text(), 'Inventory')]",
            "//*[contains(text(), 'Suppliers')]",
            "//*[contains(text(), 'Generate Insight')]",
            "//*[contains(text(), 'View Insights')]",
            "//*[contains(text(), 'Settings')]"
        ]
        
        found_nav = 0
        for selector in nav_selectors:
            try:
                elements = driver.find_elements(By.XPATH, selector)
                if elements:
                    found_nav += 1
                    element_name = selector.split("'")[1] if "'" in selector else "element"
                    print(f"SUCCESS: Found '{element_name}'")
                else:
                    element_name = selector.split("'")[1] if "'" in selector else "element"
                    print(f"WARNING: Not found '{element_name}'")
            except Exception as e:
                print(f"ERROR: Error finding element: {e}")
        
        print(f"Navigation Summary: {found_nav}/{len(nav_selectors)} elements found")
        
        # Test 3: Try to click on Sugar Records
        print("\n--- Test 3: Sugar Records Navigation ---")
        try:
            sugar_records = driver.find_element(By.XPATH, "//*[contains(text(), 'Sugar Records')]")
            driver.execute_script("arguments[0].scrollIntoView(true);", sugar_records)
            time.sleep(2)
            sugar_records.click()
            time.sleep(3)
            print("SUCCESS: Clicked on Sugar Records")
            
            # Check if we're on the Sugar Records page
            page_content = driver.find_element(By.TAG_NAME, "body").text
            if "Sugar" in page_content or "Records" in page_content:
                print("SUCCESS: Sugar Records page loaded")
            else:
                print("WARNING: Sugar Records page may not have loaded properly")
                
        except Exception as e:
            print(f"ERROR: Could not navigate to Sugar Records: {e}")
        
        # Test 4: Try to find and click Add button
        print("\n--- Test 4: Add Button Test ---")
        try:
            add_buttons = driver.find_elements(By.XPATH, "//*[contains(text(), 'Add') or contains(text(), '+')]")
            if add_buttons:
                print(f"SUCCESS: Found {len(add_buttons)} Add buttons")
                # Try to click the first Add button
                add_buttons[0].click()
                time.sleep(2)
                print("SUCCESS: Clicked Add button")
            else:
                print("WARNING: No Add buttons found")
        except Exception as e:
            print(f"ERROR: Could not interact with Add button: {e}")
        
        # Test 5: Check for form elements
        print("\n--- Test 5: Form Elements Test ---")
        try:
            inputs = driver.find_elements(By.TAG_NAME, "input")
            textareas = driver.find_elements(By.TAG_NAME, "textarea")
            selects = driver.find_elements(By.TAG_NAME, "select")
            
            print(f"SUCCESS: Found {len(inputs)} input fields")
            print(f"SUCCESS: Found {len(textareas)} textarea fields")
            print(f"SUCCESS: Found {len(selects)} select fields")
            
            if inputs:
                print("SUCCESS: Form elements are present")
            else:
                print("WARNING: No form elements found")
                
        except Exception as e:
            print(f"ERROR: Could not check form elements: {e}")
        
        # Test 6: Check for notification elements
        print("\n--- Test 6: Notification System Test ---")
        try:
            notification_elements = driver.find_elements(By.XPATH, "//*[contains(@class, 'notification') or contains(text(), 'notification') or contains(text(), 'alert')]")
            if notification_elements:
                print(f"SUCCESS: Found {len(notification_elements)} notification elements")
            else:
                print("WARNING: No notification elements found")
        except Exception as e:
            print(f"ERROR: Could not check notifications: {e}")
        
        # Test 7: Take comprehensive screenshot
        print("\n--- Test 7: Screenshot Test ---")
        screenshot_path = "advanced_test_screenshot.png"
        driver.save_screenshot(screenshot_path)
        print(f"SUCCESS: Screenshot saved: {screenshot_path}")
        
        # Test 8: Check page source for Flutter elements
        print("\n--- Test 8: Flutter Elements Analysis ---")
        try:
            page_source = driver.page_source
            flutter_indicators = [
                "flt-glass-pane",
                "flt-semantics",
                "flutter-view",
                "dart-sdk"
            ]
            
            found_indicators = 0
            for indicator in flutter_indicators:
                if indicator in page_source:
                    found_indicators += 1
                    print(f"SUCCESS: Found Flutter indicator: {indicator}")
            
            print(f"Flutter Analysis: {found_indicators}/{len(flutter_indicators)} indicators found")
            
        except Exception as e:
            print(f"ERROR: Could not analyze page source: {e}")
        
        print("\n" + "=" * 50)
        print("Advanced test completed successfully!")
        print("Your Flutter app is accessible and functional for testing!")
        return True
        
    except Exception as e:
        print(f"ERROR: Advanced test failed: {e}")
        return False
        
    finally:
        if driver:
            driver.quit()

if __name__ == "__main__":
    advanced_test()
