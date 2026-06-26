import 'package:url_launcher/url_launcher.dart';
import 'package:phone_number/phone_number.dart';
import 'phone_detector.dart';
import 'country_data.dart';
import 'models/phone_result.dart';

/// مدقق واتساب
class WhatsAppValidator {
  /// التحقق من وجود الرقم على واتساب مع تجربة جميع الاحتمالات
  static Future<PhoneResult> validateWithWhatsApp(String rawNumber) async {
    String cleaned = PhoneDetector.cleanNumber(rawNumber);

    // التحقق من صحة الرقم
    if (!PhoneDetector.isValidNumber(cleaned)) {
      return PhoneResult.failure(cleaned, 'Invalid phone number format');
    }

    // إذا كان الرقم يحتوي على +، نتحقق منه مباشرة
    if (cleaned.startsWith('+')) {
      bool exists = await _checkWhatsApp(cleaned);
      if (exists) {
        String? regionCode = await _getRegionCode(cleaned);
        String? countryCode = await _getCountryCodeFromRegion(regionCode);
        return PhoneResult.success(
          cleaned,
          countryCode ?? '',
          regionCode ?? '',
        );
      }
      return PhoneResult.failure(cleaned, 'No WhatsApp account found');
    }

    // **التعديل الأساسي: استخدم detectBestCountry بدلاً من detectPossibleCountries**
    CountryData? bestCountry = await PhoneDetector.detectBestCountry(cleaned);

    if (bestCountry == null) {
      return PhoneResult.failure(
        cleaned,
        'Could not detect country from number prefix',
      );
    }

    // نحاول فقط مع البلد الذي تم اختياره
    String numberWithCode = '+${bestCountry.code}$cleaned';

    bool exists = await _checkWhatsApp(numberWithCode);
    if (exists) {
      return PhoneResult.success(
        numberWithCode,
        bestCountry.code,
        bestCountry.region,
      );
    }

    return PhoneResult.failure(
      cleaned,
      'No WhatsApp account found for this number',
    );
  }

  /// التحقق من وجود الرقم على واتساب
  static Future<bool> _checkWhatsApp(String internationalNumber) async {
    try {
      String cleanForUrl = internationalNumber.replaceFirst('+', '');
      final whatsappUrl = Uri.parse('whatsapp://send?phone=$cleanForUrl');

      if (await canLaunchUrl(whatsappUrl)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على رمز المنطقة من الرقم الدولي
  static Future<String?> _getRegionCode(String internationalNumber) async {
    try {
      final phoneNumber = await PhoneNumberUtil().parse(internationalNumber);
      return phoneNumber.regionCode;
    } catch (e) {
      return null;
    }
  }

  /// الحصول على مفتاح الدولة من رمز المنطقة
  static Future<String?> _getCountryCodeFromRegion(String? regionCode) async {
    if (regionCode == null) return null;

    for (var country in CountryData.countries) {
      if (country.region == regionCode) {
        return country.code;
      }
    }
    return null;
  }

  /// التحقق من وجود الرقم على واتساب مع تحديد مفتاح الدولة يدوياً
  static Future<PhoneResult> validateWithCustomCountryCode(
    String rawNumber,
    String customCountryCode,
    bool forceCountryCode,
  ) async {
    String cleaned = PhoneDetector.cleanNumber(rawNumber);

    // التحقق من صحة الرقم
    if (!PhoneDetector.isValidNumber(cleaned)) {
      return PhoneResult.failure(cleaned, 'Invalid phone number format');
    }

    // البحث عن معلومات الدولة
    CountryData? country;
    try {
      country = CountryData.countries.firstWhere(
        (c) => c.code == customCountryCode,
      );
    } catch (e) {
      return PhoneResult.failure(
        cleaned,
        'Country code $customCountryCode not found in supported countries',
      );
    }

    String numberWithCode;

    if (forceCountryCode) {
      // إجبار استخدام مفتاح الدولة المحدد حتى لو كان الرقم يبدأ بمفتاح آخر
      numberWithCode = '+$customCountryCode$cleaned';
    } else {
      // التحقق مما إذا كان الرقم يبدأ بالفعل بمفتاح دولة
      bool startsWithCountryCode = false;
      String? detectedCountryCode;

      // التحقق من جميع الدول لمعرفة إذا كان الرقم يبدأ بأي مفتاح دولة
      for (var c in CountryData.countries) {
        if (cleaned.startsWith(c.code)) {
          startsWithCountryCode = true;
          detectedCountryCode = c.code;
          break;
        }
      }

      if (startsWithCountryCode && detectedCountryCode == customCountryCode) {
        // الرقم يبدأ بنفس مفتاح الدولة المحدد
        numberWithCode =
            '+$customCountryCode${cleaned.substring(customCountryCode.length)}';
      } else if (startsWithCountryCode &&
          detectedCountryCode != customCountryCode) {
        // الرقم يبدأ بمفتاح دولة مختلف - نستبدله بالمفتاح المطلوب
        numberWithCode = '+$customCountryCode$cleaned';
      } else {
        // الرقم لا يبدأ بأي مفتاح دولة
        numberWithCode = '+$customCountryCode$cleaned';
      }
    }

    // التأكد من طول الرقم مناسب للدولة المحددة
    String numberWithoutCode = numberWithCode.replaceFirst(
      '+$customCountryCode',
      '',
    );
    if (numberWithoutCode.length < country.minLength ||
        numberWithoutCode.length > country.maxLength) {
      return PhoneResult.failure(
        cleaned,
        'Number length (${numberWithoutCode.length}) is not valid for ${country.name}. Expected between ${country.minLength} and ${country.maxLength} digits.',
      );
    }

    // التحقق من صحة البادئة للدولة المحددة
    bool hasValidPrefix = false;
    for (String prefix in country.prefixes) {
      if (numberWithoutCode.startsWith(prefix)) {
        hasValidPrefix = true;
        break;
      }
    }

    if (!hasValidPrefix) {
      return PhoneResult.failure(
        cleaned,
        'Number prefix does not match any valid prefix for ${country.name}. Valid prefixes: ${country.prefixes.join(', ')}',
      );
    }

    // التحقق من وجود الرقم على واتساب
    bool exists = await _checkWhatsApp(numberWithCode);
    if (exists) {
      return PhoneResult.success(numberWithCode, country.code, country.region);
    }

    return PhoneResult.failure(
      cleaned,
      'No WhatsApp account found for this number with country code $customCountryCode',
    );
  }
}
