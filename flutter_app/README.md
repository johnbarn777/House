# House App (Flutter)

A Flutter application for managing household chores and expenses, migrated from React Native.

## Features

-   **Authentication:** Email/Password and Google Sign-In.
-   **House Management:** Create or join houses using unique codes.
-   **Chores:** Create, assign, and schedule chores (Daily, Weekly, etc.).
-   **Notifications:** Push notifications (FCM) and local reminders for chores.
-   **Settings:** Manage profile and house membership.

## Getting Started

    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase:**
    ```bash
    # Activate flutterfire CLI (one-time setup)
    dart pub global activate flutterfire_cli
    
    # Configure Firebase for your project
    flutterfire configure --project=house-backend
    ```

4.  **Install iOS pods (macOS only):**
    ```bash
    cd ios && pod install && cd ..
    ```

> **Note:** Google Sign-In is pre-configured for iOS. The URL scheme has been added to `ios/Runner/Info.plist`.

## Running the App

### iOS
Open the Simulator or connect a physical iOS device.
```bash
flutter run
```
*Note: You may need to open `ios/Runner.xcworkspace` in Xcode to configure signing if running on a physical device.*

### Android
Open an Android Emulator or connect a physical Android device.
```bash
flutter run
```

## Testing

### Unit Tests
Run unit tests for business logic (Repositories, Providers, etc.):
```bash
flutter test test/unit
```

### Widget Tests
Run widget tests for UI components:
```bash
flutter test test/widget
```

### Integration Tests
Run end-to-end integration tests:
```bash
flutter test integration_test/app_test.dart
```

## Project Structure

-   `lib/core`: Core services, providers, and utilities.
-   `lib/features`: Feature-based modules (Auth, Houses, Chores).
-   `lib/main.dart`: Entry point and app configuration.
