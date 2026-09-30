# Smart Accident Detection and Emergency Alert System

A Flutter-based accident detection and emergency alert system designed to detect possible accidents using smartphone motion sensors and provide rapid assistance through emergency alerts, location sharing, and emergency contacts.

# Project Overview

The system monitors the user's movement using the smartphone's accelerometer. When a possible accident is detected based on the configured motion threshold, the application starts an emergency countdown.

During the countdown, the user can confirm that they are safe. If the user does not cancel the alert, the system proceeds with the emergency response, including location sharing and notifying configured emergency contacts.

The project also includes a web-based police dashboard for viewing accident alert information and location-related data.

## Key Features

### Flutter Mobile Application

- User registration and login
- Firebase Authentication
- Emergency contact management
- Accident detection using accelerometer data
- Emergency countdown
- Emergency alert sound
- Device vibration
- "I AM SAFE" option to cancel an alert
- GPS-based location retrieval
- Google Maps location sharing
- Emergency contact notification
- Emergency calling
- Accident history
- Accident history clearing
- Nearby hospitals
- Location-based hospital information
- User profile and application information

### Police Dashboard

- Web-based accident monitoring dashboard
- Accident alert information
- Location information
- Emergency contact information
- Firebase-based data access
- Dashboard analytics and status information

##  Technology Stack

### Mobile Application
- Flutter
- Dart
- Android

### Backend
- Firebase Authentication
- Cloud Firestore

### Packages
- Sensors Plus
- Geolocator
- Geocoding
- Flutter SMS
- AudioPlayers
- Vibration
- Shared Preferences
- URL Launcher
- HTTP

### Police Dashboard
- HTML
- CSS
- JavaScript
- Firebase

### Deployment
- GitHub
- Vercel

##  System Workflow

```text
User
  ↓
Login / Registration
  ↓
Start Monitoring
  ↓
Accelerometer Data
  ↓
Accident Detection
  ↓
Emergency Countdown
  ↓
User Cancels?
  ├── Yes → Alert Cancelled
  │
  └── No
       ↓
  Emergency Response
       ↓
  Get Current Location
       ↓
  Notify Emergency Contacts
       ↓

### Accident Detection

The application uses the smartphone accelerometer to monitor movement.

The acceleration magnitude is calculated using the X, Y and Z axis values:

```text
Magnitude = √(X² + Y² + Z²)

##  Emergency Response

When an accident alert is confirmed:

1. The current location is obtained.
2. A Google Maps location link is generated.
3. Configured emergency contacts are retrieved.
4. Emergency information is sent to the configured contacts.
5. The accident information is stored for history.
6. The alert information can be viewed through the police dashboard.

##  Nearby Hospitals

The application provides nearby hospital information based on the user's location.

## Police Dashboard

The police dashboard provides a web interface for monitoring accident-related information collected by the system.

### Live Dashboard

[Open Police Dashboard](https://policedashboard-orpin.vercel.app/)

##  Project Structure

```text
accident_predictor/
│
├── android/
├── ios/
├── assets/
│   ├── app_icon.png
│   └── sounds/
│       └── emergency_beep.wav
│
├── lib/
│   ├── models/
│   ├── screens/
│   └── services/
│
├── pubspec.yaml
└── README.md
  Store Accident Information
       ↓
  Police Dashboard

##  Running the Flutter Application

1. Clone the repository

git clone https://github.com/NivruthaNarayanam/accident_detector.git

2. Open the project

cd accident_detector

3. Install dependencies

flutter pub get

4. Run the application

flutter run

##  Build APK

To generate a release APK:

flutter build apk --release

The generated APK will be available at:

build/app/outputs/flutter-apk/app-release.apk

##  Firebase

The application uses Firebase services for:

- User authentication
- Emergency contact storage
- Accident-related data
- Communication between the mobile application and dashboard

##  Future Enhancements

- Background accident monitoring
- Improved accident detection using machine learning
- Improved false-positive filtering
- Enhanced emergency communication
- Medical profile information
- Expanded emergency service integration
- Improved real-time monitoring capabilities

## Project

**Smart Accident Detection and Emergency Alert System**

Developed as a B.Tech community project using Flutter, Firebase and web technologies.
