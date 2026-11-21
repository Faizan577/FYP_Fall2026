# Baghbani

Baghbani is a single-account Flutter app for agriculture, gardening, nurseries and community discovery.

## Run locally

1. Install Flutter and configure an Android, iOS, web or desktop target.
2. Run flutter pub get.
3. Run flutter run.

## Current scope

The current build includes onboarding, welcome, sign in, sign up, local password update, profile editing, Help & Guide, notifications and a single dashboard. Feature modules open a Coming Soon screen.

Account data is stored on the current device with shared_preferences; passwords are hashed before local storage. This is a development-only local authentication flow. Connect a production identity service before using real accounts or password recovery. Password recovery currently updates the matching local account directly.

The supplied Figma file could not be read in this session because the Figma connector and browser access were unavailable. The current palette and components are an agriculture-inspired implementation and still need a visual pass against the Figma reference.
