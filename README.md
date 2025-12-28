# Perpetua - Habit Tracking App

A comprehensive Flutter application for tracking daily habits with Firebase backend integration, providing users with a modern, intuitive interface to build and maintain healthy habits.

## Project Overview & Motivation

Perpetua is a habit tracking application designed to help users build and maintain positive daily routines. The app provides a seamless experience for users to create habits, track their progress, maintain streaks, set reminders, and view detailed statistics. Built with Flutter and Firebase, Perpetua ensures data persistence and real-time synchronization across devices.

**Key Motivations:**
- Help users build consistent daily habits through visual tracking
- Provide motivation through streak tracking and statistics
- Enable users to set reminders for their habits
- Offer a clean, modern UI with dark mode support
- Ensure data persistence through Firebase backend

## Features

### Authentication & User Management
- User registration and login with Firebase Authentication
- Welcome screen for first-time users
- Profile management
- Secure user sessions

### Habit Management
- Create, edit, and delete habits
- Custom emoji selection for each habit
- Toggle daily habit completion
- Track completion history
- View detailed habit information

### Progress Tracking
- **Streak Tracking**: Current streak and best streak tracking for each habit
- **Statistics Screen**: Comprehensive statistics and insights
- **Streak Calendar**: Visual calendar view of habit completion
- **Completion History**: Track completion dates over time

### Reminders
- Set custom reminders for habits
- Notification system with snooze and dismiss options
- Automatic reminder checking

### Settings & Personalization
- Dark mode support
- User preferences storage with SharedPreferences
- Settings management screen

### UI/UX
- Modern, clean interface with soft baby-blue theme (#E6F2FA)
- Dark mode support
- Responsive design
- Intuitive navigation with bottom navigation bar
- Swipe gestures for habit deletion

## Technology Stack

- **Framework**: Flutter (SDK >=3.0.0)
- **State Management**: Provider
- **Backend**: Firebase (Firestore, Authentication)
- **Local Storage**: SharedPreferences
- **UI**: Material Design with Google Fonts

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.0.0 or higher
- **Dart SDK**: Included with Flutter
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase Account**: Access to Firebase Console
- **Xcode** (for iOS development on macOS)
- **Android SDK** (for Android development)

## Setup Instructions

### 1. Clone the Repository

git clone <repository-url>
cd CS_310_Project### 2. Install Flutter Dependencies

flutter pub get### 3. Firebase Configuration

This project uses Firebase for authentication and data storage. Firebase is already configured for the project, but if you need to set it up for a new Firebase project:

#### For Android:
- The `google-services.json` file is already present in `android/app/`
- If using a new Firebase project, download `google-services.json` from Firebase Console and replace the existing file

#### For iOS:
- The `GoogleService-Info.plist` file is already present in `ios/Runner/`
- If using a new Firebase project, download `GoogleService-Info.plist` from Firebase Console and replace the existing file

#### For Web (if needed):
- Firebase configuration is included in `lib/firebase_options.dart`

**Note**: The current Firebase configuration files are already set up. If you're deploying to a new environment, you'll need to:
1. Create a new Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password)
3. Create a Firestore database
4. Download the platform-specific configuration files
5. Run `flutterfire configure` if needed to regenerate `firebase_options.dart`

### 4. Verify Flutter Installation

flutter doctorEnsure all required components are installed and properly configured.

### 5. Run the Application

#### For Android:
flutter runOr specify a device:
flutter run -d <device-id>#### For iOS (macOS only):
flutter run -d ios
#### For Web:
flutter run -d chrome### 6. Build for Release

#### Android APK:
flutter build apk#### Android App Bundle:ash
flutter build appbundle#### iOS:
flutter build ios
## Running Tests

The project includes a basic test structure. To run the tests:

flutter test**Note**: The current test file (`test/widget_test.dart`) contains placeholder code. Comprehensive tests for the application features should be implemented as part of future development.

To run tests with coverage:
flutter test --coverage## Project Structure
