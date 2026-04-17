# Flutter Expense Tracker

A cross-platform personal finance and expense tracking app built with Flutter, following clean architecture principles and the BLoC pattern for state management.

---

## Screenshots

> _Screenshots will be added after first release build._

| Home Screen | Add Expense | Statistics |
|---|---|---|
| ![Home](docs/screenshots/home.png) | ![Add](docs/screenshots/add_expense.png) | ![Stats](docs/screenshots/statistics.png) |

---

## Features

- **Expense Management** — Add, edit, and delete expenses with categories, notes, and dates
- **Category System** — Built-in and custom categories with color-coded icons
- **Statistics & Charts** — Monthly breakdowns via pie and bar charts (FL Chart)
- **Dark / Light Theme** — System-aware theming with Material Design 3
- **Offline First** — All data stored locally via SQLite (sqflite)
- **Currency Formatting** — Locale-aware currency and date formatting
- **Filtering** — Filter expenses by date range or category
- **Summary Cards** — At-a-glance monthly totals and category breakdowns

---

## Architecture

This project follows a **Feature-First Clean Architecture** with the **BLoC** pattern.

```
lib/
├── bloc/              # Business Logic Components (BLoC)
│   └── expense/
│       ├── expense_bloc.dart
│       ├── expense_event.dart
│       └── expense_state.dart
├── config/            # App-wide configuration
│   ├── routes.dart
│   └── theme.dart
├── data/              # Data layer (repositories, DAOs)
│   └── database_helper.dart
├── models/            # Pure Dart data models
│   ├── expense.dart
│   └── category.dart
├── screens/           # Full-page UI screens
│   ├── home_screen.dart
│   ├── add_expense_screen.dart
│   └── statistics_screen.dart
├── utils/             # Helpers and formatters
│   └── formatters.dart
├── widgets/           # Reusable UI components
│   ├── chart_widget.dart
│   ├── expense_card.dart
│   └── summary_card.dart
└── main.dart
```

**Data flow:**

```
UI (Screen/Widget)
    │  dispatches Event
    ▼
BLoC (ExpenseBloc)
    │  reads/writes via
    ▼
DatabaseHelper (sqflite)
    │  emits State
    ▼
UI rebuilds via BlocBuilder
```

---

## Tech Stack

| Layer | Package |
|---|---|
| State Management | `flutter_bloc` ^8.1.3 |
| Local Database | `sqflite` ^2.3.0 |
| Charts | `fl_chart` ^0.66.2 |
| Internationalization | `intl` ^0.19.0 |
| Dependency Injection | `get_it` ^7.6.4 |
| Path Resolution | `path_provider` ^2.1.2 |
| UUID Generation | `uuid` ^4.3.3 |
| Equatable | `equatable` ^2.0.5 |

---

## Getting Started

### Prerequisites

- Flutter SDK >= 3.19.0
- Dart SDK >= 3.3.0
- Android Studio / Xcode (for device emulators)

### Installation

```bash
# Clone the repository
git clone https://github.com/shahabRDZ/flutter-expense-tracker.git
cd flutter-expense-tracker

# Install dependencies
flutter pub get

# Run on connected device / emulator
flutter run

# Run tests
flutter test

# Build release APK
flutter build apk --release

# Build iOS release
flutter build ios --release
```

### Environment

No environment variables or API keys are required. All data is stored locally on the device.

---

## CI / CD

GitHub Actions runs on every push and pull request to `main`:

1. **Analyze** — `flutter analyze` (static analysis)
2. **Test** — `flutter test` with coverage
3. **Build** — Debug APK artifact uploaded per run

See [`.github/workflows/flutter-ci.yml`](.github/workflows/flutter-ci.yml).

---

## Contributing

1. Fork the repo and create a feature branch (`git checkout -b feature/amazing-feature`)
2. Commit your changes following [Conventional Commits](https://www.conventionalcommits.org/)
3. Open a pull request — CI must pass before merging

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

## Join the Discussion

Have ideas or experience to share? Check out our open discussions:

- [Offline-first sync: CRDT vs event sourcing](https://github.com/shahabRDZ/flutter-expense-tracker/discussions/25)

We'd love to hear your thoughts!