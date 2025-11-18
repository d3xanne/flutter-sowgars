# 🧪 Selenium Testing Guide for Hacienda Elizabeth

## Overview
This guide provides comprehensive Selenium testing setup for your Flutter agricultural management system.

## Prerequisites
- Python 3.8+
- Chrome browser installed
- Flutter app running on localhost:3000

## Quick Start

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Start Your Flutter App
```bash
flutter run -d chrome --web-port=3000
```

### 3. Run Quick Test
```bash
python quick_test.py
```

### 4. Run Full Test Suite
```bash
python run_tests.py
```

## Test Types

### Smoke Tests
```bash
python run_tests.py smoke
```

### Regression Tests
```bash
python run_tests.py regression
```

### UI Tests
```bash
python run_tests.py ui
```

### All Tests
```bash
python run_tests.py all
```

## Test Coverage

### ✅ Core Features Tested:
- **Application Startup** - App loads correctly
- **Sugar Records Management** - CRUD operations
- **Inventory Management** - Item tracking
- **Supplier Transactions** - Transaction management
- **Insights Generation** - AI-powered recommendations
- **Data Cleanup** - System reset functionality
- **Notification System** - Real-time alerts
- **Navigation Flow** - All screens accessible
- **Responsive Design** - Multiple screen sizes
- **Data Synchronization** - Local ↔ Database sync

## Test Reports

### HTML Report
- Location: `reports/test_report.html`
- Contains detailed test results and screenshots

### Allure Report
- Location: `reports/allure-report/index.html`
- Interactive test report with detailed analytics

## Screenshots
- Location: `screenshots/`
- Automatic screenshots on test failures
- Debug screenshots for troubleshooting

## Configuration

### Test Configuration (`test_config.py`)
- Base URL: `http://localhost:3000`
- Browser settings
- Timeouts
- Test data

### Browser Options
- Headless mode available
- Custom window sizes
- Chrome-specific optimizations for Flutter

## Troubleshooting

### Common Issues:

1. **Flutter App Not Loading**
   - Ensure app is running on port 3000
   - Check Flutter web compilation
   - Verify Chrome browser installation

2. **Element Not Found**
   - Increase wait times in `test_config.py`
   - Check Flutter app loading time
   - Verify element selectors

3. **Test Failures**
   - Check screenshots in `screenshots/`
   - Review test logs
   - Verify test data

### Debug Mode:
```python
# In test_config.py
HEADLESS = False  # Set to True for headless
```

## Test Data

### Default Test Data:
- Farm Name: "Hacienda Elizabeth Test"
- Sugar Variety: "Phil 2018"
- Supplier Name: "Test Supplier"

### Customizing Test Data:
Edit `test_config.py` to modify test data.

## Continuous Integration

### GitHub Actions Example:
```yaml
name: Selenium Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.8
    - name: Install dependencies
      run: pip install -r requirements.txt
    - name: Run tests
      run: python run_tests.py
```

## Best Practices

1. **Wait Strategies**
   - Use explicit waits over implicit waits
   - Wait for Flutter app to fully load
   - Add appropriate delays for UI updates

2. **Element Selection**
   - Use data-testid attributes when possible
   - Prefer text-based selectors for Flutter
   - Avoid fragile CSS selectors

3. **Test Organization**
   - Group related tests in classes
   - Use descriptive test names
   - Clean up test data after tests

4. **Error Handling**
   - Take screenshots on failures
   - Log detailed error messages
   - Implement retry mechanisms

## Performance Testing

### Load Testing:
```python
# Test with multiple concurrent users
def test_concurrent_users():
    # Implementation for load testing
    pass
```

### Memory Testing:
```python
# Monitor memory usage during tests
def test_memory_usage():
    # Implementation for memory testing
    pass
```

## Security Testing

### Authentication Testing:
```python
# Test login/logout functionality
def test_authentication():
    # Implementation for auth testing
    pass
```

### Data Validation:
```python
# Test input validation
def test_input_validation():
    # Implementation for validation testing
    pass
```

## Mobile Testing

### Responsive Design:
```python
# Test mobile viewport
def test_mobile_view():
    driver.set_window_size(375, 667)  # iPhone size
    # Test mobile-specific functionality
```

## API Testing Integration

### Backend Testing:
```python
# Test API endpoints
def test_api_endpoints():
    # Implementation for API testing
    pass
```

## Conclusion

This testing suite provides comprehensive coverage of your Hacienda Elizabeth agricultural management system, ensuring reliability and quality for your final defense presentation.

For questions or issues, refer to the test logs and screenshots in the `reports/` and `screenshots/` directories.
