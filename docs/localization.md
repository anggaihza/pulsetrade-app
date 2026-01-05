# Localization Guide

PulseTrade uses Flutter's built-in localization system with ARB (Application Resource Bundle) files for managing translations.

## 📁 Location

```
lib/l10n/
├── arb/                        # Translation files
│   ├── app_en.arb             # English translations
│   └── app_es.arb             # Spanish translations
└── gen/                        # Generated files (auto-generated)
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    └── app_localizations_es.dart
```

## 🌍 Supported Languages

| Language | Code | File |
|----------|------|------|
| English | `en` | `app_en.arb` |
| Spanish | `es` | `app_es.arb` |

## 📝 Adding New Translations

### 1. Add to English ARB file

**File**: `lib/l10n/arb/app_en.arb`

```json
{
  "@@locale": "en",
  "myNewKey": "My new text in English",
  "greetingWithName": "Hello, {name}!",
  "@greetingWithName": {
    "description": "Greeting message with user's name",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  }
}
```

### 2. Add to Spanish ARB file

**File**: `lib/l10n/arb/app_es.arb`

```json
{
  "@@locale": "es",
  "myNewKey": "Mi nuevo texto en español",
  "greetingWithName": "¡Hola, {name}!"
}
```

### 3. Generate Localization Files

Run the code generation command:

```bash
flutter gen-l10n
```

This will regenerate the files in `lib/l10n/gen/`.

## 🎯 Using Localized Strings

### In Widgets

```dart
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get localized strings
    final strings = AppLocalizations.of(context);
    
    return Column(
      children: [
        // Simple text
        Text(strings.login),
        
        // Text with parameters
        Text(strings.greetingWithName('John')),
        
        // In buttons
        AppButton(
          label: strings.submit,
          onPressed: () => _handleSubmit(),
        ),
        
        // In text fields
        AppTextField(
          label: strings.email,
          placeholder: strings.emailPlaceholder,
        ),
      ],
    );
  }
}
```

### In Methods

```dart
void _showError(BuildContext context) {
  final strings = AppLocalizations.of(context);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(strings.errorMessage)),
  );
}
```

### Accessing Without Context

If you need strings outside of a widget (e.g., in a provider or service), pass them as parameters:

```dart
// ❌ Don't do this (no context available)
class MyService {
  void doSomething() {
    // Can't access AppLocalizations here
  }
}

// ✅ Do this instead
class MyService {
  void doSomething(String errorMessage) {
    // Use passed string
    print(errorMessage);
  }
}

// In widget
final strings = AppLocalizations.of(context);
myService.doSomething(strings.errorMessage);
```

## 📚 Available Translations

### Sign-In Screen

| Key | English | Spanish |
|-----|---------|---------|
| `signIn` | Sign in | Iniciar sesión |
| `signInSubtitle` | Ready to start where you left off? | ¿Listo para continuar donde lo dejaste? |
| `emailPhoneLabel` | Email/Phone number | Correo/Número de teléfono |
| `emailPhonePlaceholder` | Type your email/phone number | Escribe tu correo/número de teléfono |
| `passwordLabel` | Password | Contraseña |
| `passwordPlaceholder` | Type your password | Escribe tu contraseña |
| `login` | Login | Ingresar |
| `or` | or | o |
| `continueWithGoogle` | Continue with Google | Continuar con Google |
| `createPulseAccount` | Create a Pulse account | Crear una cuenta Pulse |

### Common

| Key | English | Spanish |
|-----|---------|---------|
| `appTitle` | PulseTrade | PulseTrade |
| `email` | Email | Correo |
| `password` | Password | Contraseña |
| `submit` | Submit | Enviar |
| `logout` | Logout | Cerrar sesión |

### Error Messages

| Key | English | Spanish |
|-----|---------|---------|
| `pleaseEnterEmailPassword` | Please enter email and password | Por favor ingresa correo y contraseña |
| `googleSignInNotImplemented` | Google Sign-In not yet implemented | Inicio de sesión con Google aún no implementado |

## 🔧 Configuration

**File**: `l10n.yaml` (project root)

```yaml
arb-dir: lib/l10n/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/l10n/gen
```

## ✅ Best Practices

### DO:

```dart
// ✅ Use localized strings
final strings = AppLocalizations.of(context);
Text(strings.login)

// ✅ Use descriptive keys
"emailPhoneLabel": "Email/Phone number"

// ✅ Add descriptions for complex strings
"@greetingWithName": {
  "description": "Greeting message with user's name"
}

// ✅ Keep keys consistent across languages
// app_en.arb: "login": "Login"
// app_es.arb: "login": "Ingresar"
```

### DON'T:

```dart
// ❌ Don't hardcode text
Text('Login')  // Use strings.login

// ❌ Don't use generic keys
"text1": "Login"  // Use "login" instead

// ❌ Don't forget to translate
// app_en.arb: "newFeature": "New Feature"
// app_es.arb: (missing) ❌

// ❌ Don't use different keys for same concept
// app_en.arb: "loginButton": "Login"
// app_es.arb: "signInButton": "Ingresar"  // Should be "loginButton"
```

## 🌐 Adding a New Language

### 1. Create ARB file

Create `lib/l10n/arb/app_fr.arb` (for French):

```json
{
  "@@locale": "fr",
  "appTitle": "PulseTrade",
  "login": "Connexion",
  "email": "E-mail",
  "password": "Mot de passe"
}
```

### 2. Update supported locales

**File**: `lib/app.dart`

```dart
MaterialApp(
  supportedLocales: const [
    Locale('en'),
    Locale('es'),
    Locale('fr'), // Add new locale
  ],
  // ...
)
```

### 3. Generate localization files

```bash
flutter gen-l10n
```

### 4. Test the new language

The app will automatically use the device's language if supported, or fall back to English.

## 🔄 Workflow

### When adding new UI text:

1. **Add to ARB files** (both `app_en.arb` and `app_es.arb`)
2. **Run code generation**: `flutter gen-l10n`
3. **Use in code**: `strings.myNewKey`
4. **Test both languages** in the app

### When updating existing text:

1. **Update ARB files** (all language files)
2. **Run code generation**: `flutter gen-l10n`
3. **No code changes needed** (automatically updated everywhere)

## 📱 Testing Localization

### Change language in app

```dart
// In settings screen
ElevatedButton(
  onPressed: () {
    // Change to Spanish
    ref.read(settingsProvider.notifier).updateLocale(const Locale('es'));
  },
  child: Text('Español'),
)
```

### Test on device

1. Change device language in Settings
2. Restart the app
3. Verify all text is translated

### Test in simulator/emulator

```bash
# iOS Simulator - change language
# Android Emulator - Settings > System > Languages

# Or use Flutter DevTools
flutter run
# Then change locale in DevTools
```

## 🐛 Troubleshooting

### Strings not updating

```bash
# Clean and regenerate
flutter clean
flutter pub get
flutter gen-l10n
```

### Missing translations

Check `l10n_untranslated.txt` in project root for missing keys.

### Build errors after adding strings

1. Make sure key exists in **all** ARB files
2. Run `flutter gen-l10n`
3. Restart IDE/editor
4. Run `flutter clean` if needed

## 📖 Resources

- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB Format Specification](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Intl Package](https://pub.dev/packages/intl)

---

**Remember**: Always localize user-facing text. Never hardcode strings in widgets!

