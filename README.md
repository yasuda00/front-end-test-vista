
# Vista Solutions - Frontend

A Flutter mobile application developed as part of the Vista Solutions technical assessment.

The application integrates with the Node.js REST API to manage companies and their services.

## Features

- View a list of companies.
- Display company registration numbers.
- View services associated with each company.
- Create new companies.
- Create new services.
- Select a company when creating a service.
- Form validation and error handling.
- API integration with loading indicators.

## Technology Stack

- Flutter
- Dart
- Provider (State Management)
- HTTP (API Requests)
- Material UI

## Requirements

- Flutter SDK
- Dart SDK
- Android Studio
- Android Emulator or Android Device
- Backend API running locally

## Installation

Clone the repository:

```bash
git clone https://github.com/yasuda00/front-end-test-vista.git
cd front-end-test-vista
```

Install dependencies:

```bash
flutter pub get
```

## Backend Configuration

The application communicates with the backend API.

API configuration is located in:

`lib/utils/constants.dart`

Default Android Emulator configuration:

```dart
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000';

  static const String companiesEndpoint = '/companies';
  static const String servicesEndpoint = '/services';
}
```

**Important:**

- Android Emulator: Use `10.0.2.2` to access the host machine's localhost.
- Physical Android Device: Replace the IP with your computer's local network IP address.
- Flutter Web: Use `localhost` instead of `10.0.2.2`.

Ensure the backend API and MySQL Server are running before launching the application.

Backend repository:

https://github.com/yasuda00/back-end-test-vista

## Running the Application

Start the backend API first:

```bash
npm run dev
```

Then, from the frontend project directory, check connected devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

To target a specific Android emulator:

```bash
flutter run -d emulator-5554
```

## Project Structure

```text
lib/
├── main.dart
├── models/
│   ├── company.dart
│   └── service.dart
├── providers/
│   ├── company_provider.dart
│   └── service_provider.dart
├── screens/
│   ├── company_list_screen.dart
│   ├── create_company_screen.dart
│   └── create_service_screen.dart
├── services/
│   └── api_service.dart
├── utils/
│   └── constants.dart
└── widgets/
```

## Validation

The application includes the following validations:

- Company name is required.
- Company registration number is required.
- Service name is required.
- A company must be selected.
- Service price is required and must be numeric.
- Negative service prices are not accepted.

## Build

To analyze the project:

```bash
flutter analyze
```

To create an Android APK:

```bash
flutter build apk --release
```

The generated APK can be found at:

`build/app/outputs/flutter-apk/app-release.apk`
