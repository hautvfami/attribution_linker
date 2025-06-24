import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

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

  group('Assets Update', () {
    // Define assets to download and update
    final assetsToUpdate = <String, String>{
      'ua-parser.min.js':
          'https://raw.githubusercontent.com/faisalman/ua-parser-js/refs/heads/master/dist/ua-parser.min.js',
      // Add more assets here as needed
      // 'other-asset.js': 'https://example.com/other-asset.js',
    };

    test('download and update assets from remote URLs', () async {
      // Get project root directory
      final currentDir = Directory.current;
      final projectRoot = _findProjectRoot(currentDir);
      final assetsDir = Directory(path.join(projectRoot.path, 'assets'));

      // Ensure assets directory exists
      if (!assetsDir.existsSync()) {
        assetsDir.createSync(recursive: true);
      }

      print('📁 Assets directory: ${assetsDir.path}');

      for (final entry in assetsToUpdate.entries) {
        final fileName = entry.key;
        final url = entry.value;
        final filePath = path.join(assetsDir.path, fileName);

        print('\n🔄 Updating $fileName...');
        print('📥 Downloading from: $url');

        try {
          // Download file from URL
          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            // Create backup of existing file if it exists
            final file = File(filePath);
            if (file.existsSync()) {
              final backupPath = '$filePath.backup';
              await file.copy(backupPath);
              print('💾 Created backup: $fileName.backup');
            }

            // Write new content to file
            await file.writeAsString(response.body);
            print('✅ Successfully updated: $fileName');
            print('📊 File size: ${_formatBytes(response.body.length)}');

            // Verify file was written correctly
            final writtenContent = await file.readAsString();
            expect(writtenContent, equals(response.body));

            // Show preview of content (first 100 characters)
            final preview = writtenContent.length > 100
                ? '${writtenContent.substring(0, 100)}...'
                : writtenContent;
            print('📄 Content preview: $preview');
          } else {
            fail(
                '❌ Failed to download $fileName. Status code: ${response.statusCode}');
          }
        } catch (e) {
          fail('❌ Error downloading $fileName: $e');
        }
      }

      print('\n🎉 All assets updated successfully!');
    }, timeout: const Timeout(Duration(minutes: 5)));

    test('verify assets exist and are not empty', () async {
      final currentDir = Directory.current;
      final projectRoot = _findProjectRoot(currentDir);
      final assetsDir = Directory(path.join(projectRoot.path, 'assets'));

      for (final fileName in assetsToUpdate.keys) {
        final filePath = path.join(assetsDir.path, fileName);
        final file = File(filePath);

        expect(file.existsSync(), isTrue,
            reason: 'Asset file $fileName should exist');

        final content = await file.readAsString();
        expect(content.isNotEmpty, isTrue,
            reason: 'Asset file $fileName should not be empty');

        print('✅ Verified: $fileName (${_formatBytes(content.length)})');
      }
    });
  });
}

/// Find the project root directory by looking for pubspec.yaml
Directory _findProjectRoot(Directory current) {
  while (!File(path.join(current.path, 'pubspec.yaml')).existsSync()) {
    final parent = current.parent;
    if (parent.path == current.path) {
      throw Exception('Could not find project root (pubspec.yaml not found)');
    }
    current = parent;
  }
  return current;
}

/// Format bytes to human readable string
String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
