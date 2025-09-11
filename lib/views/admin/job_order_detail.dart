import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../../services/firestore_service.dart';
import '../../models/item.dart';
import '../widgets/item_card.dart';
import 'add_item.dart';
import 'item_detail.dart';

import 'dart:io';
import 'dart:typed_data';

class JobOrderDetailPage extends StatefulWidget {
  final String jobOrderId;
  final String orderNumber;
  final String clientName;
  final DateTime deliveryDate;

  const JobOrderDetailPage({
    super.key,
    required this.jobOrderId,
    required this.orderNumber,
    required this.clientName,
    required this.deliveryDate,
  });

  @override
  State<JobOrderDetailPage> createState() => _JobOrderDetailPageState();
}

class _JobOrderDetailPageState extends State<JobOrderDetailPage> {
  final _db = FirestoreService();

  Future<void> _importFromExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result == null) return;

      Uint8List? fileBytes = result.files.single.bytes;
      String? filePath = result.files.single.path;

      if (fileBytes == null && filePath != null) {
        fileBytes = await File(filePath).readAsBytes();
      }

      if (fileBytes == null) {
        throw Exception("Unable to read Excel file bytes.");
      }

      final excel = Excel.decodeBytes(fileBytes);
      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]!.rows;

      int addedCount = 0;
      for (var row in rows.skip(1)) {
        final code = row[0]?.value.toString() ?? '';
        final description = row[1]?.value.toString() ?? '';
        final quantityStr = row[2]?.value.toString() ?? '0';
        final quantity = int.tryParse(quantityStr) ?? 0;

        if (code.isEmpty) continue;

        final item = Item(
          id: '',
          code: code,
          description: description,
          quantity: quantity,
        );

        await _db.addItem(widget.jobOrderId, item);
        addedCount++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Imported $addedCount items from Excel")),
      );
    } catch (e) {
      debugPrint("Excel import error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to import from Excel")),
      );
    }
  }

  Widget _buildScannedUsers(String jobOrderId, String itemId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _db.getScansForItem(jobOrderId, itemId),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final scans = snap.data!;
        return Wrap(
          spacing: 6,
          children: scans.map((s) {
            return Tooltip(
              message:
                  "${s['name']} (${s['role']})\n${s['date']}", // short info
              child: CircleAvatar(
                radius: 14,
                backgroundImage: s['photoUrl'] != null && s['photoUrl'] != ''
                    ? NetworkImage(s['photoUrl'])
                    : null,
                child: s['photoUrl'] == null || s['photoUrl'] == ''
                    ? Text(
                        s['name'] != null && s['name'].isNotEmpty
                            ? s['name'][0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${widget.orderNumber} — ${widget.clientName}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Delivery: ${widget.deliveryDate.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Item>>(
        stream: _db.getItems(widget.jobOrderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text('No items yet. Use + or Import Excel to add.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final it = items[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  title: Text("${it.code} — ${it.description}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Qty: ${it.quantity}"),
                      const SizedBox(height: 4),
                      _buildScannedUsers(widget.jobOrderId, it.id),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailPage(
                          jobOrderId: widget.jobOrderId,
                          orderNumber: widget.orderNumber,
                          clientName: widget.clientName,
                          itemId: it.id,
                          itemCode: it.code,
                          itemDescription: it.description,
                          quantity: it.quantity,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'importExcel',
            icon: const Icon(Icons.upload_file),
            label: const Text('Import Excel'),
            onPressed: _importFromExcel,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'addItem',
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddItemPage(jobOrderId: widget.jobOrderId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
