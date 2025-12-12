# CI/CD Setup - Automatic Builds and Releases

## Overview

This project is configured with GitHub Actions to automatically build and release Android APKs whenever you push to the `main` branch.

## How It Works

### Automatic Versioning

- **Version Format**: Simple incremental versioning (v1, v2, v3, ...)
- **Auto-increment**: Each push to `main` automatically increments the version number
- **First build**: If no tags exist, it starts at v1

### Build Process

Every push to `main` triggers:

1. ✅ **Version Calculation**: Finds the latest Git tag and increments it
2. ✅ **Version Update**: Updates `pubspec.yaml` with new version (e.g., 0.5.0)
3. ✅ **Dependencies**: Runs `flutter pub get`
4. ✅ **Build APK**: Creates a release APK using `flutter build apk --release`
5. ✅ **Git Tag**: Creates and pushes a new Git tag (e.g., v5)
6. ✅ **GitHub Release**: Creates a GitHub Release with the APK attached

### What You Get

After each push to `main`:

- **New Git Tag**: e.g., `v1`, `v2`, `v3`...
- **GitHub Release**: Found in the "Releases" section of your repository
- **Downloadable APK**: Named `auto-books-v[X].apk`
- **Release Notes**: Automatically generated with build info

## Usage

### Making a Release

Simply push to main:

```bash
git add .
git commit -m "Your changes"
git push origin main
```

The workflow will automatically:
- Build the APK
- Create version v[X+1]
- Publish to GitHub Releases

### Downloading APKs

1. Go to your GitHub repository
2. Click on "Releases" (right sidebar)
3. Find the version you want
4. Download the `auto-books-v[X].apk` file

### Installing on Android Device

1. Download the APK from GitHub Releases
2. Transfer to your Android device
3. Enable "Install from Unknown Sources" in Settings
4. Tap the APK file to install

## Version History

You can view all versions in:
- **GitHub Releases**: https://github.com/zvikazm/AutoBoosAndroid/releases
- **Git Tags**: Run `git tag -l` locally

## Current Version

Check the latest version:
```bash
git describe --tags --abbrev=0
```

Or visit: https://github.com/zvikazm/AutoBoosAndroid/releases/latest

## Workflow File

The workflow is defined in: `.github/workflows/android-build.yml`

## Signing

Currently using **debug signing** for convenience. For production releases, you should:

1. Create a release keystore
2. Add keystore to GitHub Secrets
3. Update workflow to use release signing
4. Update `android/app/build.gradle.kts` with signing config

## Troubleshooting

### Build Failed

Check the Actions tab: https://github.com/zvikazm/AutoBoosAndroid/actions

### Version Not Incrementing

Ensure tags are being pushed:
```bash
git fetch --tags
git tag -l
```

### APK Not in Release

Check workflow logs in the Actions tab for errors during the release step.

## Manual Build

To build locally:

```bash
# Debug build
flutter build apk --debug

# Release build (uses debug signing)
flutter build apk --release
```

The APK will be in: `build/app/outputs/flutter-apk/`
