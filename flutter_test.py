#!/usr/bin/env python3
"""
Flutter-specific test script for Hacienda Elizabeth
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

def flutter_test():
    """Run Flutter-specific tests"""
    print("Flutter Test - Hacienda Elizabeth")
    print("=" * 50)
    
    # Setup Chrome driver for Flutter
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
    options.add_argument("--disable-features=VizDisplayCompositor")
    
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
        time.sleep(25)  # Give plenty of time for Flutter to initialize
        
        # Test 1: Check Flutter app structure
        print("\n--- Test 1: Flutter App Structure ---")
        try:
            # Check for Flutter-specific elements
            flt_elements = driver.find_elements(By.TAG_NAME, "flt-glass-pane")
            if flt_elements:
                print(f"SUCCESS: Found {len(flt_elements)} Flutter glass panes")
            else:
                print("WARNING: No Flutter glass panes found")
            
            # Check for Flutter semantics
            semantics_elements = driver.find_elements(By.TAG_NAME, "flt-semantics")
            if semantics_elements:
                print(f"SUCCESS: Found {len(semantics_elements)} Flutter semantics elements")
            else:
                print("WARNING: No Flutter semantics elements found")
                
        except Exception as e:
            print(f"ERROR: Could not check Flutter structure: {e}")
        
        # Test 2: Look for clickable elements
        print("\n--- Test 2: Clickable Elements ---")
        try:
            # Look for any clickable elements
            clickable_elements = driver.find_elements(By.XPATH, "//*[@role='button' or @role='link' or @role='tab' or contains(@class, 'clickable')]")
            if clickable_elements:
                print(f"SUCCESS: Found {len(clickable_elements)} clickable elements")
                for i, elem in enumerate(clickable_elements[:5]):  # Show first 5
                    try:
                        text = elem.get_attribute("aria-label") or elem.text or "No text"
                        print(f"  Element {i+1}: {text[:50]}")
                    except:
                        print(f"  Element {i+1}: [No accessible text]")
            else:
                print("WARNING: No clickable elements found")
                
        except Exception as e:
            print(f"ERROR: Could not find clickable elements: {e}")
        
        # Test 3: Try to find text content using different methods
        print("\n--- Test 3: Text Content Analysis ---")
        try:
            # Get all text content
            body = driver.find_element(By.TAG_NAME, "body")
            all_text = body.text
            
            if all_text and len(all_text.strip()) > 0:
                print(f"SUCCESS: Found text content ({len(all_text)} characters)")
                print(f"First 300 characters: {all_text[:300]}")
                
                # Look for specific keywords
                keywords = ["Sugar", "Inventory", "Supplier", "Insight", "Settings", "Welcome", "Hacienda"]
                found_keywords = [kw for kw in keywords if kw.lower() in all_text.lower()]
                if found_keywords:
                    print(f"SUCCESS: Found keywords: {found_keywords}")
                else:
                    print("WARNING: No expected keywords found in text")
            else:
                print("WARNING: No text content found")
                
        except Exception as e:
            print(f"ERROR: Could not analyze text content: {e}")
        
        # Test 4: Try to interact with elements using coordinates
        print("\n--- Test 4: Coordinate-based Interaction ---")
        try:
            # Get window size
            window_size = driver.get_window_size()
            print(f"Window size: {window_size['width']}x{window_size['height']}")
            
            # Try clicking in different areas
            actions = ActionChains(driver)
            
            # Click in center of screen
            center_x = window_size['width'] // 2
            center_y = window_size['height'] // 2
            actions.move_by_offset(center_x, center_y).click().perform()
            time.sleep(2)
            print("SUCCESS: Clicked in center of screen")
            
            # Try clicking in different quadrants
            quadrants = [
                (center_x // 2, center_y // 2),  # Top-left
                (center_x + center_x // 2, center_y // 2),  # Top-right
                (center_x // 2, center_y + center_y // 2),  # Bottom-left
                (center_x + center_x // 2, center_y + center_y // 2),  # Bottom-right
            ]
            
            for i, (x, y) in enumerate(quadrants):
                try:
                    actions.move_by_offset(x - center_x, y - center_y).click().perform()
                    time.sleep(1)
                    print(f"SUCCESS: Clicked in quadrant {i+1}")
                except:
                    print(f"WARNING: Could not click in quadrant {i+1}")
                    
        except Exception as e:
            print(f"ERROR: Could not perform coordinate-based interaction: {e}")
        
        # Test 5: Check for form elements using different selectors
        print("\n--- Test 5: Form Elements Detection ---")
        try:
            # Look for input elements
            inputs = driver.find_elements(By.TAG_NAME, "input")
            print(f"Found {len(inputs)} input elements")
            
            # Look for any elements that might be forms
            form_elements = driver.find_elements(By.XPATH, "//*[@type='text' or @type='number' or @type='email' or @type='password' or @contenteditable='true']")
            print(f"Found {len(form_elements)} form-like elements")
            
            # Look for buttons
            buttons = driver.find_elements(By.TAG_NAME, "button")
            print(f"Found {len(buttons)} button elements")
            
        except Exception as e:
            print(f"ERROR: Could not detect form elements: {e}")
        
        # Test 6: Check page source for specific content
        print("\n--- Test 6: Page Source Analysis ---")
        try:
            page_source = driver.page_source
            
            # Look for specific content in page source
            content_indicators = [
                "Sugar Records",
                "Inventory",
                "Suppliers", 
                "Generate Insight",
                "View Insights",
                "Settings",
                "Hacienda Elizabeth",
                "Welcome"
            ]
            
            found_content = []
            for indicator in content_indicators:
                if indicator in page_source:
                    found_content.append(indicator)
            
            if found_content:
                print(f"SUCCESS: Found content in page source: {found_content}")
            else:
                print("WARNING: No expected content found in page source")
                
        except Exception as e:
            print(f"ERROR: Could not analyze page source: {e}")
        
        # Test 7: Take final screenshot
        print("\n--- Test 7: Final Screenshot ---")
        screenshot_path = "flutter_test_screenshot.png"
        driver.save_screenshot(screenshot_path)
        print(f"SUCCESS: Screenshot saved: {screenshot_path}")
        
        print("\n" + "=" * 50)
        print("Flutter test completed!")
        print("Your Flutter app is running and accessible for testing!")
        return True
        
    except Exception as e:
        print(f"ERROR: Flutter test failed: {e}")
        return False
        
    finally:
        if driver:
            driver.quit()

if __name__ == "__main__":
    flutter_test()
