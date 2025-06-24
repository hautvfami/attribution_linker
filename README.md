# Flutter Attribution Linker

A Flutter package for creating device fingerprints and attribution linking using WebView. This package collects device and browser information to create a unique fingerprint for attribution tracking.

## Features

- 🔍 **Device Fingerprinting**: Collects comprehensive device and browser information
- 🚀 **Headless WebView**: Uses Flutter InAppWebView for data collection
- 💾 **Caching**: Fingerprint data is cached after first collection
- 🔒 **Privacy-Aware**: Collects only standard browser API data
- 📱 **Cross-Platform**: Works on iOS and Android

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  attribution_linker: ^0.0.1
```

## Screenshot

<img src="https://github.com/hautvfami/attribution_linker/blob/main/example/screenshots/simulator_screenshot_1.png?raw=true" alt="Attribution Linker Example" width="150">

*Example app showing device fingerprint collection in action*

## Usage

### Basic Usage

```dart
import 'package:attribution_linker/attribution_linker.dart';

// Initialize the attribution linker
final linker = AttributionLinker();
linker.init();

// Collect fingerprint data
Map<String, dynamic> fingerprint = await linker.fingerprint;

print('Device OS: ${fingerprint['os_type']}');
print('Browser: ${fingerprint['browser_name']}');
print('Screen Resolution: ${fingerprint['screen_res']}');
```

### Fingerprint Data Structure

The fingerprint contains the following information:

- `os_type`: Operating system type (android, ios, macos, windows, linux, others)
- `os_name`: Operating system name
- `os_version`: Operating system version
- `browser_name`: Browser name
- `browser_version`: Browser version
- `device_model`: Device model
- `device_type`: Device type
- `device_arch`: Device architecture
- `device_bitness`: Device bitness (32/64 bit)
- `screen_res`: Screen resolution (e.g., "1920x1080")
- `pixel_ratio`: Device pixel ratio
- `timezone`: System timezone
- `language`: Browser language
- `cpu_cores`: Number of CPU cores
- `device_memory`: Device memory in GB
- `system_brightness`: System theme (light/dark)
- `user_agent`: Full user agent string
- And more...

## Technical Implementation

This package uses:
- **flutter_inappwebview**: For creating a headless WebView
- **UAParser.js**: For parsing user agent information
- **Navigator APIs**: For collecting device information
- **Singleton Pattern**: For efficient memory usage

## Privacy Considerations

This package only collects information that is freely available through standard web APIs. No personal information or unique identifiers are collected without explicit user consent.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
