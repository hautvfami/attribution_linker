import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// A helper class for handling network requests related to attribution linking.
class NetworkHelper {
  static const int _defaultTimeoutSeconds = 30;
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Makes a POST request to the specified endpoint with fingerprint data.
  ///
  /// [endpoint] - The API endpoint URL
  /// [fingerprintData] - The device fingerprint data to send
  /// [options] - Additional options including headers, timeout, etc.
  ///
  /// Returns the parsed response data as a Map.
  /// Throws [NetworkException] for various network-related errors.
  static Future<Map<String, dynamic>> postFingerprintData({
    required String endpoint,
    required Map<String, dynamic> fingerprintData,
    Map<String, dynamic> options = const {},
  }) async {
    // Validate endpoint
    if (endpoint.isEmpty) {
      throw NetworkException('Endpoint URL cannot be empty');
    }

    Uri? uri;
    try {
      uri = Uri.parse(endpoint);
    } catch (e) {
      throw NetworkException('Invalid endpoint URL: $endpoint');
    }

    // Prepare request body
    final requestBody = {
      'fingerprint': fingerprintData,
      ...options,
    };

    // Prepare headers
    final headers = Map<String, String>.from(_defaultHeaders);
    if (options.containsKey('headers') && options['headers'] is Map) {
      headers.addAll(Map<String, String>.from(options['headers']));
    }

    // Get timeout
    final timeoutSeconds = options['timeout'] as int? ?? _defaultTimeoutSeconds;
    final timeout = Duration(seconds: timeoutSeconds);

    try {
      // Make POST request
      final response = await http
          .post(
        uri,
        headers: headers,
        body: json.encode(requestBody),
      )
          .timeout(
        timeout,
        onTimeout: () {
          throw NetworkException(
              'Request timeout after ${timeout.inSeconds} seconds');
        },
      );

      // Handle response
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException('Network connection failed: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw NetworkException('Invalid JSON response format: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('HTTP client error: $e');
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException('Unexpected error: $e');
    }
  }

  /// Handles HTTP response and extracts data.
  static Map<String, dynamic> _handleResponse(http.Response response) {
    // Check status code
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'HTTP ${response.statusCode}';

      // Try to extract error message from response body
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage += ': ${errorData['message']}';
        } else if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
        } else {
          errorMessage += ': ${response.body}';
        }
      } catch (_) {
        // If we can't parse the error, just include the raw body
        if (response.body.isNotEmpty) {
          errorMessage += ': ${response.body}';
        }
      }

      throw NetworkException(errorMessage);
    }

    // Parse JSON response
    try {
      final responseData = json.decode(response.body);
      if (responseData is Map<String, dynamic>) {
        return responseData;
      } else {
        throw NetworkException('Response is not a JSON object');
      }
    } on FormatException catch (e) {
      throw NetworkException('Invalid JSON response: ${e.message}');
    }
  }

  /// Makes a GET request to check server health or connectivity.
  static Future<bool> checkConnectivity(String endpoint) async {
    try {
      final uri = Uri.parse(endpoint);
      final response = await http.head(uri).timeout(
            const Duration(seconds: 10),
          );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Validates if the given URL is properly formatted.
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }
}

/// Custom exception class for network-related errors.
class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
