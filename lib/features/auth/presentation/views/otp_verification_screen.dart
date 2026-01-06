import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/presentation/widgets/otp_input.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/core/utils/toast_utils.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/create_password_screen.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/login_screen.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Type of verification being performed
enum VerificationType { email, phone }

/// OTP Verification screen matching the Figma design
///
/// This screen displays an OTP input for email/phone verification with:
/// - Back button in app bar
/// - Email/Phone icon + title
/// - Description with contact info and countdown
/// - 6-digit OTP input boxes
/// - Continue button
/// - "I haven't receive the code" link with countdown
class OTPVerificationScreen extends ConsumerStatefulWidget {
  const OTPVerificationScreen({
    required this.contact,
    super.key,
    this.verificationType = VerificationType.email,
  });

  final String contact; // Email or phone number
  final VerificationType verificationType;

  static const String routePath = '/otp-verification';
  static const String routeName = 'otp-verification';

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  String _otpCode = '';
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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

  void _handleOTPCompleted(String code) {
    setState(() => _otpCode = code);
  }

  void _handleOTPChanged(String code) {
    setState(() => _otpCode = code);
  }

  Future<void> _handleContinue() async {
    final strings = AppLocalizations.of(context);

    if (_otpCode.length != 6) {
      showErrorToast(context, strings.otpCodeRequired);
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement actual OTP verification API call
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Simulate success/failure
    final isValid = _otpCode == '123456'; // Mock validation

    if (isValid) {
      // Navigate to Create Password screen on success
      context.go(CreatePasswordScreen.routePath);
    } else {
      setState(() => _isLoading = false);
      showErrorToast(context, strings.invalidOtpCode);
    }
  }

  void _handleResendCode() {
    final strings = AppLocalizations.of(context);

    // TODO: Implement actual resend code API call
    showSuccessToast(context, strings.resendCode);

    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              TablerIcons.arrow_narrow_left,
              color: AppColors.textPrimary,
              size: 24,
            ),
            onPressed: () {
              // Check if we can pop, otherwise navigate to login
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(LoginScreen.routePath);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + Title
                    Row(
                      children: [
                        Icon(
                          widget.verificationType == VerificationType.email
                              ? TablerIcons.mail_filled
                              : TablerIcons.phone,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.verificationType == VerificationType.email
                              ? strings.emailVerification
                              : strings.phoneVerification,
                          style: AppTextStyles.labelLarge().copyWith(
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      widget.verificationType == VerificationType.email
                          ? strings.otpSentToEmail(
                              widget.contact,
                              _secondsRemaining,
                            )
                          : strings.otpSentToPhone(
                              widget.contact,
                              _secondsRemaining,
                            ),
                      style:
                          AppTextStyles.bodyLarge(
                            color: AppColors.textSecondary,
                          ).copyWith(
                            height:
                                1.4, // Better line height for multi-line text
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                // Form section
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Verification Code label
                        Text(
                          strings.verificationCode,
                          style: AppTextStyles.textFieldLabel(),
                        ),
                        const SizedBox(height: AppSpacing.fieldLabelGap),
                        // OTP Input
                        OTPInput(
                          onCompleted: _handleOTPCompleted,
                          onChanged: _handleOTPChanged,
                        ),
                        const SizedBox(height: AppSpacing.fieldGap),
                        // Continue button
                        AppButton(
                          label: strings.continueButton,
                          onPressed: _handleContinue,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: AppSpacing.fieldGap),
                        // Resend code link
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _secondsRemaining == 0
                                ? _handleResendCode
                                : null,
                            child: Text(
                              strings.iHaventReceiveCode,
                              style: AppTextStyles.link().copyWith(
                                color: _secondsRemaining == 0
                                    ? AppColors.textTertiary
                                    : AppColors.textLabel,
                                decoration: _secondsRemaining == 0
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
