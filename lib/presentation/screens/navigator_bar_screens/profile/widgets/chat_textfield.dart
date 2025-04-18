import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

class ChatTextfield extends StatefulWidget {
  final String chatId;
  const ChatTextfield({super.key, required this.chatId});

  @override
  _ChatTextfieldState createState() => _ChatTextfieldState();
}

class _ChatTextfieldState extends State<ChatTextfield> {
  final TextEditingController messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _selectedFilePath;

  @override
  void initState() {
    super.initState();
    messageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // دالة اختيار الصورة بدون طلب صلاحيات
  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (file != null) {
      setState(() => _selectedFilePath = file.path);
      print("🖼️ Image selected: $_selectedFilePath");
    }
  }

  void _removeFile() {
    setState(() => _selectedFilePath = null);
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty && _selectedFilePath == null) return;

    final senderId = FirebaseAuth.instance.currentUser?.uid;
    final timestamp = FieldValue.serverTimestamp();
    final chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(senderId);

    String? lastMessageToUpdate;

    // إرسال النص
    if (messageController.text.isNotEmpty) {
      await chatDocRef.collection('messages').add({
        'sender': senderId,
        'text': messageController.text,
        'timestamp': timestamp,
      });
      lastMessageToUpdate = messageController.text;
    }

    // إرسال الصورة
    if (_selectedFilePath != null) {
      final localPath = _selectedFilePath!;
      setState(() => _selectedFilePath = null);

      final msgRef = await chatDocRef.collection('messages').add({
        'sender': senderId,
        'file': localPath,
        'uploading': true,
        'timestamp': timestamp,
      });

      final file = File(localPath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef =
          FirebaseStorage.instance.ref('chat_images/$senderId/$fileName');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await msgRef.update({
        'file': downloadUrl,
        'uploading': false,
      });

      lastMessageToUpdate = '[Image]';
    }

    // تحديث آخر رسالة بالمستند الرئيسي
    if (lastMessageToUpdate != null) {
      await chatDocRef.set({
        'clientId': senderId,
        'supplierId': supplierId, // عرِّف supplierId أو مرّره
        'lastMessage': lastMessageToUpdate,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedFilePath != null)
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(File(_selectedFilePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _removeFile,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  constraints:
                      const BoxConstraints(minHeight: 40, maxHeight: 150),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: _pickImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintText: 'رسالة',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                          maxLines: 5,
                          minLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.send),
                color: (messageController.text.isEmpty &&
                        _selectedFilePath == null)
                    ? Colors.blueGrey
                    : Colors.red,
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
