/// Common validation utilities for form inputs
class Validators {
  Validators._(); // Private constructor to prevent instantiation

  /// Validates if the input is a valid email format
  /// 
  /// Uses RFC 5322 compliant email regex (simplified version)
  /// 
  /// Example:
  /// ```dart
  /// Validators.isValidEmail('user@example.com'); // true
  /// Validators.isValidEmail('invalid.email'); // false
  /// ```
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates if the input is a valid phone number format
  /// 
  /// Accepts phone numbers with optional country code, spaces, dashes, and parentheses
  /// Must contain 7-15 digits after cleaning
  /// 
  /// Example:
  /// ```dart
  /// Validators.isValidPhone('+1 (234) 567-8900'); // true
  /// Validators.isValidPhone('1234567890'); // true
  /// Validators.isValidPhone('123'); // false (too short)
  /// ```
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    
    // Remove common phone number characters for validation
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    
    // Check if it contains only digits and has reasonable length (7-15 digits)
    return RegExp(r'^\d{7,15}$').hasMatch(cleanPhone);
  }

  /// Validates if the input is a valid password
  /// 
  /// Requirements:
  /// - At least 6 characters
  /// - At most 12 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  /// - At least one special character (!@#$%^&*(),.?":{}|<>)
  /// 
  /// Example:
  /// ```dart
  /// Validators.isValidPassword('Pass123!'); // true
  /// Validators.isValidPassword('weak'); // false
  /// ```
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    if (password.length < 6 || password.length > 12) return false;
    
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }

  /// Checks if password meets minimum length requirement (6 characters)
  static bool hasMinLength(String password) {
    return password.length >= 6;
  }

  /// Checks if password meets maximum length requirement (12 characters)
  static bool hasMaxLength(String password) {
    return password.length <= 12;
  }

  /// Checks if password contains at least one uppercase letter
  static bool hasUppercase(String password) {
    return RegExp(r'[A-Z]').hasMatch(password);
  }

  /// Checks if password contains at least one lowercase letter
  static bool hasLowercase(String password) {
    return RegExp(r'[a-z]').hasMatch(password);
  }

  /// Checks if password contains at least one digit
  static bool hasDigit(String password) {
    return RegExp(r'\d').hasMatch(password);
  }

  /// Checks if password contains at least one special character
  static bool hasSpecialChar(String password) {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  /// Validates if the input is a valid OTP code (6 digits)
  static bool isValidOTP(String otp) {
    return RegExp(r'^\d{6}$').hasMatch(otp);
  }

  /// Validates if the input is a valid PIN code (6 digits)
  static bool isValidPIN(String pin) {
    return RegExp(r'^\d{6}$').hasMatch(pin);
  }

  /// Checks if a string is not empty after trimming whitespace
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }
}

