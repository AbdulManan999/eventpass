import 'package:flutter/material.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/strings.dart';

/// All app dialogs live here as static methods.
class DialogBuilder {
  /// Used for States.SESSIONEXPIRED and States.APPUPDATE.
  static void showUpdateOrSessionDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String acceptButtonTitle,
    required VoidCallback onAcceptPressed,
    String? cancelButtonTitle,
    VoidCallback? onCancelPressed,
    bool isDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: isDismissible,
      builder: (ctx) => PopScope(
        canPop: isDismissible,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          content: Text(content),
          actions: [
            if (cancelButtonTitle != null)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onCancelPressed?.call();
                },
                child: Text(cancelButtonTitle),
              ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                Navigator.of(ctx).pop();
                onAcceptPressed();
              },
              child: Text(acceptButtonTitle),
            ),
          ],
        ),
      ),
    );
  }

  /// States.SESSIONEXPIRED: tells the user, then runs [onAccept] (clear data + go to login).
  static void showSessionExpiredDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String acceptButtonTitle,
    required VoidCallback onAccept,
  }) {
    showUpdateOrSessionDialog(
      context: context,
      title: title,
      content: content,
      acceptButtonTitle: acceptButtonTitle,
      onAcceptPressed: onAccept,
    );
  }

  static Future<void> showLogoutDialog({
    required BuildContext context,
    required VoidCallback callback,
    String title = logoutText,
    String content = logoutConfirmText,
    String buttonText = yesText,
    bool isCancelable = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: isCancelable,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (isCancelable) TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text(noText)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: redColor),
            onPressed: () {
              Navigator.of(ctx).pop();
              callback();
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  static void showNoInternetDialog(BuildContext context, String title, String content, VoidCallback callback) {
    showUpdateOrSessionDialog(
      context: context,
      title: title,
      content: content,
      acceptButtonTitle: okText,
      onAcceptPressed: callback,
      isDismissible: true,
    );
  }
}
