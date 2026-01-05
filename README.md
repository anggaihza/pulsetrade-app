# PulseTrade App

A modern Flutter application built with Clean Architecture principles, featuring a beautiful dark-themed UI and comprehensive localization support.

## 📱 Features

- ✅ **Authentication**

  - Sign-In with email/password
  - Google Sign-In integration (UI ready)
  - Account creation
  - Secure token storage

- ✅ **Modern UI/UX**

  - Dark theme based on Figma design
  - Responsive layouts
  - Smooth animations
  - Reusable component library

- ✅ **Internationalization**

  - English (en)
  - Spanish (es)
  - Easy to add more languages

- ✅ **State Management**

  - Riverpod 3.0
  - Type-safe providers
  - Async state handling

- ✅ **Navigation**
  - GoRouter for declarative routing
  - Deep linking support
  - Type-safe navigation

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                   # Shared functionality
│   ├── theme/             # Design system (colors, typography)
│   ├── presentation/      # Reusable widgets
│   ├── router/            # Navigation setup
│   └── ...
├── features/              # Feature modules
│   ├── auth/             # Authentication
│   ├── home/             # Home screen
│   ├── settings/         # Settings
│   └── survey/           # Survey feature
└── l10n/                 # Localization files
```

Each feature follows the layered architecture:

- **Presentation**: UI, widgets, state management
- **Domain**: Business logic, entities, use cases
- **Data**: Repositories, data sources, models

📚 **[Read more about architecture →](docs/architecture.md)**

## 🛠️ Tech Stack

| Category                   | Technology                              |
| -------------------------- | --------------------------------------- |
| **Framework**              | Flutter 3.x                             |
| **Language**               | Dart 3.x                                |
| **State Management**       | Riverpod 3.0                            |
| **Navigation**             | GoRouter                                |
| **Networking**             | Dio                                     |
| **Local Storage**          | Hive, SharedPreferences, Secure Storage |
| **Localization**           | Flutter i18n (ARB)                      |
| **Functional Programming** | fpdart                                  |
| **Code Generation**        | freezed, json_serializable              |
| **Fonts**                  | Google Fonts (Montserrat)               |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.x or higher)
- Dart SDK (3.x or higher)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio with Flutter plugin

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd pulsetrade_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate localization files**

   ```bash
   flutter gen-l10n
   ```

4. **Run code generation** (if needed)

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Environment Setup

Create environment configuration files if needed:

```dart
// lib/core/config/environment.dart
class Environment {
  static const String apiBaseUrl = 'YOUR_API_URL';
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
}
```

## 📖 Documentation

Comprehensive documentation is available in the `docs/` folder:

- **[Architecture Guide](docs/architecture.md)** - Clean architecture, folder structure, and patterns
- **[Design System](docs/design-system.md)** - Colors, typography, spacing, and theme
- **[Reusable Components](docs/components.md)** - Shared UI components guide
- **[Localization Guide](docs/localization.md)** - i18n setup and usage
- **[Features](docs/features/)** - Feature-specific documentation

## 🎨 Design System

The app uses a centralized design system for consistency:

### Colors

```dart
import 'package:pulsetrade_app/core/theme/app_colors.dart';

AppColors.primary        // #2979FF - Primary blue
AppColors.background     // #121212 - Dark background
AppColors.surface        // #2C2C2C - Card/field background
AppColors.textPrimary    // #FFFFFF - Main text
```

### Typography

```dart
import 'package:pulsetrade_app/core/theme/typography.dart';

AppTextStyles.displaySmall()  // 40px, Bold - Titles
AppTextStyles.bodyLarge()     // 14px, Regular - Body text
AppTextStyles.labelLarge()    // 14px, Bold - Labels
```

### Spacing

```dart
AppSpacing.screenPadding  // 24px - Screen edges
AppSpacing.fieldGap       // 16px - Between fields
AppSpacing.fieldHeight    // 45px - Button/field height
```

📚 **[Read more about design system →](docs/design-system.md)**

## 🧩 Reusable Components

### AppButton

```dart
AppButton(
  label: strings.login,
  onPressed: () => _handleLogin(),
  isLoading: isLoading,
)
```

### AppTextField

```dart
AppTextField(
  label: strings.email,
  placeholder: strings.emailPlaceholder,
  controller: _emailController,
)
```

### GoogleButton

```dart
GoogleButton(
  label: strings.continueWithGoogle,
  onPressed: () => _handleGoogleSignIn(),
)
```

📚 **[See all components →](docs/components.md)**

## 🌍 Localization

All user-facing text is localized:

```dart
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

final strings = AppLocalizations.of(context);
Text(strings.login)
Text(strings.welcomeMessage)
```

### Adding New Translations

1. Add keys to `lib/l10n/arb/app_en.arb` and `app_es.arb`
2. Run `flutter gen-l10n`
3. Use in code: `strings.yourNewKey`

📚 **[Read localization guide →](docs/localization.md)**

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## 📦 Building

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
flutter build ipa --release
```

### Web

```bash
flutter build web --release
```

## 📁 Project Structure

```
pulsetrade_app/
├── lib/
│   ├── core/                    # Shared/Core functionality
│   │   ├── config/             # Configuration
│   │   ├── error/              # Error handling
│   │   ├── network/            # HTTP client
│   │   ├── presentation/       # Shared widgets
│   │   ├── router/             # Navigation
│   │   ├── storage/            # Local storage
│   │   ├── theme/              # Design system
│   │   └── usecase/            # Base use case
│   ├── features/               # Feature modules
│   │   ├── auth/              # Authentication
│   │   ├── home/              # Home
│   │   ├── settings/          # Settings
│   │   └── survey/            # Survey
│   ├── l10n/                  # Localization
│   │   ├── arb/              # Translation files
│   │   └── gen/              # Generated files
│   └── main.dart              # App entry point
├── assets/                     # Images, fonts, etc.
├── docs/                       # Documentation
├── test/                       # Tests
└── pubspec.yaml               # Dependencies
```

## 🤝 Contributing

### Code Style

- Follow Flutter style guide
- Use Clean Architecture principles
- Reuse shared components
- Localize all user-facing text
- Write tests for new features

### Commit Messages

Use conventional commits:

```
feat: add user profile screen
fix: resolve login button issue
docs: update README
style: format code
refactor: improve auth flow
test: add login screen tests
```

### Pull Request Process

1. Create a feature branch
2. Make your changes
3. Write/update tests
4. Update documentation
5. Submit PR with clear description

## 📝 Development Guidelines

### DO ✅

- Use design system constants (colors, spacing, typography)
- Reuse shared components from `core/presentation/widgets/`
- Localize all text strings
- Follow Clean Architecture layers
- Write meaningful comments
- Handle errors gracefully

### DON'T ❌

- Hardcode colors, sizes, or text
- Create screen-specific components for common UI
- Skip localization
- Mix layer responsibilities
- Leave TODOs without tickets

## 🐛 Known Issues

- Google Sign-In integration pending
- Form validation needs enhancement
- Unit test coverage needs improvement

## 🗺️ Roadmap

- [ ] Complete Google Sign-In integration
- [ ] Add forgot password flow
- [ ] Implement biometric authentication
- [ ] Add unit and integration tests
- [ ] Support additional languages
- [ ] Add dark/light theme toggle
- [ ] Implement offline mode
- [ ] Add analytics

## 📄 License

[Add your license here]

## 👥 Team

[Add team members and contact information]

## 📞 Support

For questions or issues:

- Create an issue on GitHub
- Contact: [your-email@example.com]
- Documentation: [docs/](docs/)

---

**Built with ❤️ using Flutter**
