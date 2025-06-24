# API Reference

## AttributionLinker Class

The main class for collecting device fingerprints using WebView.

### Constructor

```dart
AttributionLinker()
```

Returns the singleton instance of `AttributionLinker`.

### Properties

#### fingerprint

```dart
Future<Map<String, dynamic>> get fingerprint
```

Gets the device fingerprint. If already cached, returns immediately. Otherwise, creates a headless WebView to collect fingerprint data.

**Returns:** A `Future` that completes with a `Map<String, dynamic>` containing the fingerprint data.

**Throws:** `Exception` if fingerprint collection fails.

### Methods

#### init()

```dart
void init()
```

Initializes the attribution linker. This method should be called before using the fingerprint getter.

## Fingerprint Data Structure

The fingerprint data contains the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `os_type` | String | Operating system type (android, ios, macos, windows, linux, others) |
| `os_name` | String | Operating system name |
| `os_version` | String | Operating system version |
| `browser_name` | String | Browser name |
| `browser_version` | String | Browser version |
| `device_model` | String | Device model |
| `device_type` | String | Device type |
| `device_arch` | String | Device architecture |
| `device_bitness` | String | Device bitness (32/64 bit) |
| `screen_res` | String | Screen resolution (e.g., "1920x1080") |
| `pixel_ratio` | double | Device pixel ratio |
| `timezone` | String | System timezone |
| `language` | String | Browser language |
| `cpu_cores` | String | Number of CPU cores |
| `device_memory` | String | Device memory in GB |
| `system_brightness` | String | System theme (light/dark) |
| `user_agent` | String | Full user agent string |
| `user_agent_data` | Object? | UserAgentData object (if available) |
| `user_agent_parsed` | Object | Parsed user agent information |
| `browser_full_version_list` | String | Full version list of browsers |

## Example Usage

### Basic Usage

```dart
import 'package:attribution_linker/attribution_linker.dart';

void main() async {
  // Initialize the attribution linker
  final linker = AttributionLinker();
  linker.init();

  try {
    // Collect fingerprint data
    Map<String, dynamic> fingerprint = await linker.fingerprint;
    
    print('Device OS: ${fingerprint['os_type']}');
    print('Browser: ${fingerprint['browser_name']}');
    print('Screen Resolution: ${fingerprint['screen_res']}');
    
    // Use fingerprint data as needed
    
  } catch (e) {
    print('Error collecting fingerprint: $e');
  }
}
```

### Advanced Usage with Encryption

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:attribution_linker/attribution_linker.dart';

class FingerprintService {
  final String customKey;
  
  FingerprintService({required this.customKey});
  
  Future<String> getEncryptedFingerprint() async {
    final fingerprint = await AttributionLinker().fingerprint;
    return _encrypt(fingerprint);
  }
  
  String _encrypt(Map<String, dynamic> data) {
    final jsonString = json.encode(data);
    final bytes = utf8.encode(jsonString);
    
    // Simple XOR encryption
    final keyBytes = utf8.encode(customKey);
    final encryptedBytes = <int>[];
    
    for (int i = 0; i < bytes.length; i++) {
      encryptedBytes.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64.encode(encryptedBytes);
  }
}
```

## Error Handling

The package may throw the following exceptions:

- **Exception**: General fingerprint collection failure
- **Exception**: Timeout waiting for fingerprint collection
- **Exception**: WebView creation or execution failure

Always wrap calls to `fingerprint` in try-catch blocks:

```dart
try {
  final fingerprint = await AttributionLinker().fingerprint;
  // Use fingerprint data
} catch (e) {
  // Handle error
  print('Fingerprint collection failed: $e');
}
```

## Performance Considerations

- The first call to `fingerprint` will take longer as it creates a WebView
- Subsequent calls return cached data immediately
- The singleton pattern ensures only one instance exists
- WebView resources are properly disposed after collection

## Privacy and Security

- Only collects data available through standard web APIs
- No personal information is collected without explicit consent
- Consider implementing proper encryption for sensitive applications
- Inform users about data collection practices
- Comply with relevant privacy regulations (GDPR, CCPA, etc.)
