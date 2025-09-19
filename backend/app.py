from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
import os
import uuid
import base64
from datetime import datetime
from dotenv import load_dotenv
import google.generativeai as genai
from models import db, User, Meal

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app, origins=['*'], supports_credentials=True)  # Enable CORS for Flutter app

# Configuration
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-secret-key-here')
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///calorie_tracking.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize database
db.init_app(app)

# Simple auth helper for demo tokens in the form: "demo_token_{user_id}"
def get_authenticated_user():
    auth_header = request.headers.get('Authorization', '')
    if not auth_header.startswith('Bearer '):
        return None
    token = auth_header.split(' ', 1)[1]
    prefix = 'demo_token_'
    if not token.startswith(prefix):
        return None
    user_id = token[len(prefix):]
    try:
        user = User.query.get(user_id)
        return user
    except Exception:
        return None

# Configure Gemini AI
genai.configure(api_key=os.getenv('GEMINI_API_KEY'))

# Initialize Gemini model
model = genai.GenerativeModel('gemini-1.5-flash')

# Create database tables
with app.app_context():
    db.create_all()
    
    # Migrate existing meals to add imageUrl if missing
    existing_meals = Meal.query.filter(Meal.image_url.is_(None)).all()
    for meal in existing_meals:
        if meal.image_path and os.path.exists(meal.image_path):
            # Extract filename from path
            filename = os.path.basename(meal.image_path)
            meal.image_url = f'/images/{filename}'
    
    if existing_meals:
        db.session.commit()
        print(f"Updated {len(existing_meals)} existing meals with image URLs")

def analyze_meal_image(image_data, comments=None):
    """Analyze meal image using Gemini AI to estimate calories"""
    try:
        # Convert image to base64 for Gemini
        image_base64 = base64.b64encode(image_data).decode('utf-8')
        
        prompt = f"""
        You are a nutrition expert analyzing food images. Please analyze this image and provide accurate calorie estimates.
        
        Instructions:
        1. Identify all food items visible in the image
        2. Estimate the portion size of each item
        3. Calculate calories based on standard nutritional values
        4. Be conservative and realistic with estimates
        5. Consider that a medium banana is typically 80-100 calories, an apple is 60-80 calories, etc.
        
        Please respond in this exact JSON format:
        {{
            "description": "Brief description of what you see",
            "total_calories": [number],
            "breakdown": "Detailed breakdown of each food item and its calories",
            "confidence_score": [number between 0 and 1]
        }}
        
        {f"Additional context from user: {comments}" if comments else ""}
        
        Remember: Be accurate and realistic with calorie estimates. A single piece of fruit should not be 500+ calories.
        """
        
        # Generate content using Gemini
        response = model.generate_content([
            prompt,
            {
                "mime_type": "image/jpeg",
                "data": image_base64
            }
        ])
        
        # Parse the actual response from Gemini
        response_text = response.text.strip()
        print(f"Gemini response: {response_text}")
        
        # Check if we got a valid response
        if not response_text or len(response_text) < 10:
            print("Warning: Empty or very short response from Gemini")
            return {
                "description": "Unable to analyze image - empty response",
                "total_calories": 0,
                "breakdown": "Analysis failed - no response from AI",
                "confidence_score": 0.0
            }
        
        # Try to extract information from the response
        try:
            # Look for JSON in the response
            import re
            json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
            if json_match:
                import json
                parsed_response = json.loads(json_match.group())
                return {
                    "description": parsed_response.get("description", "Food analysis"),
                    "total_calories": float(parsed_response.get("total_calories", 0)),
                    "breakdown": parsed_response.get("breakdown", "Analysis completed"),
                    "confidence_score": float(parsed_response.get("confidence_score", 0.8))
                }
        except Exception as parse_error:
            print(f"Error parsing JSON response: {parse_error}")
        
        # Fallback: try to extract calories from text
        calories_match = re.search(r'(\d+(?:\.\d+)?)\s*calories?', response_text, re.IGNORECASE)
        calories = float(calories_match.group(1)) if calories_match else 0
        
        # Extract description (first sentence or line)
        description_lines = response_text.split('\n')
        description = description_lines[0].strip() if description_lines else "Food analysis"
        
        return {
            "description": description,
            "total_calories": calories,
            "breakdown": response_text,
            "confidence_score": 0.8 if calories > 0 else 0.3
        }
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
    
    if email and password:
        # Check if user exists
        user = User.query.filter_by(email=email).first()
        
        if not user:
            # Create new user for demo purposes
            user_id = str(uuid.uuid4())
            user = User(
                id=user_id,
                email=email,
                name=email.split('@')[0]
            )
            db.session.add(user)
            db.session.commit()
        
        return jsonify({
            'message': 'Login successful',
            'token': f'demo_token_{user.id}',
            'user': user.to_dict()
        })
    
    return jsonify({'message': 'Invalid credentials'}), 401

