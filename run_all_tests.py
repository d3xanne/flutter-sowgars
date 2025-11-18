#!/usr/bin/env python3
"""
Comprehensive test runner for Hacienda Elizabeth
"""
import subprocess
import sys
import time
import os
from datetime import datetime

def run_test(test_name, test_file):
    """Run a specific test and return results"""
    print(f"\n{'='*60}")
    print(f"Running {test_name}")
    print(f"{'='*60}")
    
    start_time = time.time()
    
    try:
        result = subprocess.run([sys.executable, test_file], 
                              capture_output=True, 
                              text=True, 
                              timeout=300)  # 5 minute timeout
        
        end_time = time.time()
        duration = end_time - start_time
        
        if result.returncode == 0:
            print(f"SUCCESS: {test_name} - PASSED ({duration:.2f}s)")
            return True, result.stdout, result.stderr, duration
        else:
            print(f"FAILED: {test_name} - FAILED ({duration:.2f}s)")
            return False, result.stdout, result.stderr, duration
            
    except subprocess.TimeoutExpired:
        print(f"TIMEOUT: {test_name} - TIMEOUT")
        return False, "", "Test timed out", 300
    except Exception as e:
        print(f"ERROR: {test_name} - ERROR: {e}")
        return False, "", str(e), 0

def generate_report(results):
    """Generate a test report"""
    report_file = f"test_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    
    with open(report_file, 'w') as f:
        f.write("HACIENDA ELIZABETH - TEST REPORT\n")
        f.write("=" * 50 + "\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        total_tests = len(results)
        passed_tests = sum(1 for result in results if result['passed'])
        failed_tests = total_tests - passed_tests
        
        f.write(f"SUMMARY:\n")
        f.write(f"Total Tests: {total_tests}\n")
        f.write(f"Passed: {passed_tests}\n")
        f.write(f"Failed: {failed_tests}\n")
        f.write(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%\n\n")
        
        f.write("DETAILED RESULTS:\n")
        f.write("-" * 30 + "\n")
        
        for result in results:
            status = "PASS" if result['passed'] else "FAIL"
            f.write(f"\n{result['name']} - {status} ({result['duration']:.2f}s)\n")
            f.write("-" * 20 + "\n")
            
            if result['stdout']:
                f.write("STDOUT:\n")
                f.write(result['stdout'])
                f.write("\n")
            
            if result['stderr']:
                f.write("STDERR:\n")
                f.write(result['stderr'])
                f.write("\n")
    
    print(f"\nTest report generated: {report_file}")
    return report_file

def main():
    """Main test runner"""
    print("HACIENDA ELIZABETH - COMPREHENSIVE TEST SUITE")
    print("=" * 60)
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Define tests to run
    tests = [
        ("Simple Connectivity Test", "simple_test.py"),
        ("Advanced Flutter Test", "advanced_test.py"),
        ("Flutter-Specific Test", "flutter_test.py"),
    ]
    
    results = []
    
    # Run each test
    for test_name, test_file in tests:
        if os.path.exists(test_file):
            passed, stdout, stderr, duration = run_test(test_name, test_file)
            results.append({
                'name': test_name,
                'passed': passed,
                'stdout': stdout,
                'stderr': stderr,
                'duration': duration
            })
        else:
            print(f"WARNING: Test file not found: {test_file}")
            results.append({
                'name': test_name,
                'passed': False,
                'stdout': "",
                'stderr': f"Test file not found: {test_file}",
                'duration': 0
            })
    
    # Generate report
    report_file = generate_report(results)
    
    # Print summary
    print(f"\n{'='*60}")
    print("TEST SUMMARY")
    print(f"{'='*60}")
    
    total_tests = len(results)
    passed_tests = sum(1 for result in results if result['passed'])
    failed_tests = total_tests - passed_tests
    
    print(f"Total Tests: {total_tests}")
    print(f"Passed: {passed_tests}")
    print(f"Failed: {failed_tests}")
    print(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%")
    
    if passed_tests == total_tests:
        print("\nALL TESTS PASSED! Your system is ready for testing!")
    else:
        print(f"\n{failed_tests} test(s) failed. Check the report for details.")
    
    print(f"\nDetailed report: {report_file}")
    print(f"Screenshots: Check the current directory for .png files")
    
    return passed_tests == total_tests

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
