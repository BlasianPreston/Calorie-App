# Database Setup - Calorie Tracking App

## Overview
The app now uses **SQLite database** for persistent data storage instead of in-memory storage.

## What Changed

### Before (In-Memory Storage):
- Data stored in Python variables (`meals_db = []`, `users_db = {}`)
- Data lost when server restarts
- No persistence between sessions

### After (SQLite Database):
- Data stored in SQLite database file (`calorie_tracking.db`)
- Data persists between server restarts
- Proper relational database with foreign keys
- User-specific meal tracking

## Database Schema

### Users Table
```sql
CREATE TABLE user (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(120) UNIQUE NOT NULL,
    name VARCHAR(80) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Meals Table
```sql
CREATE TABLE meal (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    image_path VARCHAR(200),
    image_url VARCHAR(500),
    comments TEXT,
    calories FLOAT NOT NULL DEFAULT 0.0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    gemini_analysis TEXT,
    FOREIGN KEY (user_id) REFERENCES user (id)
);
```

## Setup Instructions

### 1. Install Dependencies
```bash
cd backend
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Initialize Database
```bash
python init_db.py
```

### 3. Start the App
```bash
python app.py
```

## Database Features

### ✅ **Persistent Storage**
- All data saved to `calorie_tracking.db` file
- Data survives server restarts
- No more lost meals or users

### ✅ **User-Specific Data**
- Each user has their own meals
- Proper user authentication
- User profile with real stats

### ✅ **Relational Integrity**
- Foreign key relationships
- Cascade deletes (delete user → delete their meals)
- Data consistency

### ✅ **Real Statistics**
- Accurate meal counts per user
- Real calorie totals and averages
- Historical data tracking

## Database File Location
- **File**: `backend/calorie_tracking.db`
- **Type**: SQLite (single file database)
- **Backup**: Copy this file to backup your data

## Production Upgrade Path
For production, you can easily upgrade to:
- **PostgreSQL** (recommended for production)
- **MySQL** 
- **Any SQLAlchemy-supported database**

Just change the `SQLALCHEMY_DATABASE_URI` in `app.py`:
```python
# For PostgreSQL
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://user:password@localhost/calorie_tracking'

# For MySQL  
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://user:password@localhost/calorie_tracking'
```

## Data Migration
If you had data in the old in-memory system, it's lost (as expected). The new system starts fresh with proper database storage.

## Testing the Database
1. Start the backend: `python app.py`
2. Upload a meal through the frontend
3. Check the database: `sqlite3 calorie_tracking.db "SELECT * FROM meal;"`
4. Restart the server - your data will still be there!

## Troubleshooting
- **Database locked**: Make sure only one instance of the app is running
- **Permission errors**: Check file permissions on the database file
- **Import errors**: Make sure Flask-SQLAlchemy is installed

The app now has **real persistent storage** with proper database relationships! 🎉
