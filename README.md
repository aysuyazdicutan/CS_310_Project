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

```bash
git clone <repository-url>
cd CS_310_Project
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

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

```bash
flutter doctor
```

Ensure all required components are installed and properly configured.

### 5. Run the Application

#### For Android:
```bash
flutter run
```

Or specify a device:
```bash
flutter run -d <device-id>
```

#### For iOS (macOS only):
```bash
flutter run -d ios
```

#### For Web:
```bash
flutter run -d chrome
```

### 6. Build for Release

#### Android APK:
```bash
flutter build apk
```

#### Android App Bundle:
```bash
flutter build appbundle
```

#### iOS:
```bash
flutter build ios
```

## Running Tests

The project includes comprehensive tests covering both unit and widget tests. To run all tests:

```bash
flutter test
```

The test suite includes:
- **2 Unit Tests** (`test/habit_test.dart`): Testing Habit model creation and Firestore conversion
- **2 Widget Tests** (`test/widget_test.dart`): Testing WelcomeScreen UI components and interactions

To run tests with coverage:
```bash
flutter test --coverage
```

All tests pass successfully and verify core functionality of the application.

## Project Structure

```
lib/
├── main.dart                    # App entry point with Firebase initialization
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models
│   ├── habit.dart              # Habit model
│   └── reminder.dart           # Reminder model
├── providers/                   # State management (Provider pattern)
│   ├── auth_provider.dart      # Authentication state
│   ├── habit_provider.dart     # Habit management state
│   ├── reminders_provider.dart # Reminders state
│   └── settings_provider.dart  # User settings state
├── screens/                     # UI screens
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── registration_screen.dart
│   ├── personalization_screen.dart
│   ├── home_screen.dart
│   ├── add_new_habit_screen.dart
│   ├── habit_detail_screen.dart
│   ├── habit_edit_screen.dart
│   ├── habit_selection_screen.dart
│   ├── statistics_screen.dart
│   ├── streak_calendar_screen.dart
│   ├── reminders_screen.dart
│   ├── profile_screen.dart
│   └── settings_screen.dart
└── services/                    # Business logic services
    ├── auth_service.dart       # Firebase Authentication service
    └── habit_service.dart      # Firestore Habit operations
```

## Firebase Services Used

- **Firebase Authentication**: User registration and login
- **Cloud Firestore**: Habit data storage and retrieval
- **Firebase Options**: Multi-platform configuration

## State Management

The app uses the **Provider** pattern for state management with the following providers:

- `AuthProvider`: Manages user authentication state
- `HabitProvider`: Manages habit CRUD operations
- `RemindersProvider`: Manages reminder scheduling and notifications
- `SettingsProvider`: Manages user preferences and theme settings

## Known Limitations & Bugs

1. **Reminder Notifications**: While reminders are implemented, native push notifications may require additional configuration for background notifications on iOS and Android.

2. **Offline Support**: The app requires an active internet connection to sync data with Firebase. Offline support with local caching could be improved.

3. **Error Handling**: Some edge cases in error handling could be enhanced for better user experience.

4. **Firebase Configuration**: If deploying to a new environment, Firebase configuration files need to be updated manually.

5. **iOS Signing**: Release builds for iOS require proper code signing configuration in Xcode.

6. **Web Platform**: Full feature parity on web platform may require additional testing and adjustments.

## Contributing

This is a course project. For issues or improvements, please contact the project maintainers.

## License

This project is created for educational purposes as part of CS 310 course.

## Version

Current Version: 1.0.0+1

## Contact

For questions or support, please refer to the course instructors or project documentation.
