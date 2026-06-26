import 'package:smart_phone_number/src/country_data.dart';

/// نتيجة التحقق من الرقم
class PhoneResult {
  final String phoneNumber; // Formatted number
  final String? countryCode; // Country code (e.g., '967')
  final String? regionCode; // Region code (e.g., 'YE')
  final bool success; // Validation result
  final String message; // Status message
  final List<String>? possibleNumbers; // Possible number formats
  final List<CountryData>? possibleCountries; // Possible countries

  PhoneResult._({
    required this.phoneNumber,
    this.countryCode,
    this.regionCode,
    required this.success,
    required this.message,
    this.possibleNumbers,
    this.possibleCountries,
  });

  /// نتيجة نجاح
  factory PhoneResult.success(
    String phoneNumber,
    String countryCode,
    String regionCode,
  ) {
    return PhoneResult._(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      regionCode: regionCode,
      success: true,
      message: 'WhatsApp account found',
    );
  }

  /// نتيجة فشل
  factory PhoneResult.failure(
    String phoneNumber,
    String message, {
    List<String>? possibleNumbers,
    List<CountryData>? possibleCountries,
  }) {
    return PhoneResult._(
      phoneNumber: phoneNumber,
      success: false,
      message: message,
      possibleNumbers: possibleNumbers,
      possibleCountries: possibleCountries,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'PhoneResult(success: true, number: $phoneNumber, country: $countryCode)';
    } else {
      return 'PhoneResult(success: false, number: $phoneNumber, message: $message)';
    }
  }
}
