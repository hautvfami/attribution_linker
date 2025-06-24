library attribution_linker;

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// A Flutter package for creating device fingerprints using WebView.
class AttributionLinker {
  /// Singleton instance of AttributionLinker.
  static final AttributionLinker inst = AttributionLinker._internal();
  factory AttributionLinker() => inst;
  AttributionLinker._internal();

  Map<String, dynamic>? _fingerprint;
  String? customScript;
  String? entryPoint;
  Map<String, dynamic> options = {};

  Map<String, dynamic> pendingData = {};

  Future<void> init({
    String? customScript,
    String? entryPoint,
    Map<String, dynamic> options = const {},
  }) async {
    this.customScript = customScript;
    await fingerprint; // Preload fingerprint
    this.entryPoint = entryPoint;
    this.options = options;
  }

  Future<void> fetchPendingData({
    String? customScript,
    String? entryPoint,
    Map<String, dynamic>? options,
  }) async {
    this.customScript = customScript ?? this.customScript;
    this.entryPoint = entryPoint ?? this.entryPoint;
    this.options = options ?? this.options;

    // TODO fetch pending data from server by post request fingerprint
  }  

  /// Gets the device fingerprint. If already cached, returns immediately.
  /// Otherwise, creates a headless WebView to collect fingerprint data.
  Future<Map<String, dynamic>> get fingerprint async {
    // Return cached fingerprint if available
    if (_fingerprint != null) return _fingerprint!;

    // Create headless WebView to collect fingerprint
    _fingerprint = await _collectFingerprint();
    return _fingerprint!;
  }

  /// Collects fingerprint data using a headless WebView.
  Future<Map<String, dynamic>> _collectFingerprint() async {
    HeadlessInAppWebView? headlessWebView;

    try {
      // Load UAParser.js from assets
      final String uaParserJs = await rootBundle
          .loadString('packages/attribution_linker/assets/ua-parser.min.js');

      // Load fingerprint script - use custom script if provided, otherwise use default
      String fingerprintScript;
      if (customScript != null && customScript!.isNotEmpty) {
        fingerprintScript = customScript!;
      } else {
        fingerprintScript = await rootBundle
            .loadString('packages/attribution_linker/assets/fingerprint.js');
      }

      // Combine UAParser with fingerprint script
      final String combinedScript = '''
        $uaParserJs
        
        $fingerprintScript
      ''';

      Map<String, dynamic>? result;

      headlessWebView = HeadlessInAppWebView(
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          useShouldOverrideUrlLoading: false,
        ),
        onWebViewCreated: (controller) {
          // Add handler for fingerprint result
          controller.addJavaScriptHandler(
            handlerName: 'fingerprintResult',
            callback: (args) {
              final String jsonResult = args[0];
              result = json.decode(jsonResult);
            },
          );

          // Add handler for fingerprint error
          controller.addJavaScriptHandler(
            handlerName: 'fingerprintError',
            callback: (args) {
              throw Exception('Fingerprint collection failed: \${args[0]}');
            },
          );
        },
        onLoadStop: (controller, url) async {
          // Execute fingerprint collection script
          await controller.evaluateJavascript(source: combinedScript);
        },
      );

      await headlessWebView.run();

      // Load a minimal HTML page to trigger the webview
      await headlessWebView.webViewController?.loadData(
        data: '<html><head></head><body></body></html>',
        mimeType: 'text/html',
      );

      // Wait for result with timeout
      int attempts = 0;
      while (result == null && attempts < 50) {
        // 5 second timeout
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (result == null) {
        throw Exception('Timeout waiting for fingerprint collection');
      }

      return result!;
    } catch (e) {
      throw Exception('Failed to collect fingerprint: \$e');
    } finally {
      await headlessWebView?.dispose();
    }
  }
}
