from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):
    id = db.Column(db.String(36), primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    name = db.Column(db.String(80), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationship to meals
    meals = db.relationship('Meal', backref='user', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'id': self.id,
            'email': self.email,
            'name': self.name,
            'created_at': self.created_at.isoformat()
        }

class Meal(db.Model):
    id = db.Column(db.String(36), primary_key=True)
    user_id = db.Column(db.String(36), db.ForeignKey('user.id'), nullable=False)
    image_path = db.Column(db.String(200), nullable=True)
    image_url = db.Column(db.String(500), nullable=True)
    comments = db.Column(db.Text, nullable=True)
    calories = db.Column(db.Float, nullable=False, default=0.0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    gemini_analysis = db.Column(db.Text, nullable=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'image_path': self.image_path or '',
            'image_url': self.image_url,
            'comments': self.comments,
            'calories': self.calories,
            'created_at': self.created_at.isoformat(),
            'gemini_analysis': self.gemini_analysis
        }
