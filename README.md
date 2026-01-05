
# Perpetua – Habit Tracking App

Perpetua is a comprehensive Flutter-based habit tracking application designed to help users build and maintain positive daily routines. With Firebase backend integration, the app offers real-time data synchronization, persistence across devices, and a modern, intuitive user interface.

---

## Project Overview & Motivation

Perpetua aims to support users in building consistent habits by combining visual progress tracking, reminders, streaks, and detailed statistics.

### Key Motivations
- Encourage consistency through daily habit tracking
- Motivate users with streaks and statistical insights
- Allow customizable reminders for habits
- Provide a clean, modern UI with dark mode support
- Ensure reliable data persistence via Firebase

---

## Technology Stack

- **Framework:** Flutter (SDK >= 3.0.0)
- **State Management:** Provider
- **Backend:** Firebase (Authentication, Cloud Firestore)
- **Local Storage:** SharedPreferences
- **UI:** Material Design with custom Roboto font (local assets)

---

## Prerequisites

Before running the project, ensure the following are installed:

- Flutter SDK (>= 3.0.0)
- Dart SDK (included with Flutter)
- Android Studio or VS Code with Flutter extensions
- Firebase account
- Xcode (for iOS development on macOS)
- Android SDK (for Android development)

---

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/aysuyazdicutan/CS_310_Project.git
cd CS_310_Project
````

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

This installs required packages such as:

* firebase_core, firebase_auth, cloud_firestore
* provider
* shared_preferences
* google_fonts (note: the app uses local Roboto font assets)

---

### 3. Firebase Configuration

Firebase is already configured for this project.

**Android**

* google-services.json is located in android/app/
* If using a new Firebase project, replace this file with your own

**iOS**

* GoogleService-Info.plist is located in ios/Runner/
* Deployment target must be iOS 15.0+
* Run before first build:

```bash
cd ios
pod install
cd ..
```

**Web**

* Firebase configuration is included in lib/firebase_options.dart

**Using a New Firebase Project**

1. Create a Firebase project at [https://console.firebase.google.com](https://console.firebase.google.com)
2. Enable Email/Password Authentication
3. Create a Cloud Firestore database
4. Download platform-specific config files
5. Run:

```bash
flutterfire configure
```

---

### 4. Custom Font Setup

The project uses the Roboto font family from local assets.

Included fonts (assets/fonts/):

* Roboto-Light.ttf (300)
* Roboto-Regular.ttf (400)
* Roboto-Medium.ttf (500)
* Roboto-Bold.ttf (700)

Fonts are already configured in pubspec.yaml.

If missing, download them from:
[https://fonts.google.com/specimen/Roboto](https://fonts.google.com/specimen/Roboto)

---

### 5. Verify Flutter Installation

```bash
flutter doctor
```

Ensure all components are correctly configured.

---

### 6. Run the Application

**Android**

```bash
flutter run
```

Or specify a device:

```bash
flutter run -d <device-id>
```

**iOS (macOS only)**

```bash
cd ios
pod install
cd ..
flutter run -d ios
```

**Web**

```bash
flutter run -d chrome
```

---

## Running Tests

Run all tests:

```bash
flutter test
```

Run tests with coverage:

```bash
flutter test --coverage
```

**Test Coverage**

* Unit Tests: test/habit_test.dart (Habit model and Firestore conversion)
* Widget Tests: test/widget_test.dart (WelcomeScreen UI and interactions)

---

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── constants/
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   ├── app_paddings.dart
│   └── app_dimensions.dart
├── models/
│   ├── habit.dart
│   └── reminder.dart
├── providers/
│   ├── auth_provider.dart
│   ├── habit_provider.dart
│   ├── reminders_provider.dart
│   └── settings_provider.dart
├── screens/
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── registration_screen.dart
│   ├── personalization_screen.dart
│   ├── home_screen.dart
│   ├── add_new_habit_screen.dart
│   ├── habit_detail_screen.dart
│   ├── statistics_screen.dart
│   ├── streak_calendar_screen.dart
│   ├── reminders_screen.dart
│   ├── profile_screen.dart
│   └── settings_screen.dart
└── services/
    ├── auth_service.dart
    └── habit_service.dart
```

---

## State Management

The app uses the Provider pattern:

* AuthProvider – Authentication state
* HabitProvider – Habit CRUD operations
* RemindersProvider – Reminder scheduling and management
* SettingsProvider – User preferences and theme settings

---

## Firebase Services Used

* Firebase Authentication – User login and registration
* Cloud Firestore – Habit data storage
* Firebase Options – Multi-platform configuration

---

## Known Limitations & Bugs

1. Reminder notifications may require additional native configuration for background execution.
2. Offline support is limited; local caching can be improved.
3. Some edge cases in error handling need refinement.
4. Firebase configuration must be updated manually for new environments.
5. iOS requires deployment target 15.0+.
6. Web platform feature parity may need further testing.
7. Some layouts may need optimization for very small or very large screens.

---

## License

This project was created for educational purposes as part of the CS 310 – Mobile Application Development course.

---

## Version

Current Version: 1.0.0+1


