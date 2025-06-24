import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:attribution_linker/attribution_linker.dart';
import 'package:http/http.dart' as http;

/// Example usage of AttributionLinker with encryption and server submission
class AttributionService {
  final String _endpoint;
  final String _customKey;

  AttributionService({
    required String endpoint,
    required String customKey,
  })  : _endpoint = endpoint,
        _customKey = customKey;

  /// Collects fingerprint, encrypts it, and submits to server
  Future<Map<String, dynamic>> submitFingerprint() async {
    try {
      // 1. Collect fingerprint
      final fingerprint = await AttributionLinker().fingerprint;

      // 2. Encrypt fingerprint data
      final encryptedData = _encryptData(fingerprint);

      // 3. Submit to server
      final response = await _submitToServer(encryptedData);

      return {
        'success': true,
        'fingerprint': fingerprint,
        'response': response,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Simple encryption using custom key (for demonstration)
  /// In production, use more robust encryption methods
  Map<String, dynamic> _encryptData(Map<String, dynamic> data) {
    final jsonString = json.encode(data);
    final bytes = utf8.encode(jsonString);

    // Simple XOR encryption with custom key
    final keyBytes = utf8.encode(_customKey);
    final encryptedBytes = <int>[];

    for (int i = 0; i < bytes.length; i++) {
      encryptedBytes.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    final base64Encrypted = base64.encode(encryptedBytes);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Generate a simple hash for integrity check
    final hash = sha256
        .convert(utf8.encode('$base64Encrypted$_customKey$timestamp'))
        .toString();

    return {
      'data': base64Encrypted,
      'timestamp': timestamp,
      'hash': hash,
    };
  }

  /// Submit encrypted data to server
  Future<Map<String, dynamic>> _submitToServer(
      Map<String, dynamic> encryptedData) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Flutter-AttributionLinker/1.0',
        },
        body: json.encode({
          'encrypted_fingerprint': encryptedData,
          'client_id': _generateClientId(),
          'version': '1.0.0',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generate a simple client ID (in production, use UUID)
  String _generateClientId() {
    final random = Random();
    return List.generate(16, (index) => random.nextInt(16).toRadixString(16))
        .join();
  }

  /// Decrypt data (for testing purposes)
  Map<String, dynamic> decryptData(Map<String, dynamic> encryptedData) {
    try {
      final base64Encrypted = encryptedData['data'] as String;
      final timestamp = encryptedData['timestamp'] as int;
      final receivedHash = encryptedData['hash'] as String;

      // Verify hash
      final expectedHash = sha256
          .convert(utf8.encode('$base64Encrypted$_customKey$timestamp'))
          .toString();
      if (receivedHash != expectedHash) {
        throw Exception('Data integrity check failed');
      }

      // Decrypt
      final encryptedBytes = base64.decode(base64Encrypted);
      final keyBytes = utf8.encode(_customKey);
      final decryptedBytes = <int>[];

      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      final decryptedString = utf8.decode(decryptedBytes);
      return json.decode(decryptedString);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
}

/// Example usage
void main() async {
  // Initialize attribution service
  final service = AttributionService(
    endpoint: 'https://your-server.com/api/fingerprint',
    customKey: 'your-secret-key-here',
  );

  // Submit fingerprint
  final result = await service.submitFingerprint();

  if (result['success']) {
    print('Fingerprint submitted successfully!');
    print('Response: ${result['response']}');
  } else {
    print('Error: ${result['error']}');
  }
}
