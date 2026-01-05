# OTP Verification Screen Implementation

Implementation details for the OTP (One-Time Password) email verification screen matching the Figma design.

## 📱 Overview

The OTP Verification screen allows users to verify their email address by entering a 6-digit code sent to their email. It features an intuitive input interface with automatic focus management and a countdown timer.

## 🎨 Design

**Figma Design**: [OTP Verification Screen](https://www.figma.com/design/33pzR0AFb7Hz3R11vuYtwW/Untitled?node-id=1-248&m=dev)

### Visual Elements

- **App Bar**: Back button to return to previous screen
- **Header**:
  - Mail icon + "Email verification" title (24px, Bold)
  - Description: "A 6-digit code has been sent to {email}. Please enter it within the next {seconds} seconds"
- **Form**:
  - "Verification Code" label
  - 6 OTP input boxes (50px height, dark surface)
  - Continue button (primary blue)
  - "I haven't receive the code" link with countdown

## 📁 File Locations

```
lib/features/auth/presentation/views/otp_verification_screen.dart
lib/core/presentation/widgets/otp_input.dart
```

## 🔧 Implementation Details

### OTP Input Widget

A reusable component for OTP/PIN code entry:

```dart
class OTPInput extends StatefulWidget {
  const OTPInput({
    required this.onCompleted,
    this.onChanged,
    this.length = 6,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
}
```

**Features**:
- ✅ Auto-focus to next box when digit entered
- ✅ Backspace moves to previous box
- ✅ Paste support (distributes digits across boxes)
- ✅ Only accepts numeric input
- ✅ Callback when all boxes filled
- ✅ Reusable for any length (default 6)

### OTP Verification Screen

```dart
class OTPVerificationScreen extends ConsumerStatefulWidget {
  const OTPVerificationScreen({
    required this.email,
  });

  final String email;
  
  static const String routePath = '/otp-verification';
  static const String routeName = 'otp-verification';
}
```

**State Management**:
- `_otpCode`: Current entered OTP code
- `_secondsRemaining`: Countdown timer (starts at 60)
- `_timer`: Timer for countdown
- `_isLoading`: Loading state during verification

### Key Features

#### 1. **Countdown Timer**
Automatically starts 60-second countdown when screen loads:
```dart
void _startTimer() {
  _timer?.cancel();
  setState(() => _secondsRemaining = 60);

  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_secondsRemaining > 0) {
      setState(() => _secondsRemaining--);
    } else {
      timer.cancel();
    }
  });
}
```

#### 2. **OTP Validation**
Validates the 6-digit code:
```dart
Future<void> _handleContinue() async {
  if (_otpCode.length != 6) {
    // Show error
    return;
  }

  // Verify OTP with API
  final isValid = await verifyOTP(_otpCode);
  
  if (isValid) {
    context.go(HomeScreen.routePath);
  } else {
    // Show error
  }
}
```

#### 3. **Resend Code**
Resends OTP code when timer expires:
```dart
void _handleResendCode() {
  // Only allowed when timer reaches 0
  if (_secondsRemaining == 0) {
    // Call API to resend code
    // Restart timer
    _startTimer();
  }
}
```

#### 4. **Navigation**
- **From Register** → OTP Verification (with email parameter)
- **On Success** → Home Screen
- **Back button** → Returns to Register Screen

## 🌍 Localization

All text is fully localized (English & Spanish):

| Key | English | Spanish |
|-----|---------|---------|
| `emailVerification` | Email verification | Verificación de correo |
| `otpSentMessage` | A 6-digit code has been sent to {email}. Please enter it within the next {seconds} seconds | Se ha enviado un código de 6 dígitos a {email}. Por favor ingrésalo en los próximos {seconds} segundos |
| `verificationCode` | Verification Code | Código de verificación |
| `continueButton` | Continue | Continuar |
| `iHaventReceiveCode` | I haven't receive the code | No he recibido el código |
| `resendCode` | Resend code | Reenviar código |
| `invalidOtpCode` | Invalid verification code | Código de verificación inválido |
| `otpCodeRequired` | Please enter the 6-digit code | Por favor ingresa el código de 6 dígitos |

## 🎯 Usage Example

### Navigation to OTP Screen

```dart
// From Register screen (after registration)
final email = 'user@example.com';
context.go(
  '${OTPVerificationScreen.routePath}?email=${Uri.encodeComponent(email)}',
);

// Direct navigation
context.go('/otp-verification?email=user@example.com');
```

### Router Configuration

```dart
GoRoute(
  path: OTPVerificationScreen.routePath,  // '/otp-verification'
  name: OTPVerificationScreen.routeName,  // 'otp-verification'
  builder: (context, state) {
    final email = state.uri.queryParameters['email'] ?? '';
    return OTPVerificationScreen(email: email);
  },
)
```

## 🧩 Components Used

### Shared Components

- **`OTPInput`** - 6-box OTP input widget (NEW)
- **`AppButton`** - Continue button with loading state

### Flutter Widgets

- **`Timer`** - Countdown timer
- **`Icons.mail_outline`** - Mail icon from Material Icons
- **`Icons.arrow_back`** - Back button icon

## 🎨 Design System

### Colors
```dart
AppColors.background      // #121212 - Screen background
AppColors.surface        // #2C2C2C - OTP box background
AppColors.primary        // #2979FF - Continue button
AppColors.textPrimary    // #FFFFFF - Main text
AppColors.textSecondary  // #DBDBDB - Description text
AppColors.textLabel      // #AEAEAE - Disabled resend link
AppColors.textTertiary   // #E7E7E7 - Active resend link
```

### Typography
```dart
AppTextStyles.labelLarge().copyWith(fontSize: 24)  // Title
AppTextStyles.bodyLarge()                          // Description
AppTextStyles.labelMedium()                        // Label, OTP digits
AppTextStyles.link()                               // Resend link
```

### Spacing & Sizing
```dart
AppSpacing.screenPadding  // 24px - Screen edges
AppSpacing.xl             // 40px - Header to form
AppSpacing.fieldGap       // 16px - Between elements
AppSpacing.fieldLabelGap  // 8px - Label to input
50px                      // OTP box height
12px                      // Border radius
```

## 🔄 User Flow

```
1. User completes registration on Register screen
2. System sends OTP code to user's email
3. User navigates to OTP Verification screen
4. User sees:
   - Email address where code was sent
   - 60-second countdown timer
   - 6 empty OTP input boxes
5. User enters 6-digit code:
   - Auto-focus moves between boxes
   - Can paste entire code
   - Continue button activates when all 6 digits entered
6. User taps "Continue":
   → If valid: Navigate to Home screen
   → If invalid: Show error, allow retry
7. If timer expires (0 seconds):
   → "I haven't receive the code" link becomes active
   → User can request new code
   → Timer restarts to 60 seconds
8. User can tap back button to return to Register screen
```

## ✅ Features

- ✅ Matches Figma design pixel-perfect
- ✅ Fully localized (English & Spanish)
- ✅ 6-box OTP input with auto-focus
- ✅ 60-second countdown timer
- ✅ Resend code functionality
- ✅ Paste support for OTP codes
- ✅ Loading state during verification
- ✅ Error handling and validation
- ✅ Back navigation
- ✅ Dynamic email display
- ✅ Responsive layout
- ✅ Dark theme

## 🚧 TODO

- [ ] Implement actual OTP verification API call
- [ ] Implement resend OTP API call
- [ ] Add OTP expiration handling
- [ ] Add rate limiting for resend
- [ ] Add animation when OTP is wrong
- [ ] Add haptic feedback
- [ ] Store email securely during flow
- [ ] Add analytics tracking
- [ ] Add unit tests
- [ ] Add widget tests
- [ ] Test with different email lengths

## 📝 Notes

### Design Decisions

1. **Auto-Focus**: Automatically moves focus to the next box when a digit is entered for better UX.

2. **Countdown Timer**: Displays remaining time in the description text and enables/disables the resend link accordingly.

3. **Paste Support**: Users can paste the entire OTP code, and it will be distributed across all 6 boxes automatically.

4. **Material Icons**: Used Flutter's built-in `Icons.mail_outline` instead of a custom SVG for simplicity.

5. **Query Parameters**: Email is passed via URL query parameter to maintain clean separation and allow deep linking.

### Security Considerations

- OTP codes should be 6 digits
- Codes should expire after a set time (e.g., 5-10 minutes)
- Limit resend attempts to prevent spam
- Rate limit verification attempts to prevent brute force
- Clear OTP code from memory after verification
- Use HTTPS for all API calls

### Accessibility

- All interactive elements are properly sized
- Timer countdown is visible in text
- Clear error messages
- Screen reader friendly
- High contrast text

### Testing Tips

**Mock OTP**: For testing, use `123456` as valid OTP code (hardcoded in current implementation).

**Test Scenarios**:
1. Enter correct OTP → Should navigate to Home
2. Enter incorrect OTP → Should show error
3. Wait for timer to expire → Resend link becomes active
4. Tap resend → Timer restarts
5. Paste OTP code → Should distribute across boxes
6. Backspace navigation → Should move to previous box
7. Back button → Should return to Register screen

## 🔗 Related Files

- [Register Screen](./register.md)
- [Login Screen](./sign-in.md)
- [Reusable Components](../components.md)
- [Design System](../design-system.md)
- [Localization Guide](../localization.md)

---

**Last Updated**: January 2026

