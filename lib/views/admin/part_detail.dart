import 'package:flutter/material.dart';
import '../../models/part.dart';

class PartDetailPage extends StatelessWidget {
  final String jobOrderId;
  final String itemId;
  final Part part;
  final String clientName;
  final String orderNumber;
  final String itemCode;

  const PartDetailPage({
    super.key,
    required this.jobOrderId,
    required this.itemId,
    required this.part,
    required this.clientName,
    required this.orderNumber,
    required this.itemCode,
  });

  Future<void> _printSticker(BuildContext context) async {
    // Placeholder: integrate your printing solution (e.g., pdf or direct print)
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Print Sticker'),
        content: Text(
          'Client: $clientName\nOrder: $orderNumber\nItem Code: $itemCode\nPart: ${part.description}\nSN: ${part.sn}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = [
      'Client: $clientName',
      'Order: $orderNumber',
      'Item Code: $itemCode',
      'Part: ${part.description}',
      'SN: ${part.sn}',
      'Created: ${part.createdAt}',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Part Detail')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Part: ${part.description}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...info.map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(t),
                    )),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text('Print Sticker'),
                    onPressed: () => _printSticker(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
