import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_toast.dart';

void showSuccessToast(BuildContext context, String message) {
  AppToast.showSuccess(context, message);
}

void showErrorToast(BuildContext context, String message) {
  AppToast.showError(context, message);
}

void showWarningToast(BuildContext context, String message) {
  AppToast.showWarning(context, message);
}
