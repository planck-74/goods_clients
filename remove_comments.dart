import 'dart:io';

void main() {
  final directory = Directory('lib');

  if (!directory.existsSync()) {
    print("⚠️ مجلد 'lib' غير موجود. تأكد من تشغيل السكربت داخل مجلد المشروع.");
    return;
  }

  final dartFiles = directory.listSync(recursive: true).where(
        (file) => file is File && file.path.endsWith('.dart'),
      );

  if (dartFiles.isEmpty) {
    print("⚠️ لم يتم العثور على أي ملفات Dart داخل مجلد 'lib/'.");
    return;
  }

  for (var file in dartFiles) {
    File dartFile = File(file.path);
    String content = dartFile.readAsStringSync();

    // إزالة التعليقات متعددة الأسطر (/* ... */)
    content = content.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');

    // إزالة التعليقات أحادية السطر سواء كانت منفصلة أو بجانب الكود
    content = content.replaceAll(RegExp(r'//.*'), '');

    dartFile.writeAsStringSync(content);
    print("✅ تمت إزالة التعليقات من: ${file.path}");
  }

  print("🎉 تم حذف جميع التعليقات من جميع ملفات Dart داخل 'lib/' بنجاح!");
}
