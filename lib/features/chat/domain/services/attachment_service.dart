import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/attachment_file.dart';

class AttachmentService {
  final ImagePicker _picker;

  AttachmentService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<List<AttachmentFile>> pickImages() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      return files
          .map((file) => AttachmentFile(
                path: file.path,
                type: AttachmentType.image,
                name: file.name,
              ))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AttachmentFile>> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'pptx'],
      );

      if (result == null) return [];

      return result.files
          .where((file) => file.path != null)
          .map((file) => AttachmentFile(
                path: file.path!,
                type: AttachmentType.file,
                name: file.name,
                size: file.size,
              ))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AttachmentFile?> captureImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) return null;

      return AttachmentFile(
        path: file.path,
        type: AttachmentType.image,
        name: file.name,
      );
    } catch (e) {
      rethrow;
    }
  }
}
