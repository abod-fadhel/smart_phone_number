import 'package:smart_phone_number/src/ip_location.dart';

import 'country_data.dart';

/// كاشف الدول من مقدمات الأرقام
class PhoneDetector {
  /// كشف جميع الدول المحتملة للرقم
  static List<CountryData> detectPossibleCountries(String rawNumber) {
    String cleaned = cleanNumber(rawNumber);
    List<CountryData> possibleCountries = [];

    for (var country in CountryData.countries) {
      for (String prefix in country.prefixes) {
        if (cleaned.startsWith(prefix)) {
          int expectedMinLength = country.minLength;
          int expectedMaxLength = country.maxLength;

          // حساب طول الرقم بدون مفتاح الدولة
          int numberLength = cleaned.length;

          if (numberLength >= expectedMinLength &&
              numberLength <= expectedMaxLength) {
            possibleCountries.add(country);
            break;
          }
        }
      }
    }

    return possibleCountries;
  }

  /// توليد جميع الصيغ المحتملة للرقم
  static List<String> generatePossibleNumbers(
    String rawNumber,
    List<CountryData> countries,
  ) {
    String cleaned = cleanNumber(rawNumber);

    // إزالة الصفر من البداية إذا وجد
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    List<String> possibleNumbers = [];

    for (var country in countries) {
      // الصيغة الأساسية: مفتاح الدولة + الرقم
      String withCode = '+${country.code}$cleaned';
      possibleNumbers.add(withCode);

      // تجربة الصيغ المختلفة لكل مقدمة
      for (String prefix in country.prefixes) {
        if (cleaned.startsWith(prefix)) {
          // إزالة المقدمة وإعادة إضافتها
          String withoutPrefix = cleaned.substring(prefix.length);
          String recombined = '+${country.code}$prefix$withoutPrefix';
          if (recombined != withCode) {
            possibleNumbers.add(recombined);
          }
        }
      }
    }

    // إزالة التكرارات
    return possibleNumbers.toSet().toList();
  }

  static String cleanNumber(String number) {
    String cleaned = number.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);
    return cleaned;
  }

  /// التحقق من صحة الرقم (يحتوي على أرقام فقط)
  static bool isValidNumber(String number) {
    String cleaned = cleanNumber(number);
    return RegExp(r'^[0-9+]+$').hasMatch(cleaned);
  }

  /// الحصول على بلد المستخدم من خلال IP
  static Future<String?> _getUserCountryFromIP() async {
    return await IpLocationService.getUserCountryCode();
  }

  /// كشف أفضل بلد للرقم (مع التعامل مع التشابهات)
  static Future<CountryData?> detectBestCountry(String rawNumber) async {
    String cleaned = cleanNumber(rawNumber);

    // 1. كشف جميع الدول المحتملة للرقم
    List<CountryData> possible = detectPossibleCountries(cleaned);

    if (possible.isEmpty) return null;
    if (possible.length == 1) return possible.first;

    // 2. عند وجود تشابه (مثل المغرب والجزائر)، نستخدم IP Geolocation
    String? userCountryCode = await _getUserCountryFromIP();

    if (userCountryCode != null) {
      for (var country in possible) {
        if (country.region == userCountryCode) {
          return country; // نختار البلد المطابق لموقع المستخدم
        }
      }
    }

    // 3. احتياطياً: نرجع أول بلد في القائمة
    return possible.first;
  }
}
