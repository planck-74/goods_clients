import 'package:flutter/material.dart';
import 'package:goods_clients/presentation/backgrounds/otp_background.dart';
import 'package:goods_clients/presentation/screens/auth_screens/auth_custom_widgets.dart/build_fields.dart';
import 'package:permission_handler/permission_handler.dart';

class GetClientDetails extends StatefulWidget {
  const GetClientDetails({super.key});

  @override
  State<GetClientDetails> createState() => _GetClientDetailsState();
}

class _GetClientDetailsState extends State<GetClientDetails> {
  bool _didShowExplanation = false; // حارس لمنع التكرار

  @override
  void initState() {
    super.initState();
    // جدول عرض التنبيه بعد أول إطار بناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didShowExplanation) {
        _didShowExplanation = true;
        _showPermissionExplanation();
      }
    });
  }

  // عرض رسالة شرح الإذن
  Future<void> _showPermissionExplanation() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('أهمية الإذن'),
          content: const Text(
            'لتتمكن من استخدام هذه الميزة التي تعتمد على الموقع الجغرافي، نحتاج إلى إذن للوصول إلى موقعك.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('أفهم'),
              onPressed: () {
                Navigator.of(context).pop();
                _requestLocationPermission(); // بعد أن وافق المستخدم، نطلب الإذن الفعلي
              },
            ),
          ],
        );
      },
    );
  }

  // طلب الإذن الفعلي
  Future<void> _requestLocationPermission() async {
    if (!await Permission.location.isGranted) {
      var status = await Permission.location.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        _showPermissionDeniedAlert();
      }
    }
  }

  // عرض رسالة في حالة رفض الإذن
  void _showPermissionDeniedAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('الإذن مرفوض'),
          content: const Text(
            'لم يتم منح الإذن للوصول إلى الموقع. من فضلك قم بالسماح لهذا الإذن من إعدادات الهاتف لتتمكن من استخدام هذه الميزة.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('إعدادات'),
              onPressed: () {
                openAppSettings(); // فتح إعدادات التطبيق مباشرة
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: const Stack(
            children: [
              BuildBackground(),
              BuildFields(),
            ],
          ),
        ),
      ),
    );
  }
}
