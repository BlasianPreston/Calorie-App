#!/usr/bin/env python3
"""
Database initialization script for Calorie Tracking App
"""
from app import app, db
from models import User, Meal

def init_database():
    """Initialize the database with tables"""
    with app.app_context():
        # Create all tables
        db.create_all()
        print("✅ Database tables created successfully!")
        
        # Check if we have any users
        user_count = User.query.count()
        print(f"📊 Current users in database: {user_count}")
        
        # Check if we have any meals
        meal_count = Meal.query.count()
        print(f"🍽️  Current meals in database: {meal_count}")
        
        print("\n🎉 Database initialization complete!")
        print("You can now start the Flask app with: python app.py")

if __name__ == "__main__":
    init_database()
