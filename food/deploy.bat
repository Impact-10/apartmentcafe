@echo off
REM Apartment Café - Windows Deployment Script

echo Starting deployment process...

REM Check if .env exists
if not exist .env (
    echo Error: .env file not found!
    echo Please create .env file from .env.example and fill in your Firebase config
    exit /b 1
)

REM Build frontend
echo Building frontend...
call npm run build

if %errorlevel% neq 0 (
    echo Frontend build failed!
    exit /b 1
)

REM Deploy Firestore rules
echo Deploying Firestore rules...
call firebase deploy --only firestore:rules

REM Deploy Cloud Functions
echo Deploying Cloud Functions...
call firebase deploy --only functions

REM Deploy Hosting
echo Deploying to Firebase Hosting...
call firebase deploy --only hosting

echo Deployment complete!
echo Your app is live!
