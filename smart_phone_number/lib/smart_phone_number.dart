library;

import 'package:smart_phone_number/smart_phone_number.dart';

export 'src/models/phone_result.dart';
export 'src/phone_detector.dart';
export 'src/whatsapp_validator.dart';
export 'src/country_data.dart';

/// الدالة الرئيسية للحزمة
class SmartPhoneNumber {
  /// تحويل الرقم إلى صيغة دولية والتحقق من وجوده على واتساب
  static Future<PhoneResult> detectAndValidate(String phoneNumber) async {
    return await WhatsAppValidator.validateWithWhatsApp(phoneNumber);
  }

  /// فقط كشف الدول المحتملة دون التحقق من واتساب
  static List<CountryData> detectPossibleCountries(String phoneNumber) {
    return PhoneDetector.detectPossibleCountries(phoneNumber);
  }

  /// توليد جميع الاحتمالات للرقم
  static List<String> generatePossibleNumbers(String phoneNumber) {
    List<CountryData> countries = PhoneDetector.detectPossibleCountries(
      phoneNumber,
    );
    return PhoneDetector.generatePossibleNumbers(phoneNumber, countries);
  }

  /// الحصول على معلومات الدولة من مفتاحها
  static CountryData? getCountryByCode(String code) {
    return CountryData.countries.firstWhere(
      (c) => c.code == code,
      orElse: () => throw Exception('Country not found'),
    );
  }

  static Future<PhoneResult> validateWithCountryCode({
    required String phoneNumber,
    required String countryCode,
    bool forceCountryCode = false,
  }) async {
    return await WhatsAppValidator.validateWithCustomCountryCode(
      phoneNumber,
      countryCode,
      forceCountryCode,
    );
  }

  /// التحقق من رقم هاتف مع تحديد الدولة كاملة (من CountryData)
  static Future<PhoneResult> validateWithCountry(
    String phoneNumber,
    CountryData country, {
    bool forceCountryCode = false,
  }) async {
    return await WhatsAppValidator.validateWithCustomCountryCode(
      phoneNumber,
      country.code,
      forceCountryCode,
    );
  }

  /// الحصول على معلومات الدولة من رمز المنطقة
  static CountryData? getCountryByRegion(String region) {
    return CountryData.countries.firstWhere(
      (c) => c.region == region,
      orElse: () => throw Exception('Country not found'),
    );
  }
}