@app.route('/auth/signup', methods=['POST'])
def signup():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    name = data.get('name')
    
    if email and password and name:
        # Check if user already exists
        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            return jsonify({'message': 'User already exists'}), 400
        
        user_id = str(uuid.uuid4())
        user = User(
            id=user_id,
            email=email,
            name=name
        )
        db.session.add(user)
        db.session.commit()
        
        return jsonify({
            'message': 'Signup successful',
            'token': f'demo_token_{user_id}',
            'user': user.to_dict()
        })
    
    return jsonify({'message': 'Missing required fields'}), 400

@app.route('/meals/upload', methods=['POST'])
def upload_meal():
    # Require authenticated user
    current_user = get_authenticated_user()
    if not current_user:
        return jsonify({'message': 'Unauthorized'}), 401

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
        
        # Create meal record in database
        meal_id = str(uuid.uuid4())
        
        # Create uploads directory if it doesn't exist
        uploads_dir = 'uploads'
        if not os.path.exists(uploads_dir):
            os.makedirs(uploads_dir)
        
        # Save image to filesystem
        image_filename = f'{meal_id}.jpg'
        image_path = os.path.join(uploads_dir, image_filename)
        with open(image_path, 'wb') as f:
            f.write(image_data)
        
        # Create image URL for web access
        image_url = f'/images/{image_filename}'
        
        meal = Meal(
            id=meal_id,
            user_id=current_user.id,
            image_path=image_path,
            image_url=image_url,
            comments=comments if comments else None,
            calories=analysis['total_calories'],
            gemini_analysis=f"Description: {analysis['description']}\nBreakdown: {analysis['breakdown']}\nConfidence: {analysis['confidence_score']:.2f}"
        )
        
        db.session.add(meal)
        db.session.commit()
        
        return jsonify({
            'message': 'Meal uploaded successfully',
            'meal': meal.to_dict()
        })
        
    except Exception as e:
        return jsonify({'message': f'Error processing meal: {str(e)}'}), 500

@app.route('/meals/history', methods=['GET'])
def get_meal_history():
    # Filter by authenticated user
    current_user = get_authenticated_user()
    if not current_user:
        return jsonify({'message': 'Unauthorized'}), 401
    meals = Meal.query.filter_by(user_id=current_user.id).order_by(Meal.created_at.desc()).all()
    return jsonify({
        'meals': [meal.to_dict() for meal in meals]
    })

@app.route('/meals/<meal_id>', methods=['GET'])
def get_meal(meal_id):
    meal = Meal.query.get(meal_id)
    if not meal:
        return jsonify({'message': 'Meal not found'}), 404
    
    return jsonify({'meal': meal.to_dict()})

@app.route('/meals/<meal_id>', methods=['DELETE'])
def delete_meal(meal_id):
    meal = Meal.query.get(meal_id)
    if not meal:
        return jsonify({'message': 'Meal not found'}), 404
    
    # Delete the image file if it exists
    if meal.image_path and os.path.exists(meal.image_path):
        try:
            os.remove(meal.image_path)
        except Exception as e:
            print(f"Error deleting image file: {e}")
    
    db.session.delete(meal)
    db.session.commit()
    return jsonify({'message': 'Meal deleted successfully'})

@app.route('/images/<filename>')
def serve_image(filename):
    """Serve uploaded images"""
    try:
        return send_from_directory('uploads', filename)
    except FileNotFoundError:
        return jsonify({'message': 'Image not found'}), 404

@app.route('/user/profile', methods=['GET'])
def get_user_profile():
    # Use authenticated user from token
    user = get_authenticated_user()
    if not user:
        return jsonify({'message': 'Unauthorized'}), 401
    
    # Calculate stats from database
    user_meals = Meal.query.filter_by(user_id=user.id).all()
    total_meals = len(user_meals)
    total_calories = sum(meal.calories for meal in user_meals)
    average_calories = total_calories / total_meals if total_meals > 0 else 0
    
    # Calculate today's calories
    from datetime import datetime, date
    today = date.today()
    today_meals = Meal.query.filter(
        Meal.user_id == user.id,
        db.func.date(Meal.created_at) == today
    ).all()
    today_calories = sum(meal.calories for meal in today_meals)
    
    return jsonify({
        'user': user.to_dict(),
        'stats': {
            'total_meals': total_meals,
            'total_calories': total_calories,
            'average_calories': round(average_calories, 1),
            'today_calories': today_calories
        }
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)


