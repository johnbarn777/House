# House Flutter App

This is the Flutter implementation of the House application.

## Prerequisites

-   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and in your PATH.
-   **iOS:** Xcode installed (macOS only).
-   **Android:** Android Studio and Android SDK installed.
-   **CocoaPods:** Installed (`sudo gem install cocoapods`).

## Getting Started

1.  **Navigate to the project directory:**
    ```bash
    cd flutter_app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Install iOS pods (macOS only):**
    ```bash
    cd ios && pod install && cd ..
    ```

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
