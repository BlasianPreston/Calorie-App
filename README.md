# Calorie Tracking App

A Flutter frontend with Flask backend for calorie tracking.

## Project Structure

```
calorie_tracking_app/
├── frontend/          # Flutter app
│   ├── lib/
│   │   ├── services/  # API service classes
│   │   ├── pages/     # App pages
│   │   └── ...        # Flutter app files
│   └── pubspec.yaml
├── backend/           # Flask API
│   ├── app.py
│   ├── requirements.txt
│   └── .env
└── README.md
```

## Setup

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

4. Copy environment file:
```bash
cp .env.example .env
```

5. Run the Flask server:
```bash
python app.py
```

The API will be available at `http://localhost:5000`

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

- `GET /` - Health check
- `GET /health` - API status
- `POST /auth/login` - User login
- `POST /auth/signup` - User registration

## Development

The Flutter app is configured to connect to the Flask backend running on `localhost:5000`. Make sure the backend is running before starting the Flutter app.
