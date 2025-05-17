import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {
  static String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    Intl.defaultLocale = 'ar';

    // التاريخ الأساسي
    String date = DateFormat('EEEE dd/MM/yyyy', 'ar').format(dateTime);

    // الوقت بصيغة 12 ساعة بدون AM/PM
    String time = DateFormat('h:mm', 'ar').format(dateTime);

    // تحديد الفترة: صباحًا أو مساءً
    String period = dateTime.hour < 12 ? 'صباحًا' : 'مساءً';

    return '$date - $time $period';
  }
}
