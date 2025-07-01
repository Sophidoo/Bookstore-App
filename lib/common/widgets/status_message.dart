import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum StatusMessage { success, error, info }

void showMessage(
  String message,
  StatusMessage status, {
  int autoCloseDuration = 2000,
}) {
  toastification.show(
    title: Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
    ),
    style: ToastificationStyle.fillColored,
    autoCloseDuration: Duration(milliseconds: autoCloseDuration),
    animationDuration: const Duration(milliseconds: 250),
    alignment: Alignment.topCenter,
    type:
        status == StatusMessage.success
            ? ToastificationType.success
            : status == StatusMessage.error
            ? ToastificationType.error
            : ToastificationType.info,
  );
}
