import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:url_launcher/url_launcher.dart';

void showCallDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: whiteColor,
        title: const Text(
          'إضغط لنسخ الرقم',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _launchPhoneNumber('01116475757', context),
                child: const Row(
                  children: [
                    Icon(Icons.copy, color: darkBlueColor),
                    SizedBox(width: 8),
                    Text(
                      '01116475757',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(endIndent: 80),
              InkWell(
                onTap: () => _launchPhoneNumber('01022002286', context),
                child: const Row(
                  children: [
                    Icon(Icons.copy, color: darkBlueColor),
                    SizedBox(width: 8),
                    Text(
                      '01022002286',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
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
                color: darkBlueColor,
              ),
            ),
          ),
        ],
      );
    },
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
    SnackBar(content: Text(message)),
  );
}
