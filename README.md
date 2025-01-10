# Habit Tracker

Habit Tracker is a cross-platform Flutter application designed to help users build and maintain healthy habits. Available on Android, iOS, and web platforms, Habit Tracker offers a seamless experience to track daily routines, set goals, and monitor progress.

## Table of Contents

- [Features](#features)
- [Platforms](#platforms)
- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Running the App](#running-the-app)
- [Testing](#testing)
- [CI/CD Pipeline](#cicd-pipeline)
    - [Workflow Overview](#workflow-overview)
    - [CI Workflow (`ci.yml`)](#ci-workflow-ciyml)
    - [Deploy Web Workflow (`deploy-web.yml`)](#deploy-web-workflow-deploy-webyml)

## Features

- **Track Habits:** Add, edit, and delete habits.
- **Progress Monitoring:** Visualize your habit streaks and progress.
- **Notifications:** Receive reminders to complete your habits.
- **Cross-Platform Support:** Available on Android, iOS, and web.

## Platforms

- **Android**
- **iOS**
- **Web**

## Getting Started

Follow these instructions to set up the Habit Tracker project locally for development and testing purposes.

### Prerequisites

- **Flutter SDK:** [Install Flutter](https://flutter.dev/docs/get-started/install) (version 3.24.3)
- **Dart SDK:** Included with Flutter
- **Git:** [Install Git](https://git-scm.com/downloads)
- **Node.js & npm:** Required for web deployment
- **IDE:** [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)

### Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/denkiri/habit_tracker
   cd HabitTracker
   ## Running and Building the App

You can run and build the app on Android, iOS, or Web platforms. Follow the steps below based on your target platform.

### Android

1. **Set Up an Android Device or Emulator**
  - **Physical Device:**
    - Enable **Developer Options** and **USB Debugging** on your Android device.
    - Connect your device via USB.
  - **Emulator:**
    - Open **Android Studio**.
    - Go to **AVD Manager** and create a new virtual device.
    - Start the emulator.

2. **Run the App**
   Execute the following command in the terminal:
   ```bash
   flutter run -d android
- Build the APK To generate a release APK.
    ```bash
  flutter build apk --release
- Build the App Bundle
   ```bash
  flutter build appbundle --release
  CI/CD Pipeline
The Habit Tracker project uses GitHub Actions for continuous integration and deployment. Workflow files are stored in the .github/workflows/ directory.

## Workflow Overview
### CI Workflow (ci.yml)
```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - master
  pull_request:
    branches:
      - master

jobs:
  build:
    name: Flutter CI
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.3'

      - name: Install Dependencies
        run: flutter pub get

      - name: Run Tests
        run: flutter test

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
```
- Builds the app, runs tests, and generates APK artifacts.
### Deploy Web Workflow (deploy-web.yml)
```yaml
name: Deploy Web App to GitHub Pages

on:
  push:
    branches:
      - master
  pull_request:
    branches:
      - master

jobs:
  build:
    name: Flutter CI
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.3'

      - name: Install Dependencies
        run: flutter pub get

      - name: Build Web
        run: flutter build web

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: build/web
          publish_branch: gh-pages
```
- Builds and deploys the web version of the app to GitHub Pages.



   
   


