import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // ✅ printer share
  //static const String _printerShare = r'\\192.168.0.101\BigSticker';

  Future<void> _printSticker(BuildContext context) async {
    try {
      if (!Platform.isWindows) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Printing is configured for Windows only.')),
          );
        }
        return;
      }

      // ZPL for 10x5 cm (800 x 400 dots at 203 dpi)
      final zpl = """
^XA
^PW800
^LL400
^CI28
^LH0,0

/* ---- TOP SECTION (extra top padding) ---- */
^CF0,48
^FO35,75^FD$clientName^FS

^CF0,40
^FO35,130^FDOrder:^FS
^FO150,130^FD$orderNumber^FS

^FO35,170^FDItem:^FS
^FO150,170^FD$itemCode^FS

/* ---- PART + QTY (same block) ---- */
^CF0,35
^FO35,230^FDPart:^FS

/* Part description + Qty inline */
^FO150,230^FB420,3,0,L,0^FD${part.description} (P.Q. : ${part.qty})^FS

/* ---- QR CODE ---- */
^FO560,65^BQN,2,9
^FDQA,${part.sn}^FS

/* ---- SN printed below QR (no label text) ---- */
^CF0,24
^FO560,280^FB200,2,0,C,0^FD${part.sn}^FS

/* Print copies */
^PQ${part.qty},0,1,N
^XZ
""";

      // Save ZPL to file
      final file = File('label.zpl');
      await file.writeAsString(zpl);

      // ✅ Most reliable Windows command (quotes + /D:)
      //final cmd = 'print /D:"$_printerShare" "${file.path}"';

      final result = await Process.run(
        'cmd',
        [
          '/C',
          r'print /d:\\192.168.0.101\BigSticker label.zpl',
        ],
      );

      final ok = (result.exitCode == 0);
      final stderr = (result.stderr ?? '').toString().trim();
      final stdout = (result.stdout ?? '').toString().trim();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok
                  ? 'Sticker sent to printer.'
                  : 'Print failed: ${stderr.isNotEmpty ? stderr : stdout}',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during printing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Part Detail'),
        actions: [
          IconButton(
            tooltip: 'Copy SN',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: part.sn));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SN copied.')),
              );
            },
            icon: const Icon(Icons.copy),
          ),
          IconButton(
            tooltip: 'Print',
            onPressed: () => _printSticker(context),
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part.description,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _InfoPill(label: 'Client', value: clientName),
                          _InfoPill(label: 'Order', value: orderNumber),
                          _InfoPill(label: 'Item', value: itemCode),
                          _InfoPill(label: 'Qty', value: part.qty.toString()),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Divider(color: Theme.of(context).dividerColor),
                      const SizedBox(height: 18),
                      Text('Serial Number',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: SelectableText(
                          part.sn,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('Created',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(part.createdAt.toString()),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _printSticker(context),
                              icon: const Icon(Icons.print),
                              label: const Text('Print sticker'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 8),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
