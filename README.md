# 🗳️ E-Voting.org — Premium Flutter eVotting System

[![Flutter Version](https://img.shields.io/badge/Flutter-%E2%89%A53.11.5-02569B?logo=flutter&style=for-the-badge)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%E2%89%A53.0-0175C2?logo=dart&style=for-the-badge)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-blue?style=for-the-badge)](https://flutter.dev)
[![Developer](https://img.shields.io/badge/Developer-Hitesh%20Prajapati-FF6B6B?style=for-the-badge)](https://github.com)

A premium, modern, and highly secure **E-Voting Application** built with Flutter and Dart. Designed with modern aesthetics, rich gradients, smooth transitions, and premium visual components to deliver a world-class digital voting experience.

---

## ✨ Features

*   **🌅 Immersive Splash Screen**: Features an elegant gradient backdrop (`Deep Blue` to `Teal`), app identity logo, animated circular loaders, and a timed transition to the main interface.
*   **📂 Structured Home Dashboard**: A premium bottom-navigation setup allowing effortless toggle between:
    *   🗳️ **Elections**: Complete list of regional elections with city-based filtering.
    *   📊 **Results**: Real-time progress visualizer for declared or ongoing votes.
    *   ⚙️ **Settings**: Profile, privacy control, and application details.
*   **⚡ Comprehensive CRUD on Elections**:
    *   ➕ **Create**: Add new elections on the fly with custom titles, dates, and cities via an elegant modal dialog.
    *   🔍 **Read & Filter**: View full cards with detailed information and filter dynamically using a location dropdown.
    *   ✏️ **Update**: Edit existing election parameters instantly.
    *   ❌ **Delete**: Safely remove outdated elections from the interface.
*   **📱 Detailed Election Hub**: A dedicated preview screen showcasing specific election information, complete with:
    *   👑 A gorgeous circular icon emblem highlighting the theme.
    *   ◀️ Modern custom iOS-style back-buttons and interactive action components.
*   **🛣️ App Routing & Architecture**: Decoupled routes configuration (`AppRoutes`) ensuring professional-grade maintainability and scalability.

---

## 🎨 Design System & Colors

Our design system utilizes premium, high-contrast, and harmonic colors:

| Token / Color | Hex Value | Preview | Role |
| :--- | :--- | :---: | :--- |
| **Primary Blue** | `#1A2980` | <img src="https://via.placeholder.com/15/1A2980/000000?text=+" width="15" height="15" /> | Main brand color, AppBars, Primary buttons |
| **Vibrant Cyan** | `#26D0CE` | <img src="https://via.placeholder.com/15/26D0CE/000000?text=+" width="15" height="15" /> | Secondary accent color for background gradients |
| **Light BG** | `#F4F8FB` | <img src="https://via.placeholder.com/15/F4F8FB/000000?text=+" width="15" height="15" /> | Screen background for soft contrast and readability |
| **Pure White** | `#FFFFFF` | <img src="https://via.placeholder.com/15/FFFFFF/000000?text=+" width="15" height="15" /> | Card backgrounds, Bottom Navigation background |

---

## 📁 File Structure

```text
lib/
├── main.dart                  # Application entry point, Theme Setup, & Material 3 configurations
├── routes/
│   └── app_routes.dart        # Unified static app routing names
└── screens/
    ├── splashScreen.dart       # Elegant introductory splash screen with gradient and timers
    ├── home_screen.dart        # Dashboard scaffold containing the bottom navigation bar
    ├── elections_page.dart     # Central hub managing interactive CRUD & city filter dropdown
    ├── election_detail_screen.dart # Beautiful focal screen with bespoke iOS navigation buttons
    ├── results_page.dart       # High-fidelity election outcomes screen
    └── settings_page.dart      # Quick configuration, profile, and app information page
```

---

## 🚀 Getting Started

Follow these steps to run the E-Voting application locally on your machine.

### 📋 Prerequisites

*   Install the latest version of the [Flutter SDK](https://docs.flutter.dev/get-started/install) (Ensure it's version `3.11.5` or higher).
*   An IDE (e.g., [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)) with Flutter & Dart extensions installed.
*   An active emulator, simulator, or connected physical testing device.

### ⚙️ Installation

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/techsage05/Flutter_eVotting.git
    cd Flutter_eVotting
    ```

2.  **Get Package Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the App**:
    ```bash
    flutter run
    ```
    *(To select a specific target device, use `flutter run -d <device_name>`)*

4.  **Build Production Bundles** *(Optional)*:
    *   **Android APK**: `flutter build apk --release`
    *   **Web Production**: `flutter build web --release`
    *   **Windows Build**: `flutter build windows --release`

---

## 🔒 Security & Performance Guidelines

To maintain highest standards for actual production-grade deployment:
1.  **Biometric Lock**: Integrate biometric authentication (e.g. fingerprint, FaceID) on splash transition.
2.  **State Management**: Integrate `Provider`, `Bloc`, or `Riverpod` for large-scale data flow.
3.  **Encrypted Storage**: Utilize secure storage options like `flutter_secure_storage` to handle user tokens and voting credentials.

---

## 👨‍💻 Author

Created with ❤️ by **Hitesh Prajapati**

---
*Developed under [techsage05/Flutter_eVotting](https://github.com/techsage05/Flutter_eVotting).*
