// lib/src/ip_location.dart
import 'package:get_country_ip/get_country_ip.dart';

/// خدمة تحديد بلد المستخدم من خلال IP
class IpLocationService {
  static final GetCountryIp _ipService = GetCountryIp();

  /// جلب بلد المستخدم الحالي (رمز مكون من حرفين مثل 'MA', 'DZ', 'SA', 'US')
  static Future<String?> getUserCountryCode() async {
    try {
      final location = await _ipService.getIPLocation();

      if (location != null && location['countryCode'] != null) {
        // location['countryCode'] يعيد شيء مثل 'MA' للمغرب، 'DZ' للجزائر
        return location['countryCode'] as String?;
      }
      return null;
    } catch (e) {
      print('IP Location failed: $e');
      return null;
    }
  }

  /// جلب جميع معلومات الموقع (للحاجة المستقبلية)
  static Future<Map<String, dynamic>?> getUserFullLocation() async {
    try {
      return await _ipService.getIPLocation();
    } catch (e) {
      print('IP Location failed: $e');
      return null;
    }
  }
}
