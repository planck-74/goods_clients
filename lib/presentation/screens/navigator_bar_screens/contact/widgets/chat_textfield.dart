import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

class ChatTextfield extends StatefulWidget {
  final String chatId;
  const ChatTextfield({super.key, required this.chatId});

  @override
  _ChatTextfieldState createState() => _ChatTextfieldState();
}

class _ChatTextfieldState extends State<ChatTextfield> {
  final TextEditingController messageController = TextEditingController();
  String? _selectedFilePath;

  @override
  void initState() {
    super.initState();
    messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });
      print("File selected: $_selectedFilePath");
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFilePath = null;
    });
  }

  Future<void> sendMessage() async {
    print("Start sendMessage");

    if (messageController.text.isEmpty && _selectedFilePath == null) return;

    final senderId = FirebaseAuth.instance.currentUser?.uid;
    final timestamp = FieldValue.serverTimestamp();
    final chatDocRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    String? lastMessageToUpdate;

    // إرسال الرسالة النصية
    if (messageController.text.isNotEmpty) {
      print("Sending text message");

      await chatDocRef.collection('messages').add({
        'sender': senderId,
        'text': messageController.text,
        'timestamp': timestamp,
      });

      lastMessageToUpdate = messageController.text;
    }

    // إرسال ملف صورة
    if (_selectedFilePath != null) {
      String localFilePath = _selectedFilePath!;
      setState(() {
        _selectedFilePath = null;
      });

      print("Uploading file");

      DocumentReference messageRef =
          await chatDocRef.collection('messages').add({
        'sender': senderId,
        'file': localFilePath,
        'uploading': true,
        'timestamp': timestamp,
      });

      File file = File(localFilePath);
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference = FirebaseStorage.instance
          .ref('chat_images')
          .child(FirebaseAuth.instance.currentUser?.uid ?? '')
          .child(fileName);
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print("File uploaded. Download URL: $downloadUrl");

      await messageRef.update({
        'file': downloadUrl,
        'uploading': false,
      });

      lastMessageToUpdate = '[Image]';
    }

    // تحديث مستند المحادثة الرئيسي
    if (lastMessageToUpdate != null) {
      await chatDocRef.set({
        'clientId': FirebaseAuth
            .instance.currentUser?.uid, // تأكد إن chatId يمثل العميل
        'supplierId': supplierId, // عرّف supplierId في الكلاس أو مرره للصفحة
        'lastMessage': lastMessageToUpdate,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 2, 8, 8),
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
                    color: const Color.fromARGB(255, 255, 255, 255),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 2),
                      IconButton(
                        style: ButtonStyle(
                          side: WidgetStateProperty.all(
                              const BorderSide(width: 0.5)),
                        ),
                        icon: const Icon(Icons.attach_file),
                        onPressed: _pickFile,
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
                          keyboardType: TextInputType.multiline,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: Color.fromARGB(255, 253, 254, 255),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.send),
                  color: (messageController.text.isEmpty &&
                          _selectedFilePath == null)
                      ? Colors.blueGrey
                      : Colors.red,
                  onPressed: sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
