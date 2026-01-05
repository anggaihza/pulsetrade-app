# Changelog

All notable changes to the PulseTrade app will be documented in this file.

## [Unreleased] - 2026-01-05

### Added
- **Sign-In Screen**: Fully implemented login screen matching Figma design
  - Email/Phone number input field
  - Password input field with visibility toggle
  - Login button with loading state
  - Google Sign-In button
  - Create account link
  - Full localization support (English & Spanish)

- **Reusable Components** (in `lib/core/presentation/widgets/`)
  - `AppButton`: Primary and outlined button styles with loading state
  - `AppTextField`: Text input with label and password visibility toggle
  - `GoogleButton`: Google Sign-In button with SVG logo
  - `OrDivider`: Divider with centered "or" text

- **Design System** (in `lib/core/theme/`)
  - `AppColors`: Global color constants (Foundation colors from Figma)
  - `AppSpacing`: Consistent spacing values
  - `AppRadius`: Border radius constants
  - `AppTextStyles`: Centralized text styles (Montserrat font)
  - `AppTypography`: Typography system for ThemeData

- **Localization**
  - English translations (`app_en.arb`)
  - Spanish translations (`app_es.arb`)
  - All Sign-In screen text is localized

- **Documentation** (in `docs/`)
  - `overview.md`: Documentation hub and quick start guide
  - `architecture.md`: Clean architecture guide
  - `design-system.md`: Colors, typography, spacing reference
  - `components.md`: Reusable components guide
  - `localization.md`: i18n setup and usage guide
  - `features/sign-in.md`: Sign-In implementation details

### Changed
- **AppButton**: Updated to match Figma design (45px height, proper styling)
- **AppTextField**: Improved UX - entire field container is now clickable for focus
- **Documentation Structure**: Organized all docs into `docs/` folder

### Fixed
- Text field focus UX: Clicking anywhere inside the input field now focuses it
- Login button text color: Now correctly displays black text on blue background
- Input field styling: Dark background with no white fill
- All button heights: Consistent 45px height matching Figma

### Technical Details
- Uses `google_fonts` package for Montserrat font
- Uses `flutter_svg` for Google logo SVG rendering
- Implements FocusNode for better text field UX
- All user-facing text uses Flutter's l10n system

---

## Project Structure

```
pulsetrade_app/
├── lib/
│   ├── core/
│   │   ├── theme/              # Design system
│   │   └── presentation/       # Shared widgets
│   ├── features/
│   │   └── auth/               # Authentication feature
│   └── l10n/                   # Localization
├── assets/
│   └── images/                 # Images (Google logo, etc.)
├── docs/                       # 📖 Documentation
└── README.md                   # Project overview
```

## Next Steps

- [ ] Implement Register screen
- [ ] Add forgot password functionality
- [ ] Implement actual Google Sign-In
- [ ] Add form validation
- [ ] Add more languages (French, etc.)
- [ ] Add unit tests for components
- [ ] Add integration tests for auth flow

---

**Note**: This changelog follows [Keep a Changelog](https://keepachangelog.com/) format.

