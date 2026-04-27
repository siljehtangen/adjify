import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showErrorToast(String message) {
  toastification.show(
    type: ToastificationType.error,
    style: ToastificationStyle.flatColored,
    title: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    autoCloseDuration: const Duration(seconds: 4),
    alignment: Alignment.bottomCenter,
    showProgressBar: false,
    closeOnClick: true,
    borderRadius: BorderRadius.circular(12),
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
  );
}

void showSuccessToast(String message) {
  toastification.show(
    type: ToastificationType.success,
    style: ToastificationStyle.flatColored,
    title: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    autoCloseDuration: const Duration(seconds: 3),
    alignment: Alignment.bottomCenter,
    showProgressBar: false,
    closeOnClick: true,
    borderRadius: BorderRadius.circular(12),
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
  );
}
