# Calorie Tracking App - Setup Guide

This guide will help you set up and run the complete calorie tracking application with Flutter frontend and Flask backend.

## Prerequisites

- Python 3.8+ installed
- Flutter SDK installed
- Git (optional, for version control)

## Quick Start

1. **Run the startup script:**
   ```bash
   ./start_app.sh
   ```

   This will automatically:
   - Set up the Python virtual environment
   - Install backend dependencies
   - Start the Flask backend server
   - Test the backend endpoints
   - Get Flutter dependencies
   - Start the Flutter app

## Manual Setup

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create and activate virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Start the backend server:**
   ```bash
   python app.py
   ```

   The backend will be available at `http://127.0.0.1:8000`

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Get Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the Flutter app:**
   ```bash
   flutter run
   ```

## API Endpoints

The backend provides the following endpoints:

- `GET /` - Health check
- `GET /health` - API status
- `POST /auth/login` - User login
- `POST /auth/signup` - User registration
- `GET /user/profile` - Get user profile and stats
- `POST /meals/upload` - Upload meal image for analysis
- `GET /meals/history` - Get meal history
- `GET /meals/{id}` - Get specific meal
- `DELETE /meals/{id}` - Delete meal

## Features

### Frontend (Flutter)
- **Authentication**: Login and signup with token-based auth
- **Meal Upload**: Camera integration for meal photo capture
- **AI Analysis**: Integration with Google Gemini AI for calorie estimation
- **Meal History**: View and manage uploaded meals
- **User Profile**: Display user stats and account information
- **Responsive UI**: Modern Material Design interface

### Backend (Flask)
- **RESTful API**: Clean API design with proper HTTP methods
- **CORS Support**: Configured for Flutter app integration
- **AI Integration**: Google Gemini AI for food analysis
- **File Upload**: Multipart form handling for image uploads
- **Data Storage**: In-memory storage (demo purposes)
- **Error Handling**: Comprehensive error responses

## Configuration

### Backend Configuration
- **Port**: 8000 (configurable in `app.py`)
- **CORS**: Configured for all origins (development only)
- **File Upload**: 16MB max file size
- **AI Model**: Gemini 1.5 Flash

### Frontend Configuration
- **API Base URL**: `http://127.0.0.1:8000` (configurable in `lib/config/app_config.dart`)
- **Image Quality**: 85% compression for uploads
- **Max Image Size**: 1024x1024 pixels

## Testing

### Backend Testing
Run the test script to verify all endpoints:
```bash
python3 test_backend.py
```

### Frontend Testing
The Flutter app includes:
- Form validation
- Error handling
- Loading states
- Network error recovery

## Troubleshooting

### Common Issues

1. **Backend won't start:**
   - Check if port 8000 is available
   - Ensure all dependencies are installed
   - Check Python version (3.8+ required)

2. **Frontend can't connect to backend:**
   - Verify backend is running on port 8000
   - Check CORS configuration
   - Ensure correct API base URL

3. **Image upload fails:**
   - Check file size (max 16MB)
   - Verify image format (JPEG/PNG)
   - Check network connectivity

4. **AI analysis not working:**
   - Verify GEMINI_API_KEY is set in environment
   - Check internet connection
   - Verify API quota limits

### Environment Variables

Create a `.env` file in the backend directory:
```env
SECRET_KEY=your-secret-key-here
GEMINI_API_KEY=your-gemini-api-key
```

## Development Notes

- The app uses in-memory storage for demo purposes
- In production, implement proper database storage
- Add proper authentication token validation
- Implement user-specific meal filtering
- Add image storage and serving capabilities

## File Structure

```
calorie_tracking_app/
├── backend/
│   ├── app.py              # Flask application
│   ├── requirements.txt    # Python dependencies
│   └── venv/              # Virtual environment
├── frontend/
│   ├── lib/
│   │   ├── config/        # App configuration
│   │   ├── models/        # Data models
│   │   ├── pages/         # UI pages
│   │   └── services/      # API services
│   └── pubspec.yaml       # Flutter dependencies
├── start_app.sh           # Startup script
├── test_backend.py        # Backend test script
└── SETUP.md              # This file
```

## Next Steps

1. Set up a proper database (PostgreSQL/MongoDB)
2. Implement user authentication with JWT tokens
3. Add image storage (AWS S3/Cloudinary)
4. Implement user-specific data filtering
5. Add more AI analysis features
6. Deploy to production servers
