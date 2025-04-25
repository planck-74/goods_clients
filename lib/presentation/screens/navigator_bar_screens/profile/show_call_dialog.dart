import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart'; // assuming dark red color is defined here
import 'package:url_launcher/url_launcher.dart';

void showCallDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white, // Light background color
        title: const Text(
          'إضغط لنسخ الرقم',
          style: TextStyle(
            color: Color(0xFFB71C1C), // Dark Red color for title
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.all(5.0), // More padding for space
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPhoneNumberRow('01116475757', context),
              const Divider(
                  color: Colors.grey,
                  thickness: 0.5), // Divider with light grey
              _buildPhoneNumberRow('01022002286', context),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إغلاق',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFFB71C1C), // Dark red color for button text
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Function to build phone number row
Widget _buildPhoneNumberRow(String phoneNumber, BuildContext context) {
  return InkWell(
    onTap: () => _launchPhoneNumber(phoneNumber, context),
    child: Row(
      children: [
        const Icon(Icons.copy,
            color: Color(0xFFB71C1C)), // Dark red for the copy icon
        const SizedBox(width: 12),
        Text(
          phoneNumber,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black, // Black color for text on light background
          ),
        ),
      ],
    ),
  );
}

Future<void> _launchPhoneNumber(
    String phoneNumber, BuildContext context) async {
  try {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    Clipboard.setData(ClipboardData(text: phoneNumber));
    showSnackBar(context, 'تم نسخ الرقم $phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      showSnackBar(context, 'تعذر فتح تطبيق الهاتف');
    }
  } catch (e) {
    showSnackBar(context, 'حدث خطأ: $e');
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          const Color(0xFFB71C1C), // Dark red for the snackbar background
    ),
  );
}
