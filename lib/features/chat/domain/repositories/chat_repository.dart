import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/attachment_file.dart';
import 'package:goods_clients/data/models/chat_message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<QuerySnapshot> getMessages(String chatId, {int limit = 20}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> sendTextMessage({
    required String chatId,
    required String text,
    String? replyToId,
    String? supplierId,
  }) async {
    final senderId = currentUserId;
    if (senderId == null) return;

    final timestamp = FieldValue.serverTimestamp();
    final chatDocRef = _firestore.collection('chats').doc(chatId);

    final messageData = {
      'sender': senderId,
      'text': text.trim(),
      'timestamp': timestamp,
      'type': 'text',
      'status': 'sent',
      if (replyToId != null) 'replyToId': replyToId,
    };

    await chatDocRef.collection('messages').add(messageData);
    await _updateLastMessage(chatDocRef, text.trim(), timestamp, supplierId);
  }

  Future<void> sendAttachment({
    required String chatId,
    required AttachmentFile attachment,
    String? replyToId,
    String? supplierId,
    Function(double)? onProgress,
  }) async {
    final senderId = currentUserId;
    if (senderId == null) return;

    final timestamp = FieldValue.serverTimestamp();
    final chatDocRef = _firestore.collection('chats').doc(chatId);

    final tempMessageRef = await chatDocRef.collection('messages').add({
      'sender': senderId,
      'fileName': attachment.name,
      'fileSize': attachment.size,
      'timestamp': timestamp,
      'type': attachment.type.name,
      'status': 'sending',
      'uploading': true,
      if (replyToId != null) 'replyToId': replyToId,
    });

    try {
      final downloadUrl = await _uploadFile(
        attachment,
        senderId,
        onProgress: onProgress,
      );

      await tempMessageRef.update({
        'file': downloadUrl,
        'uploading': false,
        'status': 'sent',
      });

      String lastMessageText = _getLastMessageText(attachment);
      await _updateLastMessage(
          chatDocRef, lastMessageText, timestamp, supplierId);
    } catch (e) {
      await tempMessageRef.update({
        'status': 'failed',
        'uploading': false,
      });
      rethrow;
    }
  }

  Future<String> _uploadFile(
    AttachmentFile attachment,
    String senderId, {
    Function(double)? onProgress,
  }) async {
    final file = File(attachment.path);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${attachment.name}';
    final folderPath = _getFolderPath(attachment.type);
    final storageRef = _storage.ref('$folderPath/$senderId/$fileName');
    final uploadTask = storageRef.putFile(file);

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  String _getFolderPath(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return 'chat_images';
      case AttachmentType.file:
        return 'chat_files';
      case AttachmentType.voice:
        return 'chat_voice';
    }
  }

  String _getLastMessageText(AttachmentFile attachment) {
    switch (attachment.type) {
      case AttachmentType.image:
        return '📷 صورة';
      case AttachmentType.file:
        return '📄 ${attachment.name}';
      case AttachmentType.voice:
        return '🎤 رسالة صوتية';
    }
  }

  Future<void> _updateLastMessage(
    DocumentReference chatDocRef,
    String message,
    FieldValue timestamp,
    String? supplierId,
  ) async {
    await chatDocRef.set({
      'clientId': currentUserId,
      'supplierId': supplierId,
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'updatedAt': timestamp,
    }, SetOptions(merge: true));
  }

  Future<void> deleteMessages(String chatId, List<String> messageIds) async {
    final batch = _firestore.batch();
    for (String messageId in messageIds) {
      final docRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);
      batch.delete(docRef);
    }
    await batch.commit();
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> clearChat(String chatId) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
