import 'package:flutter/material.dart';
import '../../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${item.code} — ${item.description}'),
        subtitle: Text('QTY: ${item.quantity} | SN: ${item.sn}'),
      ),
    );
  }
}
