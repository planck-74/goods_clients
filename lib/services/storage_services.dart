import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goods_clients/business_logic/cubits/client_data/controller_cubit.dart';

class StorageServices {
  static FirebaseStorage storage = FirebaseStorage.instance;

  static Future<String> uploadImage({
    required BuildContext context,
    required File imageFile,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName =
        '${context.read<ControllerCubit>().nameController.text}_$timestamp.jpg';

    String uid = FirebaseAuth.instance.currentUser!.uid;

    Reference ref = storage.ref().child('clients/$uid/images/$fileName');

    try {
      await ref.putFile(imageFile);

      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return '';
    }
  }
}
