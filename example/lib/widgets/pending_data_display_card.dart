import 'package:flutter/material.dart';

class PendingDataDisplayCard extends StatelessWidget {
  final Map<String, dynamic> pendingData;

  const PendingDataDisplayCard({
    super.key,
    required this.pendingData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pending_actions, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Pending Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${pendingData.length} properties',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                itemCount: pendingData.entries.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = pendingData.entries.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.value?.toString() ?? 'null',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
