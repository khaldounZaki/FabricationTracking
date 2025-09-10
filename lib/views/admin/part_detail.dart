import 'dart:io';
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
    try {
      // ZPL for 10x5 cm (800 x 400 dots at 203 dpi)
      final zpl = """
^XA
^PW800
^LL400
^CF0,40

^FO40,40^FDClient: $clientName^FS
^FO40,90^FDOrder: $orderNumber^FS
^FO40,140^FDItem: $itemCode^FS
^FO40,190^FDPart: ${part.description}^FS
^FO500,25^BQN,2,10
^FDQA,${part.sn}^FS
^XZ
""";

      // Save ZPL to file
      final file = File('label.zpl');
      await file.writeAsString(zpl);

      // Send to Zebra printer
      await Process.run(
        'cmd',
        [
          '/C',
          r'print /d:\\192.168.0.45\BigSticker label.zpl',
        ],
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sticker sent to printer.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error during printing.')),
        );
      }
    }
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
                Text(
                  'Part: ${part.description}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
