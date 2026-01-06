# Toast/Snackbar System

## Overview
A standardized toast notification system that follows the app's design system with consistent styling for success, warning, and error messages.

## Location
- **Widget**: `lib/core/presentation/widgets/app_toast.dart`
- **Utils**: `lib/core/utils/toast_utils.dart`

## Features

### Toast Types
1. **Success Toast** - Green theme for successful operations
2. **Warning Toast** - Orange theme for warnings and info
3. **Error Toast** - Red theme for errors and validation failures

### Design Specifications

Colors are based on the [Figma Design System Color Palette](https://www.figma.com/design/33pzR0AFb7Hz3R11vuYtwW/Untitled?node-id=10-303&m=dev).

#### Success Toast
- **Icon**: `TablerIcons.circle_check`
- **Icon Color**: `#1BC865` (Green Normal)
- **Background**: `#094623` (Green Darker)

#### Warning Toast
- **Icon**: `TablerIcons.alert_triangle`
- **Icon Color**: `#FFC107` (Yellow Normal)
- **Background**: `#594402` (Yellow Darker)

#### Error Toast
- **Icon**: `TablerIcons.circle_x`
- **Icon Color**: `#FF4D4D` (Orange/Red Normal)
- **Background**: `#591B1B` (Orange/Red Darker)

### Common Properties
- **Border Radius**: 12px (AppRadius.card)
- **Padding**: 16px horizontal, 12px vertical
- **Behavior**: Floating
- **Duration**: 3 seconds (default, customizable)
- **Margin**: 16px from edges
- **Text Style**: Montserrat Regular, 14px, white

## Usage

### Method 1: Using Utility Functions (Recommended)

```dart
import 'package:pulsetrade_app/core/utils/toast_utils.dart';

// Success toast
showSuccessToast(context, 'Account created successfully!');

// Error toast
showErrorToast(context, 'Invalid email or password');

// Warning toast
showWarningToast(context, 'Session will expire soon');
```

### Method 2: Using AppToast Directly

```dart
import 'package:pulsetrade_app/core/presentation/widgets/app_toast.dart';

// With custom duration
AppToast.showSuccess(
  context,
  'Operation completed',
  duration: Duration(seconds: 5),
);

AppToast.showError(
  context,
  'Something went wrong',
  duration: Duration(seconds: 4),
);

AppToast.showWarning(
  context,
  'Please review your input',
);
```

## Examples

### Login Screen
```dart
// Error when credentials are empty
if (email.isEmpty || password.isEmpty) {
  showErrorToast(context, strings.pleaseEnterEmailPassword);
  return;
}

// Error from API
if (loginFailed) {
  showErrorToast(context, 'Invalid credentials');
}
```

### Register Screen
```dart
// Validation error
if (!_acceptedTerms) {
  showErrorToast(context, strings.pleaseAcceptTerms);
  return;
}

// Warning for unimplemented feature
showWarningToast(context, strings.googleSignInNotImplemented);
```

### OTP Verification Screen
```dart
// Error for incomplete OTP
if (_otpCode.length != 6) {
  showErrorToast(context, strings.otpCodeRequired);
  return;
}

// Success when code is resent
showSuccessToast(context, strings.resendCode);
```

### Create Password Screen
```dart
// Error when requirements not met
if (!_isPasswordValid) {
  showErrorToast(context, strings.pleaseCompletePasswordRequirements);
  return;
}

// Success when password is created
showSuccessToast(context, 'Password created successfully!');
```

## Implementation Details

### Toast Structure
```dart
Row(
  children: [
    Icon(
      icon,              // Type-specific icon
      color: iconColor,  // Type-specific color
      size: 24,
    ),
    SizedBox(width: 12),
    Expanded(
      child: Text(
        message,
        style: AppTextStyles.bodyMedium(
          color: AppColors.textPrimary,
        ).copyWith(fontSize: 14),
      ),
    ),
  ],
)
```

### SnackBar Configuration
```dart
SnackBar(
  content: _ToastContent(...),
  backgroundColor: config.backgroundColor,
  duration: duration,
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.card),
  ),
  margin: const EdgeInsets.all(16),
  padding: EdgeInsets.zero,
)
```

## Best Practices

### When to Use Each Type

**Success Toast**:
- Account created
- Password updated
- Code resent
- Operation completed successfully

**Warning Toast**:
- Feature not yet implemented
- Session expiring soon
- Non-critical issues
- Informational messages

**Error Toast**:
- Validation failures
- API errors
- Authentication failures
- Missing required fields
- Invalid input

### Message Guidelines

1. **Be Clear and Concise**
   - ✅ "Invalid email or password"
   - ❌ "There was an error processing your request"

2. **Use Action-Oriented Language**
   - ✅ "Please enter your email"
   - ❌ "Email field is empty"

3. **Provide Context**
   - ✅ "Password must be 6-12 characters"
   - ❌ "Invalid password"

4. **Use Localized Strings**
   - Always use `AppLocalizations` for messages
   - Never hardcode English text

## Migration from Old SnackBars

### Before
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error message')),
);
```

### After
```dart
showErrorToast(context, 'Error message');
```

## Accessibility

- Icons provide visual cues for different toast types
- Color-coded backgrounds reinforce the message type
- Text is readable with sufficient contrast
- Duration allows time to read the message

## Related Documentation
- [Design System](../design-system.md)
- [Typography](../design-system.md#typography)
- [Colors](../design-system.md#colors)
- [Spacing](../design-system.md#spacing)

