import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class AddPartsPage extends StatefulWidget {
  const AddPartsPage({super.key});

  @override
  State<AddPartsPage> createState() => _AddPartsPageState();
}

class _AddPartsPageState extends State<AddPartsPage> {
  final _orderNumber = TextEditingController();
  final _itemCode = TextEditingController();
  final _partDescription = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Parts (Part Cutting Order)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomTextField(
              controller: _orderNumber,
              label: 'Order Number',
              validator: Validators.requiredText),
          const SizedBox(height: 12),
          CustomTextField(
              controller: _itemCode,
              label: 'Item Code',
              validator: Validators.requiredText),
          const SizedBox(height: 12),
          CustomTextField(
              controller: _partDescription,
              label: 'Part Description',
              validator: Validators.requiredText),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Add Part'),
            onPressed: () async {
              final orderId = _orderNumber.text.trim();
              final itemId = _itemCode.text.trim();
              final sn = '$orderId-$itemId';
              await FirestoreService.instance
                  .addPart(orderId, itemId, _partDescription.text.trim(), sn);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Part added')),
                );
                _partDescription.clear();
              }
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Text('Recent Parts (last 10)'),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('jobOrders')
                .doc(_orderNumber.text.isEmpty ? '_' : _orderNumber.text)
                .collection('items')
                .doc(_itemCode.text.isEmpty ? '_' : _itemCode.text)
                .collection('parts')
                .orderBy('createdAt', descending: true)
                .limit(10)
                .snapshots(),
            builder: (_, s) {
              if (!s.hasData) return const SizedBox();
              final docs = s.data!.docs;
              return Column(
                children: docs
                    .map((d) => ListTile(
                          title: Text(d['description'] ?? ''),
                          subtitle: Text('SN: ${d['stickerSN'] ?? ''}'),
                        ))
                    .toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
