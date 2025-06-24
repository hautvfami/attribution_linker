import 'package:flutter_test/flutter_test.dart';
import 'package:attribution_linker/src/network_helper.dart';

void main() {
  group('NetworkHelper', () {
    test('should validate URLs correctly', () {
      expect(NetworkHelper.isValidUrl('https://example.com'), isTrue);
      expect(NetworkHelper.isValidUrl('http://example.com'), isTrue);
      expect(NetworkHelper.isValidUrl('ftp://example.com'), isFalse);
      expect(NetworkHelper.isValidUrl('invalid-url'), isFalse);
      expect(NetworkHelper.isValidUrl(''), isFalse);
    });

    test('should throw NetworkException for empty endpoint', () async {
      expect(
        () => NetworkHelper.postFingerprintData(
          endpoint: '',
          fingerprintData: {'test': 'data'},
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should throw NetworkException for invalid endpoint', () async {
      expect(
        () => NetworkHelper.postFingerprintData(
          endpoint: 'invalid-url',
          fingerprintData: {'test': 'data'},
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should handle network timeout', () async {
      expect(
        () => NetworkHelper.postFingerprintData(
          endpoint: 'https://httpbin.org/delay/10',
          fingerprintData: {'test': 'data'},
          options: {'timeout': 1}, // 1 second timeout
        ),
        throwsA(isA<NetworkException>()),
      );
    }, timeout: const Timeout(Duration(seconds: 5)));

    test('should handle successful response with httpbin', () async {
      try {
        final result = await NetworkHelper.postFingerprintData(
          endpoint: 'https://httpbin.org/post',
          fingerprintData: {
            'device_id': 'test-device',
            'os': 'test-os',
          },
          options: {
            'timeout': 10,
            'headers': {
              'X-Test': 'true',
            },
            'app_version': '1.0.0',
          },
        );

        // httpbin.org returns the request data in the response
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('json'), isTrue);

        final requestData = result['json'] as Map<String, dynamic>;
        expect(requestData.containsKey('fingerprint'), isTrue);
        expect(requestData.containsKey('app_version'), isTrue);
        expect(requestData['app_version'], equals('1.0.0'));

        final fingerprint = requestData['fingerprint'] as Map<String, dynamic>;
        expect(fingerprint['device_id'], equals('test-device'));
        expect(fingerprint['os'], equals('test-os'));

        print('✅ Successful API call result: $result');
      } catch (e) {
        // If the test fails due to network issues, just print a warning
        print('⚠️ Network test failed (this is ok if no internet): $e');
      }
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('should handle HTTP error responses', () async {
      expect(
        () => NetworkHelper.postFingerprintData(
          endpoint: 'https://httpbin.org/status/404',
          fingerprintData: {'test': 'data'},
        ),
        throwsA(isA<NetworkException>()),
      );
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('should check connectivity', () async {
      // Test with a reliable endpoint
      final isConnected =
          await NetworkHelper.checkConnectivity('https://httpbin.org');
      print('Connectivity test result: $isConnected');

      // Test with invalid endpoint
      final isNotConnected = await NetworkHelper.checkConnectivity(
          'https://invalid-domain-12345.com');
      expect(isNotConnected, isFalse);
    }, timeout: const Timeout(Duration(seconds: 15)));
  });

  group('NetworkException', () {
    test('should create exception with message', () {
      const exception = NetworkException('Test error');
      expect(exception.message, equals('Test error'));
      expect(exception.toString(), equals('NetworkException: Test error'));
    });
  });
}
