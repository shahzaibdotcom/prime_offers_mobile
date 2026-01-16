# Prime Offers - Mobile App (Flutter)

A Flutter-based mobile application for discovering credit/debit card offers. It features a modern UI, dynamic home screen layouts driven by the backend, and secure authentication.

## Prerequisites

-   **Flutter SDK**: >= 3.0
-   **Dart**: >= 3.0
-   **IDE**: VS Code or Android Studio
-   **Backend**: The Laravel backend must be running.

## Setup & Configuration

1.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

2.  **Configure API Endpoint**
    Open `lib/core/api_client.dart` and update the `baseUrl`.
    
    If running on an Android Emulator, use `10.0.2.2`:
    ```dart
    static const String baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000/api',
    );
    ```

    If running on iOS Simulator, use `127.0.0.1`:
    ```dart
    static const String baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000/api',
    );
    ```

    *Alternatively, pass the URL as a build argument:*
    ```bash
    flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8000/api
    ```

## Running the App

1.  Start a simulator/emulator or connect a physical device.
2.  Run the application:
    ```bash
    flutter run
    ```

## Key Features

-   **Dynamic Home**: The layout (banners, grids, carousels) is fetched from the backend.
-   **Location Awareness**: Users can select their city globally. The app passes `X-Location-Id` header to filter content relevant to that city.
-   **Offer Discovery**: Filter offers by Category, Bank, Card, or tags like "Trending" and "Featured".
-   **Card Management**: "Add Card" flow with mocked payment gateway simulation to unlock exclusive offers.
-   **State Management**: Uses **Riverpod** for robust state management (e.g., `LocationNotifier` for persisting city selection).

## Project Structure

-   `lib/core`: Shared utilities like `ApiClient` and Theme.
-   `lib/features`: Feature-based modular structure:
    -   `auth`: Login/Signup.
    -   `home`: Dynamic home screen logic.
    -   `offers`: Discovery and filtering integration.
    -   `location`: Global location selector and persistence.
    -   `cards`: Payment simulation and My Cards management.
