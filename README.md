# Perpetua - Habit Tracking App

A Flutter application for tracking daily habits with a clean, modern UI.

## Features

### Registration Screen
- Clean registration form with Full Name, Email, and Password fields
- Terms and Privacy Policy agreement with Yes/No checkboxes
- Modern UI with soft baby-blue background (#E6F2FA)
- Handwritten-style title font

### Home Screen (Your Habits)
- View and manage daily habits
- Toggle habit completion with circular icons
- Track streaks with fire emoji indicators
- Swipe left to delete habits
- Tap habits to view details
- Add new habits with + button
- Bottom navigation with Reminders, Stats, Streaks, and Settings tabs

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone or navigate to the project directory:
```bash
cd CS_310_Project
```

2. Get Flutter dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
└── screens/
    ├── registration_screen.dart  # Registration UI
    └── home_screen.dart          # Home screen with habits
```

## UI Design

- **Background Color**: Soft baby-blue (#E6F2FA)
- **Primary Elements**: White rounded containers
- **Font Style**: Modern, minimalistic design
- **Icons**: Material Design icons

## Notes

- This is a UI-only implementation (no backend authentication)
- Sample habit data is included for demonstration
- Navigation between screens is functional
- All interactive features (swipe to delete, toggle, add) are implemented

