import 'package:flutter_test/flutter_test.dart';
import 'package:smart_phone_number/smart_phone_number.dart';

void main() {
  group('SmartPhoneNumber Tests', () {
    test('Detect Saudi number', () {
      List<CountryData> countries = SmartPhoneNumber.detectPossibleCountries(
        '501234567',
      );
      expect(countries.isNotEmpty, true);
      expect(countries.first.code, '966');
    });

    test('Detect Yemen number', () {
      List<CountryData> countries = SmartPhoneNumber.detectPossibleCountries(
        '771234567',
      );
      expect(countries.isNotEmpty, true);
      expect(countries.first.code, '967');
    });

    test('Generate possible numbers for ambiguous prefix', () {
      List<String> numbers = SmartPhoneNumber.generatePossibleNumbers(
        '771234567',
      );
      expect(numbers.contains('+967771234567'), true);
      expect(numbers.contains('+962771234567'), true);
    });
  });
}
// import 'package:flutter_test/flutter_test.dart';

// import 'package:smart_phone_number/smart_phone_number.dart';

// void main() {
//   test('adds one to input values', () {
//     final calculator = Calculator();
//     expect(calculator.addOne(2), 3);
//     expect(calculator.addOne(-7), -6);
//     expect(calculator.addOne(0), 1);
//   });
// }
