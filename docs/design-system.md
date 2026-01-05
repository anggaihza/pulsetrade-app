# Design System

The PulseTrade design system ensures consistency across the app with centralized colors, typography, spacing, and other design tokens based on Figma specifications.

## 📁 Location

All design system files are in:
```
lib/core/theme/
├── app_colors.dart    # Colors, spacing, border radius
├── typography.dart    # Text styles
└── app_theme.dart     # Theme configuration
```

## 🎨 Colors

**File**: `lib/core/theme/app_colors.dart`

### Foundation Colors

Based on Figma Foundation tokens:

```dart
// Foundation/White variants
AppColors.white          // #FFFFFF - Pure white
AppColors.whiteDark      // #DBDBDB - Darker white
AppColors.whiteNormal    // #E7E7E7 - Normal white
AppColors.whiteActive    // #AEAEAE - Active state

// Foundation/Black
AppColors.black          // #121212 - Background
AppColors.blackField     // #2C2C2C - Input fields, surfaces

// Foundation/Primary
AppColors.primaryNormal  // #2979FF - Primary blue
```

### Semantic Aliases

For better code readability, use semantic names:

```dart
// Background & Surfaces
AppColors.background     // Black (#121212)
AppColors.surface        // BlackField (#2C2C2C)

// Text Colors
AppColors.textPrimary    // White (#FFFFFF)
AppColors.textSecondary  // WhiteDark (#DBDBDB)
AppColors.textTertiary   // WhiteNormal (#E7E7E7)
AppColors.textLabel      // WhiteActive (#AEAEAE)

// Interaction Colors
AppColors.border         // WhiteDark (#DBDBDB)
AppColors.primary        // PrimaryNormal (#2979FF)
AppColors.onPrimary      // Black (#121212) - Text on primary buttons
```

### Usage

```dart
// Background
Container(color: AppColors.background)

// Text
Text('Hello', style: TextStyle(color: AppColors.textPrimary))

// Primary button
Container(
  color: AppColors.primary,
  child: Text('Login', style: TextStyle(color: AppColors.onPrimary)),
)

// Surface/Card
Container(color: AppColors.surface)
```

## ✏️ Typography

**File**: `lib/core/theme/typography.dart`

### Font Family

All text uses **Montserrat** from Google Fonts:
- Font weights: Regular (400), SemiBold (600), Bold (700)
- Loaded automatically via `google_fonts` package

### Text Styles

#### Display Styles

```dart
// Display Small - 40px, Bold
Text('Sign in', style: AppTextStyles.displaySmall())
// Custom color
Text('Sign in', style: AppTextStyles.displaySmall(color: Colors.blue))
```

#### Body Styles

```dart
// Body Large - 14px, Regular
Text('Ready to start?', style: AppTextStyles.bodyLarge())

// Body Medium - 12px, Regular
Text('Small text', style: AppTextStyles.bodyMedium())

// With custom color
Text('Subtitle', style: AppTextStyles.bodyLarge(color: AppColors.textSecondary))
```

#### Label Styles

```dart
// Label Large - 14px, Bold
Text('Login', style: AppTextStyles.labelLarge())

// Label Medium - 12px, SemiBold
Text('Email', style: AppTextStyles.labelMedium())
```

#### Special Styles

```dart
// Button Primary (Label Large with black color)
Text('Login', style: AppTextStyles.buttonPrimary())

// Button Outlined (Label Large with white color)
Text('Cancel', style: AppTextStyles.buttonOutlined())

// Text Field Input (Label Medium)
TextField(style: AppTextStyles.textFieldInput())

// Text Field Label (Label Medium)
Text('Email', style: AppTextStyles.textFieldLabel())

// Link (Label Large with underline)
Text('Create account', style: AppTextStyles.link())
```

### Typography Hierarchy

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `displaySmall` | 40px | Bold | Page titles |
| `bodyLarge` | 14px | Regular | Body text, descriptions |
| `bodyMedium` | 12px | Regular | Small body text |
| `labelLarge` | 14px | Bold | Button text, labels |
| `labelMedium` | 12px | SemiBold | Field labels, small labels |

### Customizing Text Styles

All text style methods accept an optional `color` parameter:

```dart
// Default color (textPrimary - white)
AppTextStyles.bodyLarge()

// Custom color
AppTextStyles.bodyLarge(color: AppColors.textSecondary)
AppTextStyles.bodyLarge(color: Colors.red)
```

## 📏 Spacing

**File**: `lib/core/theme/app_colors.dart` (in `AppSpacing` class)

### Standard Spacing Values

```dart
// Screen Padding
AppSpacing.screenPadding  // 24px - Main screen padding

// Gaps
AppSpacing.headerGap      // 40px - Between header and content
AppSpacing.fieldGap       // 16px - Between form fields
AppSpacing.fieldLabelGap  // 8px - Between label and input
AppSpacing.buttonIconGap  // 11px - Icon and text in buttons

// Component Heights
AppSpacing.fieldHeight    // 45px - Text fields, buttons
```

### Additional Spacing (if needed)

You can define additional spacing in your code:

```dart
// Common spacing values
const double xs = 4.0;
const double sm = 8.0;
const double md = 16.0;
const double lg = 24.0;
const double xl = 32.0;
const double xxl = 40.0;
```

### Usage

