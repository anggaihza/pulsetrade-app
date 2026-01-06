# Register Screen Implementation

Implementation details for the Register (Sign Up) screen matching the Figma design.

## 📱 Overview

The Register screen allows new users to create a Pulse Trading account. It features a single-step registration process with email/phone number input and terms acceptance.

## 🎨 Design

**Figma Design**: [Register Screen](https://www.figma.com/design/33pzR0AFb7Hz3R11vuYtwW/Untitled?node-id=1-207&m=dev)

### Visual Elements

- **Header**:
  - Title: "Welcome!" (40px, Bold)
  - Subtitle: "Join now and embark on your journey to success. Let's get started!" (14px, Regular)

- **Form**:
  - Email/Phone number input field
  - Terms of Service checkbox with clickable links
  - Continue button (primary blue)
  - "or" divider
  - Google Sign-In button (outlined)
  - "I have Pulse account" link

## 📁 File Location

```
lib/features/auth/presentation/views/register_screen.dart
```

## 🔧 Implementation Details

### State Management

```dart
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _acceptedTerms = false;  // Terms checkbox state
  ProviderSubscription<AsyncValue<AuthState>>? _authSubscription;
  
  // ...
}
```

### Key Features

#### 1. **Email/Phone Input**
Uses the shared `AppTextField` component:
```dart
AppTextField(
  label: strings.emailPhoneLabel,
  placeholder: strings.emailPhonePlaceholder,
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
)
```

#### 2. **Terms of Service Checkbox**
Custom checkbox with clickable Terms and Privacy Policy links:
```dart
Widget _buildTermsCheckbox(AppLocalizations strings) {
  return Row(
    children: [
      // Custom checkbox
      GestureDetector(
        onTap: () {
          setState(() => _acceptedTerms = !_acceptedTerms);
        },
        child: Container(
          // Checkbox styling
          child: _acceptedTerms ? Icon(Icons.check) : null,
        ),
      ),
      // Terms text with clickable links
      RichText(
        text: TextSpan(
          children: [
            TextSpan(text: strings.termsAgreement),
            TextSpan(
              text: strings.termsOfService,
              recognizer: TapGestureRecognizer()..onTap = () { /* Navigate */ },
            ),
            // ...
          ],
        ),
      ),
    ],
  );
}
```

#### 3. **Automatic Contact Type Detection**
The system automatically detects whether the user entered an email or phone number:
```dart
VerificationType _detectContactType(String contact) {
  // Check if it's an email (contains @ symbol and has valid email pattern)
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  if (emailRegex.hasMatch(contact)) {
    return VerificationType.email;
  }
  
  // Otherwise treat it as a phone number
  return VerificationType.phone;
}
```

#### 4. **Validation**
Validates email/phone and terms acceptance before proceeding:
```dart
void _handleRegister() {
  if (contact.isEmpty) {
    showErrorToast(context, strings.pleaseEnterEmail);
    return;
  }
  if (!_acceptedTerms) {
    showErrorToast(context, strings.pleaseAcceptTerms);
    return;
  }
  
  // Auto-detect if input is email or phone
  final verificationType = _detectContactType(contact);
  
  // Navigate to OTP screen with detected type
  context.go(
    Uri(
      path: OTPVerificationScreen.routePath,
      queryParameters: {
        'contact': contact,
        'type': verificationType == VerificationType.email ? 'email' : 'phone',
      },
    ).toString(),
  );
}
```

#### 5. **Navigation**
- "I have Pulse account" → Navigates to Login screen
- After validation → Automatically detects input type and navigates to OTP Verification screen
- After successful registration flow → Navigates to Home screen

## 🌍 Localization

All text is fully localized (English & Spanish):

| Key | English | Spanish |
|-----|---------|---------|
| `welcome` | Welcome! | ¡Bienvenido! |
| `registerSubtitle` | Join now and embark on your journey to success. Let's get started! | Únete ahora y comienza tu viaje hacia el éxito. ¡Empecemos! |
| `emailPhoneLabel` | Email/Phone number | Correo/Número de teléfono |
| `emailPhonePlaceholder` | Type your email/phone number | Escribe tu correo/número de teléfono |
| `continueButton` | Continue | Continuar |
| `termsAgreement` | By Creating an account, I agree to Pulse Trading's | Al crear una cuenta, acepto los |
| `termsOfService` | Terms of Service | Términos de Servicio |
| `and` | and | y |
| `privacyPolicy` | Privacy Policy | Política de Privacidad |
| `iHavePulseAccount` | I have Pulse account | Ya tengo cuenta Pulse |
| `pleaseEnterEmail` | Please enter email/phone number | Por favor ingresa correo/número de teléfono |
| `pleaseAcceptTerms` | Please accept the Terms of Service and Privacy Policy | Por favor acepta los Términos de Servicio y la Política de Privacidad |

## 🎯 Usage Example

### Navigation to Register Screen

```dart
// From Login screen
TextButton(
  onPressed: () => context.go(RegisterScreen.routePath),
  child: Text(strings.createPulseAccount),
)

// Direct navigation
context.go('/register');
```

### Router Configuration

```dart
GoRoute(
  path: RegisterScreen.routePath,  // '/register'
  name: RegisterScreen.routeName,  // 'register'
  builder: (context, state) => const RegisterScreen(),
)
```

## 🧩 Components Used

### Shared Components

- **`AppTextField`** - Email/phone input field
- **`AppButton`** - Continue button with loading state
- **`GoogleButton`** - Google Sign-In option
- **`OrDivider`** - Divider with "or" text

### Custom Components

- **Terms Checkbox** - Inline checkbox with clickable links (defined in `_buildTermsCheckbox`)

## 🎨 Design System

### Colors
```dart
AppColors.background      // #121212 - Screen background
AppColors.surface        // #2C2C2C - Input field background
AppColors.primary        // #2979FF - Continue button, checked checkbox
AppColors.textPrimary    // #FFFFFF - Main text
AppColors.textSecondary  // #DBDBDB - Subtitle text
AppColors.textTertiary   // #E7E7E7 - Checkbox border
```

### Typography
```dart
AppTextStyles.displaySmall()       // 40px, Bold - "Welcome!"
AppTextStyles.bodyLarge()          // 14px, Regular - Subtitle
AppTextStyles.bodyMedium()         // 12px, Regular - Terms text
AppTextStyles.labelMedium()        // 12px, SemiBold - Field labels
AppTextStyles.link()               // 14px, Bold, Underlined - Account link
```

### Spacing
```dart
AppSpacing.screenPadding  // 24px - Screen edges
AppSpacing.xl             // 40px - Header to form
AppSpacing.fieldGap       // 16px - Between form elements
```

## 🔄 User Flow

```
1. User lands on Register screen
2. User enters email or phone number (e.g., "user@example.com" or "+1234567890")
3. User checks Terms of Service checkbox
4. User taps "Continue" button
   → Validation:
     - Contact field must not be empty
     - Terms checkbox must be checked
   → If valid:
     ✓ System automatically detects if input is email or phone
     ✓ Navigate to OTP Verification screen with detected type
   → If invalid: Show error toast message
5. Alternative: User taps "Continue with Google"
   → Google Sign-In flow (to be implemented)
6. Alternative: User taps "I have Pulse account"
   → Navigate to Login screen
```

## ✅ Features

- ✅ Matches Figma design pixel-perfect
- ✅ Fully localized (English & Spanish)
- ✅ Uses shared design system
- ✅ Reusable components
- ✅ Form validation with error toasts
- ✅ Automatic email/phone detection
- ✅ Smart OTP routing (email or phone)
- ✅ Loading states
- ✅ Clickable Terms/Privacy links
- ✅ Custom checkbox with check icon
- ✅ Responsive layout
- ✅ Dark theme

## 🚧 TODO

- [ ] Implement actual registration API call
- [ ] Add password field (if required)
- [ ] Implement email validation (regex)
- [ ] Add Terms of Service screen
- [ ] Add Privacy Policy screen
- [ ] Implement Google Sign-In
- [ ] Add email verification flow
- [ ] Add more registration fields (name, etc.)
- [ ] Add form field error states
- [ ] Add unit tests
- [ ] Add widget tests

## 📝 Notes

### Design Decisions

1. **Single Field Registration**: Following Figma, the screen only asks for email/phone initially. Additional information can be collected in a follow-up screen.

2. **Automatic Type Detection**: The system intelligently detects whether the user entered an email (contains `@`) or phone number, eliminating the need for manual selection. This provides a seamless UX without extra steps.

3. **Smart OTP Routing**: Based on the detected input type, users are automatically routed to the appropriate OTP verification method (email or SMS), streamlining the registration flow.

4. **Custom Checkbox**: Used a custom checkbox instead of Flutter's default to match the exact Figma design (15x15px with 4px border radius).

5. **Clickable Links**: Terms of Service and Privacy Policy are tappable within the checkbox text using `TapGestureRecognizer`.

6. **No Password Field**: The Figma design doesn't include a password field on the initial registration screen. This follows a modern pattern where the password is set in a follow-up step after OTP verification.

### Accessibility

- Checkbox has a tap target larger than the visible 15x15px for better usability
- All interactive elements are properly sized
- Text contrast meets WCAG standards
- Screen reader friendly

## 🔗 Related Files

- [Login Screen](./sign-in.md)
- [Reusable Components](../components.md)
- [Design System](../design-system.md)
- [Localization Guide](../localization.md)

---

**Last Updated**: January 2026

