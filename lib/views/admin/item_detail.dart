import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/part.dart';
import '../widgets/part_card.dart';
import 'add_part.dart';
import 'part_detail.dart';

class ItemDetailPage extends StatelessWidget {
  final String jobOrderId;
  final String orderNumber;
  final String clientName;
  final String itemId;
  final String itemCode;
  final String itemDescription;
  final int quantity;

  const ItemDetailPage({
    super.key,
    required this.jobOrderId,
    required this.orderNumber,
    required this.clientName,
    required this.itemId,
    required this.itemCode,
    required this.itemDescription,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final _db = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Item $itemCode — $itemDescription'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
                'Order: $orderNumber • Client: $clientName • Qty: $quantity',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ),
      body: StreamBuilder<List<Part>>(
        stream: _db.getParts(jobOrderId, itemId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final parts = snap.data ?? [];
          if (parts.isEmpty) {
            return const Center(child: Text('No parts added yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: parts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final p = parts[i];
              return PartCard(
                part: p,
                subtitleRight: 'SN: ${p.sn}',
                onOpen: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PartDetailPage(
                        jobOrderId: jobOrderId,
                        itemId: itemId,
                        part: p,
                        clientName: clientName,
                        orderNumber: orderNumber,
                        itemCode: itemCode,
                      ),
                    ),
                  );
                },
                onPrint: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PartDetailPage(
                        jobOrderId: jobOrderId,
                        itemId: itemId,
                        part: p,
                        clientName: clientName,
                        orderNumber: orderNumber,
                        itemCode: itemCode,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Part'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPartPage(
                jobOrderId: jobOrderId,
                orderNumber: orderNumber,
                itemId: itemId,
                itemCode: itemCode,
              ),
            ),
          );
        },
      ),
    );
  }
}
