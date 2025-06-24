import 'package:flutter_test/flutter_test.dart';

import 'package:attribution_linker/attribution_linker.dart';

void main() {
  group('AttributionLinker', () {
    test('should be singleton', () {
      final instance1 = AttributionLinker();
      final instance2 = AttributionLinker();

      expect(instance1, same(instance2));
    });

    test('should initialize without errors', () {
      final linker = AttributionLinker();
      expect(() => linker.init(), returnsNormally);
    });

    // Note: fingerprint test would require a more complex setup with mocked WebView
    // This is just a basic structure test
  });
}
