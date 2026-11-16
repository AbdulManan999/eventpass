import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:eventpass/utils/colors.dart';

class CustomToast {
  static void showToast(String message, {bool long = false, Color? backgroundColor}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: long ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor ?? Colors.black87,
      textColor: whiteColor,
      fontSize: 16.0,
    );
  }

  static void showIconToast(BuildContext context, String message, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(icon, color: whiteColor),
              const SizedBox(width: 8),
              Expanded(child: Text(message, style: const TextStyle(color: whiteColor))),
            ],
          ),
        ),
      );
  }
}
