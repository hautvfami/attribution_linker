library attribution_linker;

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// A Flutter package for creating device fingerprints using WebView.
class AttributionLinker {
  /// Singleton instance of AttributionLinker.
  static final AttributionLinker _instance = AttributionLinker._internal();
  factory AttributionLinker() {
    return _instance;
  }
  AttributionLinker._internal();

  Map<String, dynamic>? _fingerprint;

  void init() {
    // Initialization logic can be added here if needed.
  }

  /// Gets the device fingerprint. If already cached, returns immediately.
  /// Otherwise, creates a headless WebView to collect fingerprint data.
  Future<Map<String, dynamic>> get fingerprint async {
    // Return cached fingerprint if available
    if (_fingerprint != null) {
      return _fingerprint!;
    }

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

      // JavaScript code to collect fingerprint
      final String fingerprintJs = '''
        $uaParserJs
        
        async function parseFingerprintInfo() {
          const ua = navigator.userAgent || '';
          const uaData = navigator.userAgentData;

          // 🧠 Ưu tiên entropy cao nếu có hỗ trợ
          const highEntropy = uaData?.getHighEntropyValues
            ? await uaData.getHighEntropyValues([
                "platform", "platformVersion", "architecture", "model", "uaFullVersion", "bitness", "fullVersionList"
              ])
            : null;

          // 📦 Dùng UAParser.js
          const parser = new UAParser(ua);
          const parsed = parser.getResult();

          // 📱 Phân loại hệ điều hành
          function detectOS() {
            const p = (highEntropy?.platform || parsed.os.name || '').toLowerCase();
            if (p.includes('android')) return 'android';
            if (p.includes('ios')) return 'ios';
            if (p.includes('ipad')) return 'ipados';
            if (p.includes('mac')) return 'macos';
            if (p.includes('win')) return 'windows';
            if (p.includes('linux')) return 'linux';
            return 'others';
          }

          const osType = detectOS();

          // 🌙 Phát hiện hệ thống sáng/tối
          const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
          const systemBrightness = prefersDark ? 'dark' : 'light';

          // ✅ Trải phẳng dữ liệu fingerprint
          const fingerprint = {
            os_type: osType,
            os_name: highEntropy?.platform || parsed.os.name || '',
            os_version: highEntropy?.platformVersion || parsed.os.version || '',
            browser_name: parsed.browser.name || '',
            browser_version: highEntropy?.uaFullVersion || parsed.browser.version || '',
            device_model: highEntropy?.model || parsed.device.model || '',
            device_type: parsed.device.type || '',
            device_arch: highEntropy?.architecture || '',
            device_bitness: highEntropy?.bitness || '',
            screen_res: `\${screen.width}x\${screen.height}`,
            pixel_ratio: window.devicePixelRatio || 1,
            timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || '',
            language: navigator.language || '',
            cpu_cores: navigator.hardwareConcurrency?.toString() || '',
            device_memory: navigator.deviceMemory?.toString() || '',
            system_brightness: systemBrightness,
            user_agent: ua,
            user_agent_data: uaData || null,
            user_agent_parsed: parsed,
            browser_full_version_list: highEntropy?.fullVersionList?.map(b => `\${b.brand}/\${b.version}`).join(', ') || ''
          };

          return fingerprint;
        }
        
        // Execute and return result
        parseFingerprintInfo().then(result => {
          window.flutter_inappwebview.callHandler('fingerprintResult', JSON.stringify(result));
        }).catch(error => {
          window.flutter_inappwebview.callHandler('fingerprintError', error.toString());
        });
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
          await controller.evaluateJavascript(source: fingerprintJs);
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
