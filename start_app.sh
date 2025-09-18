#!/bin/bash

# Calorie Tracking App Startup Script
echo "Starting Calorie Tracking App..."

# Check if we're in the right directory
if [ ! -f "backend/app.py" ]; then
    echo "Error: Please run this script from the project root directory"
    exit 1
fi

# Function to start backend
start_backend() {
    echo "Starting backend server..."
    cd backend
    
    # Check if virtual environment exists
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install dependencies
    echo "Installing backend dependencies..."
    pip install -r requirements.txt
    
    # Start Flask server
    echo "Starting Flask server on http://127.0.0.1:8000"
    python app.py &
    BACKEND_PID=$!
    
    cd ..
    echo "Backend started with PID: $BACKEND_PID"
}

# Function to start frontend
start_frontend() {
    echo "Starting Flutter app..."
    cd frontend
    
    # Get Flutter dependencies
    echo "Getting Flutter dependencies..."
    flutter pub get
    
    # Start Flutter app
    echo "Starting Flutter app..."
    flutter run &
    FRONTEND_PID=$!
    
    cd ..
    echo "Frontend started with PID: $FRONTEND_PID"
}

# Function to cleanup on exit
cleanup() {
    echo "Shutting down..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
    fi
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Start services
start_backend

# Wait a moment for backend to start
sleep 3

# Test backend
echo "Testing backend..."
python3 test_backend.py

# Start frontend
start_frontend

echo "App is running!"
echo "Backend: http://127.0.0.1:8000"
echo "Frontend: Check your Flutter device/emulator"
echo "Press Ctrl+C to stop all services"

# Wait for user to stop
wait
