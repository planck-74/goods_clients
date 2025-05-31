import 'dart:io';

enum AttachmentType { image, file, voice }

class AttachmentFile {
  final String path;
  final AttachmentType type;
  final String name;
  final int? size;
  final File? file;

  AttachmentFile({
    required this.path,
    required this.type,
    required this.name,
    this.size,
    this.file,
  });
}
