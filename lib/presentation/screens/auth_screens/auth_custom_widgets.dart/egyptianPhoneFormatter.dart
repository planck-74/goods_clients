import 'package:flutter/services.dart';

class EgyptianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    // Remove any non-digits
    newText = newText.replaceAll(RegExp(r'[^\d]'), '');

    // Ensure it starts with 01
    if (newText.isNotEmpty && !newText.startsWith('01')) {
      if (newText.startsWith('1')) {
        newText = '0$newText';
      } else if (!newText.startsWith('0')) {
        newText = '01$newText';
      }
    }

    // Limit to 11 digits total
    if (newText.length > 11) {
      newText = newText.substring(0, 11);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
