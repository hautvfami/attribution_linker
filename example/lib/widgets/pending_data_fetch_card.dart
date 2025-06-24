import 'package:flutter/material.dart';

class PendingDataFetchCard extends StatelessWidget {
  final bool isFetching;
  final VoidCallback onFetchPendingData;

  const PendingDataFetchCard({
    super.key,
    required this.isFetching,
    required this.onFetchPendingData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_download,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Fetch Pending Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get attribution data from server',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isFetching ? null : onFetchPendingData,
              icon: isFetching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(isFetching ? 'Fetching...' : 'Fetch Data'),
            ),
          ],
        ),
      ),
    );
  }
}
