# OTP Verification Feature

## Overview
The OTP Verification screen supports both **email** and **phone** verification based on the [Figma design](https://www.figma.com/design/33pzR0AFb7Hz3R11vuYtwW/Untitled?node-id=1-447&m=dev).

## Features
- ✅ **Dual verification types**: Email and Phone
- ✅ **6-digit OTP input** with auto-advance
- ✅ **Paste support**: Paste any format (123456, 12-34-56, etc.)
- ✅ **Countdown timer**: 60-second countdown with resend functionality
- ✅ **Tabler Icons**: Uses `mail_filled` for email, `phone_filled` for phone
- ✅ **Backspace navigation**: Smooth movement between fields
- ✅ **Full localization**: English and Spanish support
- ✅ **Clean UX**: No jumping, no keyboard errors

## Usage

### Navigate to Email Verification
```dart
context.go(
  Uri(
    path: OTPVerificationScreen.routePath,
    queryParameters: {
      'contact': 'user@example.com',
      'type': 'email',
    },
  ).toString(),
);
```

### Navigate to Phone Verification
```dart
context.go(
  Uri(
    path: OTPVerificationScreen.routePath,
    queryParameters: {
      'contact': '+1234567890',
      'type': 'phone',
    },
  ).toString(),
);
```

### Auto-detect Type from Register Screen
```dart
final email = _emailController.text.trim();
final isPhone = RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(email);

context.go(
  Uri(
    path: OTPVerificationScreen.routePath,
    queryParameters: {
      'contact': email,
      'type': isPhone ? 'phone' : 'email',
    },
  ).toString(),
);
```

## VerificationType Enum
```dart
enum VerificationType {
  email,  // Shows mail icon and "Email verification"
  phone,  // Shows phone icon and "Phone verification"
}
```

## Screen Components

### 1. Header
- **Icon**: `TablerIcons.mail_filled` or `TablerIcons.phone_filled`
- **Title**: "Email verification" or "Phone verification"
- **Description**: "A 6-digit code has been sent to {contact}..."

### 2. OTP Input
- **6 boxes**: Dark surface (#2C2C2C), 50px height, 12px radius
- **Auto-advance**: Type digit → Jump to next box
- **Backspace**: Clear current → Press again → Move to previous
- **Paste**: Paste 123456 → Fills all boxes
- **No white background**: Transparent TextField

### 3. Actions
- **Continue button**: Primary button (45px height)
- **Resend link**: Enabled after 60-second countdown

## Localization Keys

### English (app_en.arb)
```json
{
  "emailVerification": "Email verification",
  "phoneVerification": "Phone verification",
  "otpSentToEmail": "A 6-digit code has been sent to {email}. Please enter it within the next {seconds} seconds",
  "otpSentToPhone": "A 6-digit code has been sent to {phone}. Please enter it within the next {seconds} seconds",
  "verificationCode": "Verification Code",
  "iHaventReceiveCode": "I haven't receive the code",
  "continueButton": "Continue",
  "resendCode": "Resend code",
  "invalidOtpCode": "Invalid verification code",
  "otpCodeRequired": "Please enter the 6-digit code"
}
```

### Spanish (app_es.arb)
```json
{
  "emailVerification": "Verificación de correo",
  "phoneVerification": "Verificación de teléfono",
  "otpSentToEmail": "Se ha enviado un código de 6 dígitos a {email}. Por favor ingrésalo en los próximos {seconds} segundos",
  "otpSentToPhone": "Se ha enviado un código de 6 dígitos a {phone}. Por favor ingrésalo en los próximos {seconds} segundos"
}
```

## OTP Input Widget

### Location
`lib/core/presentation/widgets/otp_input.dart`

### Features
```dart
OTPInput(
  length: 6,                          // Number of digits
  onCompleted: (code) {               // Called when all 6 filled
    print('OTP: $code');
  },
  onChanged: (code) {                 // Called on every change
    print('Current: $code');
  },
)
```

### Behavior Table
| Action | Behavior |
|--------|----------|
| Type "1" in empty Box 1 | Fill → Jump to Box 2 |
| Type "2" in filled Box 2 | Replace "2" → Stay in Box 2 |
| Backspace in filled Box 3 | Clear "3" → Stay in Box 3 |
| Backspace in empty Box 3 | Jump to Box 2 |
| Paste "123456" | Fill all 6 boxes |
| Paste "12-34-56" | Strip dashes → Fill all 6 boxes |
| Paste "123" | Fill first 3 → Focus Box 4 |

## State Management

### Timer State
```dart
int _secondsRemaining = 60;  // Countdown from 60
Timer? _timer;               // Timer instance

void _startTimer() {
  _secondsRemaining = 60;
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_secondsRemaining > 0) {
      setState(() => _secondsRemaining--);
    } else {
      timer.cancel();
    }
  });
}
```

### OTP State
```dart
String _otpCode = '';        // Current OTP value
bool _isLoading = false;     // Loading state for verification

void _handleOTPChanged(String code) {
  setState(() => _otpCode = code);
}

void _handleOTPCompleted(String code) {
  print('OTP Complete: $code');
  // Auto-verify when all 6 digits entered
}
```

## Router Configuration

### Route Path
```dart
static const String routePath = '/otp-verification';
static const String routeName = 'otp-verification';
```

### Route Builder
```dart
GoRoute(
  path: OTPVerificationScreen.routePath,
  name: OTPVerificationScreen.routeName,
  builder: (context, state) {
    final contact = state.uri.queryParameters['contact'] ?? '';
    final type = state.uri.queryParameters['type'] ?? 'email';
    final verificationType = type == 'phone'
        ? VerificationType.phone
        : VerificationType.email;
    return OTPVerificationScreen(
      contact: contact,
      verificationType: verificationType,
    );
  },
),
```

## Design Tokens

### Colors
```dart
AppColors.background        // #121212 (screen background)
AppColors.surface          // #2C2C2C (OTP box background)
AppColors.textPrimary      // #FFFFFF (main text)
AppColors.textSecondary    // #DBDBDB (description text)
AppColors.primary          // #2979FF (cursor color)
```

### Spacing
```dart
AppSpacing.screenPadding   // 24px (screen edges)
AppSpacing.xl              // 40px (header to form gap)
AppSpacing.fieldGap        // 16px (between form elements)
AppSpacing.fieldLabelGap   // 8px (label to input gap)
```

### Typography
```dart
AppTextStyles.labelLarge()          // 14px Bold (title - increased to 24px)
AppTextStyles.bodyLarge()           // 14px Regular (description, height 1.4)
AppTextStyles.textFieldLabel()      // 12px SemiBold (label)
AppTextStyles.labelMedium()         // 12px SemiBold (OTP input, 16px)
```

## Integration Examples

### From Register Screen
```dart
// After successful registration API call
if (registrationSuccess) {
  final contact = _emailController.text.trim();
  final isPhone = RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(contact);
  
  context.go(
    Uri(
      path: OTPVerificationScreen.routePath,
      queryParameters: {
        'contact': contact,
        'type': isPhone ? 'phone' : 'email',
      },
    ).toString(),
  );
}
```

### From Login Screen (if needed)
```dart
// Navigate to verification if user needs to verify
GestureDetector(
  onTap: () {
    context.go(
      Uri(
        path: OTPVerificationScreen.routePath,
        queryParameters: {
          'contact': 'user@example.com',
          'type': 'email',
        },
      ).toString(),
    );
  },
  child: Text('Verify your email'),
)
```

## Testing Checklist

- [ ] Email verification shows mail icon
- [ ] Phone verification shows phone icon
- [ ] Description shows correct contact (email/phone)
- [ ] OTP boxes are 50px height with dark background
- [ ] Type digit → Auto-advances to next box
- [ ] Backspace on filled → Clears digit, stays in box
- [ ] Backspace on empty → Moves to previous box
- [ ] Paste "123456" → Fills all boxes
- [ ] Paste "12-34-56" → Strips formatting, fills all boxes
- [ ] Countdown timer starts at 60 seconds
- [ ] Resend link disabled during countdown
- [ ] Resend link enabled when countdown reaches 0
- [ ] Continue button triggers verification
- [ ] No white background in OTP input
- [ ] No KeyUpEvent errors in console
- [ ] Localization works in Spanish

## Known Issues & Solutions

### ✅ Fixed: KeyUpEvent Error
**Problem**: `KeyboardListener` with extra `FocusNode` caused keyboard events
**Solution**: Use `Focus` widget with `onKey` callback instead

### ✅ Fixed: Paste Not Working
**Problem**: `maxLength: 1` on TextField blocked paste
**Solution**: Removed `maxLength`, detect paste in `onChanged` when `value.length > 1`

### ✅ Fixed: White Background in OTP Boxes
**Problem**: TextField default fill color
**Solution**: Set `filled: false`, `fillColor: Colors.transparent`, remove all borders

### ✅ Fixed: Auto-Advance Not Working
**Problem**: `Future.delayed` prevented focus change
**Solution**: Direct `requestFocus()` call without delay

### ✅ Fixed: Stuck in One Field (Backspace)
**Problem**: No way to move back on empty field
**Solution**: `Focus` widget with `RawKeyDownEvent` detection for backspace

## Next Steps
- [ ] Implement actual OTP verification API call
- [ ] Add error handling for invalid OTP
- [ ] Add retry limit (e.g., max 3 attempts)
- [ ] Add expiry time for OTP (e.g., 10 minutes)
- [ ] Implement resend OTP API call
- [ ] Add analytics tracking for verification events
- [ ] Add unit tests for OTP input widget
- [ ] Add widget tests for verification screen
