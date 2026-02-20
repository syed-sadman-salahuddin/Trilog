# Trilog - Connect & Share

Trilog is a vibrant and modern social media platform designed to bring people together. With a focus on real-time interaction and seamless media sharing, Trilog provides a premium social experience across both Android and iOS devices.

## Features

- **Personalized Profiles**: Express yourself with customizable cover photos and profile pictures. Showcase your profession and track your growing community with live follower counts.
- **Real-Time Feed**: Stay updated with a dynamic home feed that brings the latest posts from around the community straight to your screen.
- **Engaging Interactions**: Show love to your favorite posts with a simple like or join the conversation through the threaded comment system.
- **Stories**: Share your fleeting moments with temporary stories. Capture and upload directly from your gallery to keep your friends engaged.
- **Seamless Search**: Discover new people and professionals using the smart, live-filtering search tool.
- **Activity Alerts**: Never miss a beat with real-time notifications for likes, comments, and new followers.
- **Connection Management**: A secure follow system allows you to manage your social circle with follow requests and mutual connections.

## Tech Stack

Trilog is built using industry-standard technologies to ensure high performance, security, and scalability:

- **Framework**: [Flutter](https://flutter.dev/) - Enabling a single codebase for high-performance cross-platform apps.
- **Backend Services**: [Firebase](https://firebase.google.com/)
    - **Authentication**: Secure and reliable user sign-in and management.
    - **Realtime Database**: Powering live updates for feeds, comments, and notifications.
    - **Cloud Storage**: Fast and efficient hosting for all user-generated media.
- **Visuals & UX**:
    - **Shimmer**: Elegant loading placeholders for a smoother feel.
    - **Google Fonts**: Clean, modern typography using the Poppins font family.
    - **Cached Network Image**: High-performance image loading and caching for a lag-free experience.

## State Management

Trilog utilizes **Riverpod** as its primary state management solution. This choice ensures:
- **Scalability**: A clean, modular architecture that grows seamlessly with the application.
- **Reliability**: Compile-time safety for all state-related operations, reducing runtime errors.
- **Real-time Synchronization**: Efficient handling of dynamic data streams to keep the user interface perfectly in sync with the backend.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest Stable Version)
- [Dart SDK](https://dart.dev/get-started)
- IDE (Android Studio, VS Code, or IntelliJ) with Flutter extensions
- A Firebase project set up via the [Firebase Console](https://console.firebase.google.com/)

## Installation

Follow these steps to get Trilog running on your local machine:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/trilog.git
   cd trilog/sample_social_flutter
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**:
   - Download `google-services.json` from your Firebase project and place it in `android/app/`.
   - Download `GoogleService-Info.plist` (for iOS) and place it in `ios/Runner/`.
   - Ensure the `firebase_options.dart` file is present in the `lib/` directory with your project's unique configuration.

4. **Launch the App**:
   ```bash
   flutter run
   ```

## Acknowledgement

We would like to express our gratitude to the vibrant open-source community for the exceptional tools and packages that power Trilog. A special thanks to the teams behind Flutter, Riverpod, and Firebase for their innovative platforms that enable developers to build world-class applications.

---
