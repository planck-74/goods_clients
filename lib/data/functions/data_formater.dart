import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {
  static String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    Intl.defaultLocale = 'ar';
    String formattedDate = DateFormat('EEEE dd/MM/yyyy', 'ar').format(dateTime);

    return formattedDate;
  }
}
