<div align="center">

# Voice Memo

### A minimal Flutter voice recorder for quick local audio notes.

Record short voice notes, save them locally, and manage everything through a calm, smooth mobile interface.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State-BLoC-111111?style=flat-square)](https://bloclibrary.dev)
[![ObjectBox](https://img.shields.io/badge/Storage-ObjectBox-22A699?style=flat-square)](https://objectbox.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-f83700?style=flat-square)](LICENSE)

</div>

## Demo

https://github.com/user-attachments/assets/4b8fc35c-53ed-4603-b001-57928af025be


## Overview

`Voice Memos` is a Flutter app focused on a minimalistic and smooth recording experience: capture a voice note, name it, browse saved memos, and replay audio without unnecessary friction.

## Highlights

- Live voice recording with animated recording UI
- Waveform-style visual feedback while recording and playing audio
- Browse saved memos in a stacked card interface
- Play, pause, seek, rename, and delete memos

## Design Credit

This app is an independent Flutter implementation inspired by an external design concept.

- Concept reference: [Instagram post](https://www.instagram.com/p/DTsJbGvEVcC/?epik=dj0yJnU9NVQ4aG1Qd0NYX0Z6Q2w5NmxFR3dyNzE2aExCTmU2R3ImcD0wJm49NFh2LUdMejZ4TlJxOVZnZlFVM0ZzZyZ0PUFBQUFBR25fbExF)
- Designer profile: [Nina Skrbic](https://www.instagram.com/nina.skrbic_/)

This repository is not affiliated with Instagram or the original designer.

## Tech Stack

| Area | Tools |
| --- | --- |
| App | Flutter, Dart |
| State management | `bloc` |
| Audio | `record`, `just_audio` |
| Local storage | `ObjectBox` |
| Dependency injection | `get_it`, `injectable` |
| Code generation | `Freezed` |
| Testing | `flutter_test`, `bloc_test`, `mocktail` |

## Structure

```text
lib/
  data/          ObjectBox models, converters, repository implementation
  domain/        Core entities and repository contracts
  presentation/  Screens, dialogs, widgets, styles, and BLoCs
  utils/         Audio services, DI setup, formatters, notifications, helpers
```

## Getting Started

### Prerequisites

- Flutter SDK compatible with `.fvmrc`
- Dart SDK `^3.11.4`
- Xcode for iOS builds
- Android Studio or Android SDK for Android builds

### Install Dependencies

```bash
flutter pub get
```

### Generate Code

The project uses generated files for Freezed, Injectable, and ObjectBox.

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run

```bash
flutter run
```

## Quality Checks

```bash
flutter analyze
flutter test
```

## License

This project is released under the [MIT License](LICENSE).
