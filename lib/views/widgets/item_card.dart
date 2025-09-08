import 'package:flutter/material.dart';
import '../../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onOpen;

  const ItemCard({
    super.key,
    required this.item,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      child: ListTile(
        leading: const Icon(Icons.widgets),
        title: Text('${item.code} — ${item.description}'),
        subtitle: Text('Qty: ${item.quantity}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpen,
      ),
    );
  }
}
