import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// معالج رسائل الخلفية
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // تأكد من تهيئة Firebase
  await Firebase.initializeApp();

  // إظهار الإشعار
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.show(
    message.notification?.hashCode ?? 0,
    message.notification?.title ?? 'رسالة جديدة',
    message.notification?.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'إشعارات عالية الأهمية',
        importance: Importance.high,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: const Color.fromARGB(255, 190, 30, 19),
        colorized: true,
        showWhen: true,
        channelShowBadge: true,
        actions: [
          AndroidNotificationAction('reply', 'الرد'),
          AndroidNotificationAction('view', 'عرض المحادثة'),
        ],
        styleInformation: BigTextStyleInformation(''),
      ),
    ),
    payload: '${message.data['chatId']}|${message.data['messageId']}',
  );
}

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> _saveFcmTokenToFirestore(String? token) async {
    if (token == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('clients')
            .doc(user.uid)
            .set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('FCM Token saved successfully for user: ${user.uid}');
      } catch (e) {
        print('Error saving FCM token: $e');
      }
    } else {
      print('No user is currently logged in');
    }
  }

  Future<void> init() async {
    // تسجيل معالج رسائل الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // طلب الأذونات مع تفعيل جميع أنواع الإشعارات
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      carPlay: true,
      criticalAlert: true,
      announcement: true,
    );

    // تهيئة إعدادات الإشعارات المحلية
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // معالجة النقر على الإشعار
        _handleNotificationTap(response.payload);
      },
    );

    // إنشاء قناة الإشعارات عالية الأهمية
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'إشعارات عالية الأهمية',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    // استقبال الرسائل في المقدمة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // تجنب عرض الإشعار إذا كان التطبيق في المقدمة والمستخدم في نفس المحادثة
      if (message.data['chatId'] == getCurrentChatId()) {
        return;
      }

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title ?? 'رسالة جديدة',
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              importance: Importance.high,
              priority: Priority.high,
              enableLights: true,
              enableVibration: true,
              playSound: true,
              channelShowBadge: true, icon: '@mipmap/ic_launcher',
              largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              color: const Color.fromARGB(255, 190, 30, 19), // primary color
              colorized: true,
              showWhen: true,
              fullScreenIntent: true,
              styleInformation: const BigTextStyleInformation(''),
            ),
          ),
          payload: '${message.data['chatId']}|${message.data['messageId']}',
        );
      }
    });
    // الحصول على رمز FCM وحفظه
    String? token = await _messaging.getToken();
    print('🔑 FCM Token: $token');
    await _saveFcmTokenToFirestore(token);

    // الاستماع لتحديثات رمز FCM والتأكد من حفظه
    _messaging.onTokenRefresh.listen((String? newToken) async {
      print('🔄 FCM Token refreshed: $newToken');
      await _saveFcmTokenToFirestore(newToken);
    });
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    final parts = payload.split('|');
    if (parts.length != 2) return;

    // Extract both chatId and messageId from payload
    final chatId = parts[0];
    final messageId = parts[1];

    // Navigate to chat screen with both parameters
    // Note: This needs to be implemented with proper navigation
    print('Navigating to chat $chatId and message $messageId');
  }

  String? getCurrentChatId() {
    // يمكن تخزين معرف المحادثة الحالية في متغير ثابت عندما يدخل المستخدم للمحادثة
    // وإعادة تعيينه عندما يخرج منها
    return null; // مبدئياً نعيد null حتى لا نمنع الإشعارات
  }
}
