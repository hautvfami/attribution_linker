import 'package:flutter/material.dart';

class FingerprintHeaderCard extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCollectFingerprint;

  const FingerprintHeaderCard({
    super.key,
    required this.isLoading,
    required this.onCollectFingerprint,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.fingerprint,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Device Fingerprinting',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Collect unique device fingerprint data',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isLoading ? null : onCollectFingerprint,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(isLoading ? 'Collecting...' : 'Collect Fingerprint'),
            ),
          ],
        ),
      ),
    );
  }
}
