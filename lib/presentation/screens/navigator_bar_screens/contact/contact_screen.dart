import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
      _showSnackBar(context, 'تم نسخ الرقم $phoneNumber');
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showSnackBar(context, 'تعذر فتح تطبيق الهاتف');
      }
    } catch (e) {
      _showSnackBar(context, 'حدث خطأ: $e');
    }
  }

  void _openChatScreen(BuildContext context) {
    Navigator.pushNamed(context, '/ChatScreen');
  }

  Future<void> _openSocialMedia(BuildContext context, String platform) async {
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
        _showSnackBar(
            context, 'تم نسخ الرابط ، ولكن تعذر فتحه مباشرة علي جهازك');
      }
    } catch (e) {
      _showSnackBar(context, 'حدث خطأ: $e');
    }
  }

  Widget _buildSocialIcon(String asset, VoidCallback onTap) {
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 230, 230),
      appBar: customAppBar(
        context,
        const Text(
          'تواصل معنا',
          style: TextStyle(color: whiteColor),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
              bottom: 0,
              child: Container(
                alignment: Alignment.bottomCenter,
                height: 400,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/cola.png'))),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => showCallDialog(context),
                    child: SizedBox(
                      height: 150,
                      width: screenWidth,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 10,
                            child: Image.asset(
                              'assets/images/Calling-amico.png',
                              width: 160,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'اتصل بنا',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '01116475757',
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                                Text(
                                  '01022002286',
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openChatScreen(context),
                    child: SizedBox(
                      height: 150,
                      width: screenWidth,
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            top: 10,
                            child: Image.asset(
                              'assets/images/Chat-cuate.png',
                              width: 200,
                            ),
                          ),
                          const Positioned(
                            left: 25,
                            top: 50,
                            child: Text(
                              'راسـلنا',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialIcon(
                          'assets/icons/facebook.png',
                          () => _openSocialMedia(context, 'facebook'),
                        ),
                        _buildSocialIcon(
                          'assets/icons/instagram.png',
                          () => _openSocialMedia(context, 'instagram'),
                        ),
                        _buildSocialIcon(
                          'assets/icons/whatsapp.png',
                          () => _openSocialMedia(context, 'whatsapp'),
                        ),
                        _buildSocialIcon(
                          'assets/icons/telegram.png',
                          () => _openSocialMedia(context, 'telegram'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
