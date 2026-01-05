# Reusable Components Guide

This document describes the shared, reusable components that can be used across the entire app.

## 📁 Location

All reusable components are in:
```
lib/core/presentation/widgets/
```

## 🎯 Available Components

### 1. **AppButton** - Primary/Outlined Button

**File:** `lib/core/presentation/widgets/app_button.dart`

**Usage:**
```dart
// Primary button (filled with blue background)
AppButton(
  label: 'Login',
  onPressed: () => _handleLogin(),
)

// With loading state
AppButton(
  label: 'Login',
  onPressed: () => _handleLogin(),
  isLoading: true,
)

// Outlined button (transparent with border)
AppButton(
  label: 'Cancel',
  onPressed: () => _handleCancel(),
  isPrimary: false,
)

// With icon
AppButton(
  label: 'Save',
  onPressed: () => _handleSave(),
  icon: Icon(Icons.save, size: 20),
)
```

**Properties:**
- `label` (String, required) - Button text
- `onPressed` (VoidCallback?, required) - Tap handler
- `isLoading` (bool) - Shows loading spinner (default: false)
- `isPrimary` (bool) - Primary (filled) or outlined style (default: true)
- `icon` (Widget?) - Optional icon before label

**Features:**
- ✅ Matches Figma design (45px height, 12px radius)
- ✅ Loading state with spinner
- ✅ Primary (blue) and outlined styles
- ✅ Disabled state when loading
- ✅ Uses AppTextStyles for consistency

---

### 2. **AppTextField** - Text Input with Label

**File:** `lib/core/presentation/widgets/app_text_field.dart`

**Usage:**
```dart
// Basic text field
AppTextField(
  label: 'Email',
  placeholder: 'Enter your email',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
)

// Password field with visibility toggle
AppTextField(
  label: 'Password',
  placeholder: 'Enter your password',
  controller: _passwordController,
  obscureText: true,
)

// With custom suffix icon
AppTextField(
  label: 'Search',
  placeholder: 'Type to search',
  suffixIcon: Icon(Icons.search),
  onSuffixIconTap: () => _handleSearch(),
)

// With onChange callback
AppTextField(
  label: 'Username',
  placeholder: 'Choose username',
  onChanged: (value) => _validateUsername(value),
)
```

**Properties:**
- `label` (String, required) - Field label above input
- `placeholder` (String, required) - Hint text
- `controller` (TextEditingController?) - Text controller
- `keyboardType` (TextInputType?) - Keyboard type
- `obscureText` (bool) - Hide text for passwords (default: false)
- `onChanged` (ValueChanged<String>?) - Text change callback
- `suffixIcon` (Widget?) - Custom suffix icon
- `onSuffixIconTap` (VoidCallback?) - Suffix icon tap handler

**Features:**
- ✅ Dark surface background (#2C2C2C)
- ✅ Label above field
- ✅ Auto password visibility toggle
- ✅ Custom suffix icons
- ✅ Matches Figma design (45px height, 12px radius)

---

### 3. **GoogleButton** - Google Sign-In Button

**File:** `lib/core/presentation/widgets/google_button.dart`

**Usage:**
```dart
// Default label
GoogleButton(
  onPressed: () => _handleGoogleSignIn(),
)

// Custom label
GoogleButton(
  label: 'Sign in with Google',
  onPressed: () => _handleGoogleSignIn(),
)
```

**Properties:**
- `onPressed` (VoidCallback?, required) - Tap handler
- `label` (String) - Button text (default: 'Continue with Google')

**Features:**
- ✅ Official Google logo from SVG
- ✅ Outlined style (transparent with border)
- ✅ Customizable label
- ✅ Matches Figma design

---

### 4. **AppCard** - Card Container

**File:** `lib/core/presentation/widgets/app_card.dart`

**Usage:**
```dart
AppCard(
  child: Column(
    children: [
      Text('Title'),
      Text('Content'),
    ],
  ),
)
```

**Features:**
- ✅ Consistent card styling
- ✅ Rounded corners
- ✅ Proper elevation

---

### 5. **AppInput** (Legacy)

**File:** `lib/core/presentation/widgets/app_input.dart`

**Note:** Consider migrating to `AppTextField` for new code.

---

## 🎨 Design System Integration

All components use the centralized design system:

```dart
// Colors
import 'package:pulsetrade_app/core/theme/app_colors.dart';
AppColors.primary, AppColors.background, etc.

// Typography
import 'package:pulsetrade_app/core/theme/typography.dart';
AppTextStyles.bodyLarge(), AppTextStyles.buttonPrimary(), etc.

// Spacing
AppSpacing.screenPadding, AppSpacing.fieldGap, etc.

// Border Radius
AppRadius.button, AppRadius.field, etc.
```

## 📝 Best Practices

### ✅ DO:
- Use these shared components for consistency
- Import from `lib/core/presentation/widgets/`
- Use `AppTextStyles` for text styling
- Use `AppColors` for colors

### ❌ DON'T:
- Create screen-specific components for common UI elements
- Duplicate button/input logic
- Use inline styles
- Create new components without checking if one exists

## 🔄 Migration Example

**Before (Screen-specific):**
```dart
// ❌ In lib/features/auth/presentation/widgets/
sign_in_text_field.dart
google_sign_in_button.dart
```

**After (Shared & Reusable):**
```dart
// ✅ In lib/core/presentation/widgets/
app_text_field.dart     // Generic name, works everywhere
google_button.dart      // Generic name, works everywhere
app_button.dart         // Updated to match Figma design
```

## 🚀 Usage in Screens

**Example: Login Screen**
```dart
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_text_field.dart';
import 'package:pulsetrade_app/core/presentation/widgets/google_button.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          label: 'Email',
          placeholder: 'Enter email',
        ),
        AppTextField(
          label: 'Password',
          placeholder: 'Enter password',
          obscureText: true,
        ),
        AppButton(
          label: 'Login',
          onPressed: () => _login(),
        ),
        GoogleButton(
          onPressed: () => _googleSignIn(),
        ),
      ],
    );
  }
}
```

## 📊 Component Comparison

| Component | Old Name | New Name | Location |
|-----------|----------|----------|----------|
| Text Field | `SignInTextField` | `AppTextField` | `core/presentation/widgets/` |
| Google Button | `GoogleSignInButton` | `GoogleButton` | `core/presentation/widgets/` |
| Primary Button | Custom code | `AppButton` | `core/presentation/widgets/` |

## 🎯 Benefits

1. **Consistency** - Same look & feel across the app
2. **Maintainability** - Update once, applies everywhere
3. **Reusability** - Use in any screen/feature
4. **Type Safety** - Compile-time checks
5. **Documentation** - Clear usage examples
6. **Figma Alignment** - Matches design system exactly

## 📚 Next Steps

When creating new screens:
1. Check `lib/core/presentation/widgets/` first
2. Use existing components when possible
3. Only create new components if truly unique
4. If creating new shared component, put it in `core/presentation/widgets/`
5. Use generic names (not screen-specific)

