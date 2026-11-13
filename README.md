# Vista Solutions - Frontend

A modern, responsive Flutter mobile application developed as part of the Vista Solutions technical assessment.

The application integrates with the Node.js REST API to seamlessly manage companies and their associated services with modern UI/UX design patterns, robust client-side validation, and state management.

---

## 🌟 Key Features

- **Company Management**:
  - View companies with interactive collapsible gradient headers.
  - Display company registration numbers and service counts.
  - Pull-to-refresh data synchronization.
- **Service Management**:
  - View services associated with each company in formatted price chips (RM currency).
  - Create and link new services to existing companies.
- **Modern UI & Motion Design**:
  - **Material 3 Design System**: Clean typography using Google Fonts (Inter).
  - **Fluid Animations**: Smooth entrance transitions and micro-interactions powered by `flutter_animate`.
  - **Adaptive Header**: Dynamic collapsing gradient header that transforms between expanded title mode and pinned mini-logo mode.
  - **Optimized Performance**: Scoped state rebuilds and `const` widget trees for smooth 60fps scrolling.
- **Client-Side Form Validation**: Instant user feedback with error indicators, numeric constraints, and double-submit guards.
- **Error Handling**: Graceful network error recovery with retry prompts and friendly empty states.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (3.x)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider) (`ChangeNotifierProvider`, `Consumer`)
- **Networking**: [http](https://pub.dev/packages/http)
- **Typography**: [google_fonts](https://pub.dev/packages/google_fonts) (Inter)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)
- **Design System**: Material 3

---

## 📋 Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code
- Android Emulator or physical device
- Backend API running locally

---

## 🚀 Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yasuda00/front-end-test-vista.git
   cd front-end-test-vista
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

---

## ⚙️ Backend Configuration

API endpoints and base URLs are centralized in:

`lib/utils/constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000';

  static const String companiesEndpoint = '/companies';
  static const String servicesEndpoint = '/services';
}
```

> **Network Host Mapping:**
> - **Android Emulator**: Use `http://10.0.2.2:3000` (points to the host machine's `localhost`).
> - **Physical Android Device**: Replace `10.0.2.2` with your computer's local Wi-Fi IP address (e.g., `http://192.168.1.X:3000`).
> - **Flutter Web / Desktop**: Use `http://localhost:3000`.

*Ensure the backend API and database server are running before launching the application.*

Backend repository: [https://github.com/yasuda00/back-end-test-vista](https://github.com/yasuda00/back-end-test-vista)

---

## 📱 Running the Application

1. **Start the backend server first**:
   ```bash
   npm run dev
   ```

2. **Check connected devices**:
   ```bash
   flutter devices
   ```

3. **Run the Flutter application**:
   ```bash
   flutter run
   ```

   To target a specific emulator:
   ```bash
   flutter run -d emulator-5554
   ```

---

## 📁 Project Structure

```text
lib/
├── main.dart                          # App entry point, Material 3 theme & Provider setup
├── models/
│   ├── company.dart                   # Company data model & JSON deserialization
│   └── service.dart                   # Service data model & JSON deserialization
├── providers/
│   ├── company_provider.dart          # State management for fetching & creating companies
│   └── service_provider.dart          # State management for service creation
├── screens/
│   ├── company_list_screen.dart       # Main dashboard with animated list & sliver header
│   ├── create_company_screen.dart     # Company creation form with validation
│   └── create_service_screen.dart     # Service creation form with company dropdown & validation
├── services/
│   └── api_service.dart               # HTTP client service interacting with backend REST API
└── utils/
    └── constants.dart                 # API endpoints and configuration
```

---

## 🛡️ Form Validation & Security

The client application works in tandem with backend `express-validator` to provide both **immediate user experience** and **data integrity**:

- **Company Name**: Required, trimmed validation.
- **Registration Number**: Required, trimmed validation.
- **Company Selection**: Dropdown validation ensures a service is always mapped to a valid company.
- **Service Name**: Required, trimmed validation.
- **Service Price**:
  - Required and validated as numeric format.
  - Safe parsing against format exceptions.
  - Disallows negative numbers (`price >= 0`).
- **Double-Submit Protection**: Prevents duplicate submissions while asynchronous requests are executing.

---

## 🏗️ Build & Release

1. **Analyze Code**:
   ```bash
   flutter analyze
   ```

2. **Build Android APK (Release)**:
   ```bash
   flutter build apk --release
   ```

   The generated APK will be available at:
   `build/app/outputs/flutter-apk/app-release.apk`
