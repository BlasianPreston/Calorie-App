#!/usr/bin/env python3
"""
Simple test script to verify backend endpoints are working
"""
import requests
import json

BASE_URL = "http://127.0.0.1:8000"

def test_endpoint(endpoint, method="GET", data=None):
    """Test a single endpoint"""
    url = f"{BASE_URL}{endpoint}"
    print(f"\nTesting {method} {endpoint}")
    
    try:
        if method == "GET":
            response = requests.get(url)
        elif method == "POST":
            response = requests.post(url, json=data)
        
        print(f"Status: {response.status_code}")
        if response.status_code < 400:
            print(f"Response: {json.dumps(response.json(), indent=2)}")
        else:
            print(f"Error: {response.text}")
        return response.status_code < 400
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    print("Testing Calorie Tracking Backend API")
    print("=" * 40)
    
    # Test basic endpoints
    test_endpoint("/")
    test_endpoint("/health")
    
    # Test auth endpoints
    test_endpoint("/auth/signup", "POST", {
        "email": "test@example.com",
        "password": "password123",
        "name": "Test User"
    })
    
    test_endpoint("/auth/login", "POST", {
        "email": "test@example.com",
        "password": "password123"
    })
    
    # Test user profile
    test_endpoint("/user/profile")
    
    # Test meal endpoints
    test_endpoint("/meals/history")
    
    print("\n" + "=" * 40)
    print("Backend test completed!")

if __name__ == "__main__":
    main()
