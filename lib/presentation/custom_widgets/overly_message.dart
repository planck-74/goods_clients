import 'package:flutter/material.dart';

void showCustomOverlayMessage(
  BuildContext context,
  String message, {
  Color textColor = Colors.white, // اللون الافتراضي للنص
  Color backgroundColor = Colors.green, // اللون الافتراضي للخلفية
  double top = 20, // المسافة الافتراضية من الأعلى
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + top, // لتحديد مكان الرسالة
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor, // اللون المخصص للخلفية
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
