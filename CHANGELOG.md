# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-06-24

### Added
- Initial release of Flutter Attribution Linker package
- Device fingerprinting using headless WebView
- Comprehensive device and browser information collection
- Singleton pattern for efficient memory usage
- Caching mechanism for fingerprint data
- Support for high entropy user agent data
- UAParser.js integration for user agent parsing
- Cross-platform support (iOS, Android)
- Example implementations with encryption
- Complete API documentation

### Features
- **Fingerprint Collection**: Collects 20+ device and browser attributes
- **WebView Integration**: Uses flutter_inappwebview for data collection
- **Privacy-Aware**: Only uses standard web APIs
- **Caching**: Fingerprint data is cached after first collection
- **Error Handling**: Comprehensive error handling and timeouts

### Technical Details
- Uses UAParser.js (v1.0.2) for user agent parsing
- Implements JavaScript fingerprinting functions
- Supports both light and dark system themes
- Collects screen resolution, CPU cores, memory info
- Detects operating system and browser details
- Provides timezone and language information

### Examples
- Basic fingerprint collection example
- Advanced encryption and server submission example
- Web browser fingerprint collection (HTML/JS)
- Attribution service implementation

### Dependencies
- flutter_inappwebview: ^6.1.5
- Standard Flutter SDK dependencies
