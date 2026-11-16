import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/repository/auth_repository.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/widgets/dialog_widget/dialog_widget.dart';

/// Shared reaction to States.SESSIONEXPIRED: explain, clear all user data, go to login.
void handleSessionExpired(BuildContext context, WidgetRef ref) {
  final loc = context.loc;
  DialogBuilder.showSessionExpiredDialog(
    context: context,
    title: loc.text_session_expired_title,
    content: loc.text_session_expired_message,
    acceptButtonTitle: loc.text_ok,
    onAccept: () async {
      final navigator = Navigator.of(context);
      await ref.read(authRepository).removeAllData();
      navigator.pushNamedAndRemoveUntil(Routes.LOGIN, (_) => false);
    },
  );
}
