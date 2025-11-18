#!/usr/bin/env python3
"""
Test execution script for Hacienda Elizabeth
"""
import os
import sys
import subprocess
import time
from pathlib import Path

def create_directories():
    """Create necessary directories"""
    directories = ['screenshots', 'reports', 'reports/allure-results']
    for directory in directories:
        Path(directory).mkdir(exist_ok=True)
    print("✅ Created test directories")

def install_dependencies():
    """Install required dependencies"""
    print("📦 Installing dependencies...")
    try:
        subprocess.run([sys.executable, '-m', 'pip', 'install', '-r', 'requirements.txt'], check=True)
        print("✅ Dependencies installed successfully")
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to install dependencies: {e}")
        return False
    return True

def run_flutter_app():
    """Start Flutter app in background"""
    print("🚀 Starting Flutter app...")
    try:
        # Start Flutter app
        process = subprocess.Popen(
            ['flutter', 'run', '-d', 'chrome', '--web-port=3000'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        
        # Wait for app to start
        time.sleep(30)
        print("✅ Flutter app started")
        return process
    except Exception as e:
        print(f"❌ Failed to start Flutter app: {e}")
        return None

def run_tests(test_type="all"):
    """Run tests based on type"""
    print(f"🧪 Running {test_type} tests...")
    
    test_commands = {
        "smoke": ["pytest", "-m", "smoke", "-v"],
        "regression": ["pytest", "-m", "regression", "-v"],
        "integration": ["pytest", "-m", "integration", "-v"],
        "ui": ["pytest", "-m", "ui", "-v"],
        "all": ["pytest", "-v"]
    }
    
    if test_type not in test_commands:
        print(f"❌ Unknown test type: {test_type}")
        return False
    
    try:
        result = subprocess.run(test_commands[test_type], check=True)
        print("✅ Tests completed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Tests failed: {e}")
        return False

def generate_report():
    """Generate test report"""
    print("📊 Generating test report...")
    try:
        # Generate Allure report
        subprocess.run(['allure', 'generate', 'reports/allure-results', '-o', 'reports/allure-report', '--clean'], check=True)
        print("✅ Test report generated")
        print("📁 Report location: reports/allure-report/index.html")
    except Exception as e:
        print(f"⚠️ Failed to generate Allure report: {e}")

def main():
    """Main execution function"""
    print("🌾 Hacienda Elizabeth Test Suite")
    print("=" * 50)
    
    # Create directories
    create_directories()
    
    # Install dependencies
    if not install_dependencies():
        sys.exit(1)
    
    # Get test type from command line
    test_type = sys.argv[1] if len(sys.argv) > 1 else "all"
    
    # Start Flutter app
    flutter_process = run_flutter_app()
    if not flutter_process:
        sys.exit(1)
    
    try:
        # Run tests
        success = run_tests(test_type)
        
        # Generate report
        generate_report()
        
        if success:
            print("🎉 All tests passed!")
        else:
            print("❌ Some tests failed!")
            sys.exit(1)
            
    finally:
        # Cleanup
        if flutter_process:
            flutter_process.terminate()
            print("🧹 Flutter app stopped")

if __name__ == "__main__":
    main()
