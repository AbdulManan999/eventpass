import 'package:flutter/material.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/constants.dart';

class ErrorSnackbars {
  static void _show(BuildContext context, String msg, {Color color = redColor}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(backgroundColor: color, content: Text(msg)));
  }

  static void showInternetConnectError(BuildContext context) =>
      _show(context, Constants.errorInternetConnection);

  static void showNoDataFound(BuildContext context) => _show(context, 'No record found!');

  static void showServerError(BuildContext context) =>
      _show(context, 'Application is unable to connect with the server!');

  static void showTokenExpired(BuildContext context) =>
      _show(context, Constants.errorSessionExpired);

  static void showCustomSnackBar(BuildContext context, String msg, Color? color) =>
      _show(context, msg, color: color ?? redColor);
}
