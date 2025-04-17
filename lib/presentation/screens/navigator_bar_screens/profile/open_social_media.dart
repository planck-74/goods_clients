import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/profile/show_call_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openSocialMedia(BuildContext context, String platform) async {
  try {
    String url = '';
    switch (platform) {
      case 'facebook':
        url = 'https:';
        break;
      case 'telegram':
        url = 'https:';
        break;
      case 'whatsapp':
        url = 'https:';
        break;
      case 'instagram':
        url = 'https:';
        break;
      default:
        return;
    }
    final Uri uri = Uri.parse(url);
    Clipboard.setData(ClipboardData(text: url));

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showSnackBar(context, 'تم نسخ الرابط ، ولكن تعذر فتحه مباشرة علي جهازك');
    }
  } catch (e) {
    showSnackBar(context, 'حدث خطأ: $e');
  }
}

Widget buildSocialIcon(String asset, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    customBorder: const CircleBorder(),
    child: CircleAvatar(
      backgroundColor: scaffoldBackgroundColor,
      radius: 30,
      child: Image.asset(
        asset,
        height: 30,
      ),
    ),
  );
}
