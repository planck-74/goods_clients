const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp, getApps } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

// تأكد من تهيئة Firebase Admin
if (getApps().length === 0) {
      initializeApp();
}

exports.sendMessageNotification = onDocumentCreated({
      document: 'chats/{chatId}/messages/{messageId}',
      region: 'europe-west1', // نفس منطقة المشروع
}, async (event) => {
      try {
            // تجاهل الإشعار إذا كانت الرسالة مكررة
            const messageData = event.data.data();
            if (messageData.notificationSent) {
                  console.log('Notification already sent for this message');
                  return null;
            }
            const { chatId, messageId } = event.params;
            const recipientId = messageData.recipientId;

            // تجاهل إذا لم يكن هناك مستلم
            if (!recipientId) {
                  console.log('No recipient ID found');
                  return null;
            }

            // الحصول على رمز FCM للمستلم
            const db = getFirestore();
            const recipientDoc = await db
                  .collection('clients')
                  .doc(recipientId)
                  .get();

            if (!recipientDoc.exists) {
                  console.log('Recipient document not found');
                  return null;
            }

            const fcmToken = recipientDoc.data()?.fcmToken;

            if (!fcmToken) {
                  console.log('No FCM token found for recipient');
                  return null;
            }

            // تحضير الإشعار
            const notificationPayload = {
                  notification: {
                        title: messageData.senderName || 'رسالة جديدة',
                        body: messageData.text || 'تم استلام رسالة جديدة',
                  },
                  data: {
                        chatId: chatId,
                        messageId: messageId,
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                  },
                  android: {
                        priority: 'high',
                        notification: {
                              channelId: 'high_importance_channel',
                              priority: 'high',
                              defaultSound: true,
                              defaultVibrateTimings: true,
                        }
                  },
                  apns: {
                        payload: {
                              aps: {
                                    sound: 'default',
                              }
                        }
                  },
                  token: fcmToken
            };

            // إرسال الإشعار
            const messaging = getMessaging();
            await messaging.send(notificationPayload);

            // تحديث الرسالة لتجنب إرسال إشعار مكرر
            await event.data.ref.update({
                  notificationSent: true
            });

            console.log('Notification sent successfully');
            return null;
      } catch (error) {
            console.error('Error sending notification:', error);
            return null;
      }
});