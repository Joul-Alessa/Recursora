# Recursora — Focus Cyclic System

> **Your next step is always clear.**

Recursora is a minimalist mobile app built with Flutter that helps you make progress across multiple life areas — without depending on a calendar. Instead of scheduling tasks by day of the week, Recursora tracks *where you are* in each cyclic list, so when you return to an area, you always know exactly what comes next.

---

## Motivation

Managing many projects and life areas (gym routines, software projects, content creation, etc.) with a fixed weekly schedule creates a rigid system: if Monday is "leg day" and you miss it, the whole week is thrown off. The same happens with project work.

Recursora solves this with a single insight: **order matters, dates don't.** Every group has an ordered list of items. You advance to the next item only when you complete the current one, regardless of how much time passes between sessions.

**This is not Habitica.** Recursora does not:
- Gamify habits or reward streaks
- Reset progress when you "miss a day"
- require any frequency or consistency

It simply maintains the state of your cycles so you always know what comes next, every time you come back.

---

## What Recursora Does

| Feature | Description |
|---|---|
| **Roadmap groups** | Create named groups for different life areas (Gym, Projects, Content, etc.) |
| **Ordered item lists** | Add items to each group in the order you want to cycle through them |
| **Current item tracking** | Each group remembers exactly where you left off |
| **One-tap advancement** | Press "Next" to mark the current item done and move forward cyclically |
| **Circular cycling** | When you reach the end of the list it wraps back to the beginning automatically |
| **Previous / next context** | Each group card shows the item before and after the current one for orientation |
| **Inline item editing** | Edit item names directly in the list without modals or extra screens |
| **Drag-to-reorder** | Reorder both groups and items within a group via drag handles |
| **Fully offline** | All data is stored locally on the device as a JSON file — no account, no backend, no internet required |

---

## Screenshots

_Coming soon._

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) |
| Language | Dart `^3.11.0` |
| State management | Flutter `StatefulWidget` (local state) |
| Local storage | JSON file via [`path_provider`](https://pub.dev/packages/path_provider) `^2.1.2` |
| Image utilities | [`image_picker`](https://pub.dev/packages/image_picker) `^1.0.7` |
| Linting | [`flutter_lints`](https://pub.dev/packages/flutter_lints) `^6.0.0` |
| App icon generation | [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) `^0.13.1` |
| Target platforms | Android, iOS |

---

## Data Model

All data is persisted as a single JSON file (`roadmaps.json`) in the device's application documents directory.

```json
{
  "roadmaps": [
    {
      "name": "Gym",
      "description": "My gym routine",
      "currentIndex": 2,
      "items": [
        { "item": "Arms" },
        { "item": "Chest" },
        { "item": "Back" },
        { "item": "Legs" }
      ]
    }
  ],
  "recursora_version": "1.0.0"
}
```

`currentIndex` is the only mutable pointer per group. Advancing to the next item is computed as:

```dart
currentIndex = (currentIndex + 1) % items.length;
```

---

## Project Structure

```
recursora/
└── lib/
    ├── main.dart                         # App entry point
    └── src/
        ├── data/
        │   └── local_file_service.dart   # Read/write roadmaps.json
        └── presentation/
            ├── home_page.dart            # Main screen — list of all groups
            └── add_roadmap_page.dart     # Create / edit a group and its items
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.11.0`)
- Android Studio / Xcode for device or emulator targets

### Run locally

```bash
cd recursora
flutter pub get
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

---

## Roadmap

- [ ] Publish to Google Play Store
- [ ] Publish to Apple App Store
- [ ] Dark mode support
- [ ] Per-item notes
- [ ] Optional cloud sync / backup (future backend)
- [ ] Pro tier: unlimited groups, cloud backup

---

## Philosophy

Recursora is designed around three principles:

1. **No calendar dependency** — progress is measured in cycles, not dates.
2. **Zero guilt** — missing a session never resets or penalizes anything.
3. **Radical focus** — when it's time for an area, only that area exists.

---

## License

Private — all rights reserved. Not open source at this time.