```dart
// Screen padding
Padding(
  padding: const EdgeInsets.all(AppSpacing.screenPadding),
  child: ...,
)

// Gap between elements
SizedBox(height: AppSpacing.fieldGap)

// Component height
Container(height: AppSpacing.fieldHeight)

// Custom spacing
SizedBox(height: 16) // Use directly for one-off spacing
```

## 🔲 Border Radius

**File**: `lib/core/theme/app_colors.dart` (in `AppRadius` class)

```dart
// Buttons
AppRadius.button  // 12px - All buttons

// Text Fields
AppRadius.field   // 12px - All input fields

// Cards
AppRadius.card    // 12px - Cards, containers
```

### Usage

```dart
// Button
BorderRadius.circular(AppRadius.button)

// Text field
BorderRadius.circular(AppRadius.field)

// Card
BorderRadius.circular(AppRadius.card)
```

## 🎭 Theme Configuration

**File**: `lib/core/theme/app_theme.dart`

### Light Theme

```dart
ThemeData light = AppTheme.light()
```

### Dark Theme (Current)

```dart
ThemeData dark = AppTheme.dark()
```

The dark theme uses:
- Background: `AppColors.background` (#121212)
- Surface: `AppColors.surface` (#2C2C2C)
- Primary: `AppColors.primary` (#2979FF)
- Text: `AppColors.textPrimary` (#FFFFFF)

### Accessing Theme in Widgets

```dart
// Access theme
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;
final textTheme = theme.textTheme;

// Use theme colors
Container(color: theme.colorScheme.primary)

// Use theme text styles
Text('Hello', style: theme.textTheme.bodyLarge)
```

However, **prefer using design system directly** for consistency:

```dart
// ✅ Preferred (explicit, consistent)
Container(color: AppColors.primary)
Text('Hello', style: AppTextStyles.bodyLarge())

// ⚠️ Use theme only for Material widgets that require it
```

## 📐 Figma Mapping

### Colors

| Figma Token | App Constant | Hex Value |
|-------------|--------------|-----------|
| Foundation/White/white | `AppColors.white` | #FFFFFF |
| Foundation/White/white-dark | `AppColors.whiteDark` | #DBDBDB |
| Foundation/White/white-normal | `AppColors.whiteNormal` | #E7E7E7 |
| Foundation/White/white-active | `AppColors.whiteActive` | #AEAEAE |
| Foundation/Black/black | `AppColors.black` | #121212 |
| Foundation/Black/black-field | `AppColors.blackField` | #2C2C2C |
| Foundation/Primary/primary-normal | `AppColors.primaryNormal` | #2979FF |

### Typography

| Figma Style | App Style | Font | Size | Weight |
|-------------|-----------|------|------|--------|
| display-small | `displaySmall()` | Montserrat | 40px | Bold |
| body-large | `bodyLarge()` | Montserrat | 14px | Regular |
| body-medium | `bodyMedium()` | Montserrat | 12px | Regular |
| label-large | `labelLarge()` | Montserrat | 14px | Bold |
| label-medium | `labelMedium()` | Montserrat | 12px | SemiBold |

### Spacing

| Figma | App Constant | Value |
|-------|--------------|-------|
| Screen padding | `AppSpacing.screenPadding` | 24px |
| Header gap | `AppSpacing.headerGap` | 40px |
| Field gap | `AppSpacing.fieldGap` | 16px |
| Field height | `AppSpacing.fieldHeight` | 45px |

## ✅ Best Practices

### DO:
```dart
// ✅ Use design system constants
Container(color: AppColors.primary)
Text('Hello', style: AppTextStyles.bodyLarge())
SizedBox(height: AppSpacing.fieldGap)
BorderRadius.circular(AppRadius.button)

// ✅ Use semantic color names
color: AppColors.textPrimary  // Not AppColors.white

// ✅ Pass custom colors as parameters
AppTextStyles.bodyLarge(color: Colors.red)
```

### DON'T:
```dart
// ❌ Hardcode colors
Container(color: Color(0xFF2979FF))  // Use AppColors.primary

// ❌ Hardcode text styles
Text('Hello', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400))
// Use AppTextStyles.bodyLarge()

// ❌ Hardcode spacing
SizedBox(height: 16)  // Define in AppSpacing or use existing constant

// ❌ Inline font definitions
GoogleFonts.montserrat(fontSize: 14, ...)
// Use AppTextStyles
```

## 🔄 Updating Design System

When Figma design changes:

1. **Update constants** in design system files
2. **Keep semantic names** (don't change `AppColors.primary`, just its value)
3. **Test across app** - changes apply globally
4. **Document changes** in this file

## 📱 Responsive Design

Currently, the design system uses fixed values. For responsive design:

```dart
// Get screen size
final screenWidth = MediaQuery.of(context).size.width;
final isSmallScreen = screenWidth < 600;

// Adjust spacing
final padding = isSmallScreen ? 16.0 : AppSpacing.screenPadding;

// Or use LayoutBuilder
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return CompactLayout();
    } else {
      return WideLayout();
    }
  },
)
```

## 🎯 Quick Reference

```dart
// Import all at once
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

// Common patterns
Container(
  color: AppColors.background,
  padding: EdgeInsets.all(AppSpacing.screenPadding),
  child: Column(
    children: [
      Text('Title', style: AppTextStyles.displaySmall()),
      SizedBox(height: AppSpacing.headerGap),
      Text('Body', style: AppTextStyles.bodyLarge()),
    ],
  ),
)
```

---

**Remember**: Use the design system for **all** colors, typography, and spacing. This ensures consistency and makes global changes easy!

