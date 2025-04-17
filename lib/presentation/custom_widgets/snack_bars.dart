import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar({
  required BuildContext context,
  required String text,
  Color? backgroundColor,
  Color? textColor,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor ?? Colors.red,
      content: Text(text,
          style: TextStyle(
              color: textColor ?? const Color.fromARGB(255, 255, 255, 255))),
    ),
  );
}
