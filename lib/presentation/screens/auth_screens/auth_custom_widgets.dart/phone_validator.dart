class PhoneValidator {
  static String? validateEgyptianPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'أدخل رقم الهاتف';
    }

    // Remove any non-digits
    String cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check length
    if (cleanNumber.length != 11) {
      return 'رقم الهاتف يجب أن يكون 11 رقماً';
    }

    // Check if starts with valid Egyptian prefixes
    List<String> validPrefixes = ['010', '011', '012', '015'];
    String prefix = cleanNumber.substring(0, 3);

    if (!validPrefixes.contains(prefix)) {
      return 'رقم الهاتف يجب أن يبدأ بـ 010 أو 011 أو 012 أو 015';
    }

    return null;
  }

  static String formatToInternational(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // If starts with 01, add +20
    if (cleaned.startsWith('01')) {
      return '+2$cleaned';
    }

    // If already has country code
    if (cleaned.startsWith('201')) {
      return '+$cleaned';
    }

    return '+2$cleaned';
  }
}
