# Auto Books 📚

A Flutter mobile application for tracking borrowed books from the Kedumim library system in Israel.

![Build Status](https://github.com/zvikazm/AutoBoosAndroid/workflows/Android%20APK%20Build%20&%20Release/badge.svg)

## Features

- ✅ **Secure Authentication** - First-time login with encrypted credential storage
- ✅ **Auto-Login** - Credentials persist across app updates and restarts
- ✅ **Hebrew RTL Interface** - Full support for right-to-left text
- ✅ **Book Tracking** - View all borrowed books with return dates
- ✅ **Urgency Indicators** - Color-coded status (🔴 urgent ≤3 days, 🟡 soon ≤7 days, 🟢 ok >7 days)
- ✅ **Smart Sorting** - Books sorted by days remaining (urgent books first)
- ✅ **Pull-to-Refresh** - Easy data refresh with swipe gesture

## Download

### Latest Release
[![Download APK](https://img.shields.io/github/v/release/zvikazm/AutoBoosAndroid?label=Download%20APK&style=for-the-badge)](https://github.com/zvikazm/AutoBoosAndroid/releases/latest)

Visit the [Releases](https://github.com/zvikazm/AutoBoosAndroid/releases) page to download the latest APK.

### Installation
1. Download the APK file from the releases page
2. Enable "Install from Unknown Sources" in Android settings (if prompted)
3. Open the downloaded APK file
4. Follow the installation prompts
5. Launch the app and enter your library credentials on first run

## Building from Source

### Prerequisites
- Flutter SDK 3.24.5 or later
- Java 17 or later
- Android SDK

### Build Commands

```bash
# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## Automated Releases 🚀

This project uses GitHub Actions for automated APK building and releases.

### Build Triggers

The workflow automatically builds the APK when:

#### 1. **Version Tag Push** (Recommended for Releases)
Creates a new release with the APK attached:

```bash
# Update version in pubspec.yaml first
version: 1.0.0

# Commit and push
git add pubspec.yaml
git commit -m "Bump version to 1.0.0"
git push

# Create and push tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

**Result**: Automatically builds APK and creates GitHub Release `v1.0.0`

#### 2. **Manual Workflow Trigger** (For On-Demand Builds)
Trigger a build manually from GitHub:

1. Go to **Actions** tab in GitHub
2. Select **"Android APK Build & Release"** workflow
3. Click **"Run workflow"**
4. Enter version number (e.g., `1.0.0`)
5. Choose whether to create a release (`true`/`false`)
6. Click **"Run workflow"**

**Result**: Builds APK with specified version and optionally creates release

#### 3. **Push to Main Branch** (For Testing)
Builds APK automatically on code changes:

```bash
git add .
git commit -m "Updated UI"
git push origin main
```

**Result**: Builds APK but **doesn't create release**. APK available as workflow artifact for 90 days.

### Release Process

#### Quick Release (Using Tags)
```bash
# 1. Update version
version: 1.2.0

# 2. Commit
git add pubspec.yaml
git commit -m "Version 1.2.0"
git push

# 3. Tag and push
git tag v1.2.0
git push origin v1.2.0

# Done! Check GitHub releases in ~5 minutes
```

#### Manual Release (Using GitHub UI)
1. Navigate to **Actions** → **Android APK Build & Release**
2. Click **Run workflow**
3. Enter version: `1.2.0`
4. Select create release: `true`
5. Click **Run workflow**
6. Wait ~5 minutes for completion

### What Gets Included in Releases

Each release automatically includes:
- 📦 **APK file** - `auto_books-v{version}.apk`
- 📊 **File size** - Human-readable size
- 🔐 **SHA-256 checksum** - For security verification
- 📝 **Release notes** - Installation instructions and features
- 🔗 **Build logs** - Link to the GitHub Actions run

### Workflow Features

- ✅ **Java 17** - Modern, stable Java version
- ✅ **Flutter 3.24.5** - Latest stable Flutter
- ✅ **Caching** - Faster builds (~2-3 minutes after first run)
- ✅ **Artifacts** - APKs stored for 90 days
- ✅ **Clean builds** - Ensures consistency
- ✅ **Automatic versioning** - From tags or manual input

## Project Structure

```
lib/
├── main.dart                    # App entry point & authentication checker
├── models/
│   └── book.dart               # Book data model with status enum
├── screens/
│   ├── login_screen.dart       # First-time login UI (Hebrew RTL)
│   └── books_screen.dart       # Main book list display
└── services/
    ├── credentials_service.dart # Secure credential storage
    └── library_service.dart    # HTTP requests & HTML parsing

android/                         # Android-specific configuration
ios/                            # iOS-specific configuration (not used)
.github/workflows/              # GitHub Actions CI/CD
└── android-release.yml         # Automated APK build workflow
```

## Technology Stack

- **Framework**: Flutter 3.24.5
- **Language**: Dart 3.9.2
- **Secure Storage**: `flutter_secure_storage` (platform-native encryption)
- **HTTP Client**: `http` package
- **HTML Parsing**: `html` package
- **Date Formatting**: `intl` package

## Security

- **Encrypted Storage**: Credentials stored using platform-native encryption
  - Android: KeyStore/EncryptedSharedPreferences
  - iOS: Keychain (if needed)
- **No Plaintext**: Credentials never stored in plaintext
- **Session Management**: Proper cookie handling for library authentication
- **Checksum Verification**: SHA-256 hashes provided for APK downloads

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is for personal use with the Kedumim library system.

## Support

For issues or questions, please [open an issue](https://github.com/zvikazm/AutoBoosAndroid/issues) on GitHub.

---

**Made with ❤️ for the Kedumim Library Community**
