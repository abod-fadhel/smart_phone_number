import 'package:flutter/material.dart';
import 'package:smart_phone_number/smart_phone_number.dart';

class PhoneValidatorExample extends StatefulWidget {
  const PhoneValidatorExample({super.key});

  @override
  _PhoneValidatorExampleState createState() => _PhoneValidatorExampleState();
}

class _PhoneValidatorExampleState extends State<PhoneValidatorExample> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  bool _loading = false;

  Future<void> _validateNumber() async {
    if (_controller.text.isEmpty) {
      setState(() => _result = 'Please enter a phone number');
      return;
    }

    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      PhoneResult result = await SmartPhoneNumber.detectAndValidate(
        _controller.text,
      );

      setState(() {
        if (result.success) {
          _result =
              '''
✅ WhatsApp account found!
📱 Number: ${result.phoneNumber}
🌍 Country Code: +${result.countryCode}
📍 Region: ${result.regionCode}
''';
        } else {
          _result = '❌ ${result.message}';
          if (result.possibleCountries != null) {
            _result += '\n\nPossible countries:';
            for (var country in result.possibleCountries!) {
              _result += '\n• ${country.nameAr} (${country.name})';
            }
          }
        }
      });
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Validator')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter phone number',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _validateNumber,
              child: _loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Validate'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_result, style: TextStyle(fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
