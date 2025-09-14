# Calorie Tracking App

A Flutter frontend with Flask backend for AI-powered calorie tracking using Gemini API.

## Features

- **User Authentication**: Login and signup pages
- **Meal Upload**: Take photos of meals with optional comments
- **AI Analysis**: Uses Gemini API to analyze food photos and estimate calories
- **Meal History**: View past meals with calorie information and AI analysis
- **Account Management**: User profile, stats, and logout functionality

## Project Structure

```
calorie_tracking_app/
├── frontend/          # Flutter app
│   ├── lib/
│   │   ├── models/    # Data models
│   │   ├── pages/     # App screens
│   │   ├── services/  # API services
│   │   └── config/    # Configuration
│   └── pubspec.yaml
├── backend/           # Flask API
│   ├── app.py
│   ├── requirements.txt
│   └── .env
└── README.md
```

## Setup

### Prerequisites

- Flutter SDK (3.0+)
- Python 3.8+
- Google Gemini API key

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Set up environment variables:
```bash
# Create .env file
echo "SECRET_KEY=your-secret-key-here" > .env
echo "GEMINI_API_KEY=your-gemini-api-key-here" >> .env
echo "FLASK_ENV=development" >> .env
```

5. Run the Flask server:
```bash
python app.py
```

The API will be available at `http://localhost:8080`

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Run the Flutter app:
```bash
flutter run
```

## API Endpoints

### Authentication
- `POST /auth/login` - User login
- `POST /auth/signup` - User registration

### Meals
- `POST /meals/upload` - Upload meal photo with AI analysis
- `GET /meals/history` - Get user's meal history
- `GET /meals/<id>` - Get specific meal details
- `DELETE /meals/<id>` - Delete a meal

## Getting Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Add it to your backend `.env` file

## Features Overview

### Meal Upload Page
- Camera integration for taking photos
- Optional comments field
- Real-time AI analysis using Gemini
- Progress indicators during upload

### Meal History Page
- Chronological list of all meals
- Calorie information and AI analysis
- Delete functionality
- Pull-to-refresh support

### Account Page
- User statistics (total meals, average calories)
- Account information display
- Settings options (placeholder)
- Logout functionality

## Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile framework
- **HTTP**: API communication
- **Image Picker**: Camera integration
- **Shared Preferences**: Local storage
- **Google Nav Bar**: Navigation

### Backend
- **Flask**: Python web framework
- **Flask-CORS**: Cross-origin resource sharing
- **Google Generative AI**: Gemini API integration
- **Python-dotenv**: Environment variable management

## Development Notes

- The backend uses in-memory storage for demo purposes
- In production, implement proper database storage
- Add proper authentication middleware
- Implement file upload to cloud storage
- Add input validation and error handling
- Consider adding user roles and permissions

## Troubleshooting

### CocoaPods Issues (iOS)
If you encounter CocoaPods issues on macOS:
```bash
# Install/update CocoaPods with Homebrew Ruby
brew install ruby
sudo /opt/homebrew/opt/ruby/bin/gem install cocoapods
sudo ln -s /opt/homebrew/lib/ruby/gems/3.4.0/bin/pod /usr/local/bin/pod
```

### Flutter Dependencies
If Flutter dependencies fail to install:
```bash
flutter clean
flutter pub get
```

### Backend Dependencies
If Python dependencies fail to install:
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

## License

This project is for educational purposes. Please ensure you comply with Google's Gemini API terms of service when using this application.
