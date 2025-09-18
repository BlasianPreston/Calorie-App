#!/usr/bin/env python3
"""
Test script to verify AI analysis is working correctly
"""
import requests
import json
import base64

def test_ai_analysis():
    """Test the AI analysis endpoint with a sample image"""
    
    # Create a simple test image (1x1 pixel PNG)
    # In a real test, you would use an actual food image
    test_image_data = b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\tpHYs\x00\x00\x0b\x13\x00\x00\x0b\x13\x01\x00\x9a\x9c\x18\x00\x00\x00\nIDATx\x9cc```\x00\x00\x00\x04\x00\x01\xdd\x8d\xb4\x1c\x00\x00\x00\x00IEND\xaeB`\x82'
    
    # Test the analysis endpoint
    url = "http://127.0.0.1:8000/meals/upload"
    
    files = {
        'image': ('test.png', test_image_data, 'image/png')
    }
    
    data = {
        'comments': 'Test banana image for AI analysis'
    }
    
    try:
        print("Testing AI analysis endpoint...")
        response = requests.post(url, files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ AI Analysis Response:")
            print(f"Description: {result['meal']['gemini_analysis']}")
            print(f"Calories: {result['meal']['calories']}")
            
            # Check if we got realistic calories
            calories = result['meal']['calories']
            if calories > 0 and calories < 1000:  # Reasonable range
                print("✅ Calories seem realistic")
            else:
                print("⚠️  Calories seem unrealistic")
                
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            
    except Exception as e:
        print(f"❌ Error testing AI: {e}")

if __name__ == "__main__":
    test_ai_analysis()
