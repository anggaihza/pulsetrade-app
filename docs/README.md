# PulseTrade App Documentation

Welcome to the PulseTrade app documentation! This guide will help you understand the project structure, design system, and how to work with the codebase.

## 📚 Documentation Index

### Getting Started
- [Main README](../README.md) - Project overview and setup

### Architecture & Design System
- [Architecture](./architecture.md) - Clean architecture, folder structure, and patterns
- [Design System](./design-system.md) - Colors, typography, spacing, and theme
- [Reusable Components](./components.md) - Shared UI components guide

### Features
- [Sign-In Screen](./features/sign-in.md) - Sign-in implementation details

## 🏗️ Project Structure

```
pulsetrade_app/
├── lib/
│   ├── core/                    # Shared core functionality
│   │   ├── theme/              # Design system (colors, typography)
│   │   ├── presentation/       # Shared widgets
│   │   ├── router/             # Navigation
│   │   └── ...
│   └── features/               # Feature modules
│       ├── auth/               # Authentication
│       ├── home/               # Home screen
│       ├── settings/           # Settings
│       └── survey/             # Survey feature
├── assets/                     # Images, icons, fonts
└── docs/                       # 📖 You are here!
```

## 🎨 Quick Links

### Design System
- **Colors**: [`lib/core/theme/app_colors.dart`](../lib/core/theme/app_colors.dart)
- **Typography**: [`lib/core/theme/typography.dart`](../lib/core/theme/typography.dart)
- **Theme**: [`lib/core/theme/app_theme.dart`](../lib/core/theme/app_theme.dart)

### Shared Components
- **Buttons**: [`lib/core/presentation/widgets/app_button.dart`](../lib/core/presentation/widgets/app_button.dart)
- **Text Fields**: [`lib/core/presentation/widgets/app_text_field.dart`](../lib/core/presentation/widgets/app_text_field.dart)
- **Google Button**: [`lib/core/presentation/widgets/google_button.dart`](../lib/core/presentation/widgets/google_button.dart)

## 🚀 Quick Start

### Using Design System
```dart
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

// Colors
Container(color: AppColors.primary)

// Typography
Text('Hello', style: AppTextStyles.bodyLarge())

// Spacing
Padding(padding: EdgeInsets.all(AppSpacing.screenPadding))
```

### Using Shared Components
```dart
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_text_field.dart';

// Button
AppButton(
  label: 'Submit',
  onPressed: () => _handleSubmit(),
  isLoading: _isLoading,
)

// Text Field
AppTextField(
  label: 'Email',
  placeholder: 'Enter your email',
  controller: _emailController,
)
```

## 📖 Documentation Standards

When adding new documentation:

1. **Feature Docs**: Add to `docs/features/`
2. **Component Docs**: Update `docs/components.md`
3. **Design Changes**: Update `docs/design-system.md`
4. **Architecture Changes**: Update `docs/architecture.md`

## 🤝 Contributing

When implementing new features:

1. ✅ Follow clean architecture patterns
2. ✅ Use existing design system (colors, typography)
3. ✅ Reuse shared components when possible
4. ✅ Document significant changes
5. ✅ Keep code consistent with existing patterns

## 📝 Need Help?

- Check the documentation in this folder
- Review similar implementations in the codebase
- Look at the Figma design files for UI specifications

---

**Last Updated**: January 2026

