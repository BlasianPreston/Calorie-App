from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import uuid
import base64
from datetime import datetime
from dotenv import load_dotenv
import google.generativeai as genai

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app, origins=['http://127.0.0.1:*', 'http://localhost:*'], supports_credentials=True)  # Enable CORS for Flutter app

# Configuration
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-secret-key-here')
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# Configure Gemini AI
genai.configure(api_key=os.getenv('GEMINI_API_KEY'))

# In-memory storage for demo (use database in production)
meals_db = []
users_db = {}

# Initialize Gemini model
model = genai.GenerativeModel('gemini-1.5-flash')

def analyze_meal_image(image_data, comments=None):
    """Analyze meal image using Gemini AI to estimate calories"""
    try:
        # Convert image to base64 for Gemini
        image_base64 = base64.b64encode(image_data).decode('utf-8')
        
        prompt = f"""
        Analyze this food image and provide:
        1. A detailed description of the food items visible
        2. An estimate of the total calories in the meal
        3. Breakdown of major food components and their approximate calorie contributions
        
        Please be as accurate as possible with calorie estimation.
        Return the response in JSON format with keys: description, total_calories, breakdown, confidence_score.
        
        {f"Additional context from user: {comments}" if comments else ""}
        """
        
        # Generate content using Gemini
        response = model.generate_content([
            prompt,
            {
                "mime_type": "image/jpeg",
                "data": image_base64
            }
        ])
        
        # Parse response (in a real app, you'd want more robust parsing)
        result = {
            "description": "AI analysis of the meal",
            "total_calories": 500,  # Placeholder - would parse from actual response
            "breakdown": "Various food items detected",
            "confidence_score": 0.85
        }
        
        return result
    except Exception as e:
        print(f"Error analyzing image: {e}")
        return {
            "description": "Unable to analyze image",
            "total_calories": 0,
            "breakdown": "Analysis failed",
            "confidence_score": 0.0
        }

@app.route('/')
def home():
    return jsonify({'message': 'Calorie Tracking API is running'})

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

@app.route('/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    
    # Simple demo authentication
    if email and password:
        user_id = str(uuid.uuid4())
        users_db[user_id] = {
            'email': email,
            'name': email.split('@')[0],
            'created_at': datetime.now().isoformat()
        }
        
        return jsonify({
            'message': 'Login successful',
            'token': f'demo_token_{user_id}',
            'user': users_db[user_id]
        })
    
    return jsonify({'message': 'Invalid credentials'}), 401

@app.route('/auth/signup', methods=['POST'])
def signup():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    name = data.get('name')
    
    if email and password and name:
        user_id = str(uuid.uuid4())
        users_db[user_id] = {
            'email': email,
            'name': name,
            'created_at': datetime.now().isoformat()
        }
        
        return jsonify({
            'message': 'Signup successful',
            'token': f'demo_token_{user_id}',
            'user': users_db[user_id]
        })
    
    return jsonify({'message': 'Missing required fields'}), 400

@app.route('/meals/upload', methods=['POST'])
def upload_meal():
    if 'image' not in request.files:
        return jsonify({'message': 'No image file provided'}), 400
    
    file = request.files['image']
    comments = request.form.get('comments', '')
    
    if file.filename == '':
        return jsonify({'message': 'No image selected'}), 400
    
    try:
        # Read image data
        image_data = file.read()
        
        # Analyze with Gemini AI
        analysis = analyze_meal_image(image_data, comments)
        
        # Create meal record
        meal_id = str(uuid.uuid4())
        meal = {
            'id': meal_id,
            'image_path': f'uploads/{meal_id}.jpg',  # In production, save to file system
            'image_url': None,  # Would be actual URL in production
            'comments': comments if comments else None,
            'calories': analysis['total_calories'],
            'created_at': datetime.now().isoformat(),
            'gemini_analysis': f"Description: {analysis['description']}\nBreakdown: {analysis['breakdown']}\nConfidence: {analysis['confidence_score']:.2f}"
        }
        
        meals_db.append(meal)
        
        return jsonify({
            'message': 'Meal uploaded successfully',
            'meal': meal
        })
        
    except Exception as e:
        return jsonify({'message': f'Error processing meal: {str(e)}'}), 500

@app.route('/meals/history', methods=['GET'])
def get_meal_history():
    # In production, filter by authenticated user
    return jsonify({
        'meals': meals_db
    })

@app.route('/meals/<meal_id>', methods=['GET'])
def get_meal(meal_id):
    meal = next((m for m in meals_db if m['id'] == meal_id), None)
    if not meal:
        return jsonify({'message': 'Meal not found'}), 404
    
    return jsonify({'meal': meal})

@app.route('/meals/<meal_id>', methods=['DELETE'])
def delete_meal(meal_id):
    global meals_db
    meals_db = [m for m in meals_db if m['id'] != meal_id]
    return jsonify({'message': 'Meal deleted successfully'})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)


