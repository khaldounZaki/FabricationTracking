import 'dart:io';
import 'package:flutter/material.dart';

import '../../models/part.dart';
import '../../services/firestore_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AddPartPage extends StatefulWidget {
  final String jobOrderId;
  final String orderNumber;
  final String itemId;
  final String itemCode;

  // ✅ NEW: client name so we can print it on the sticker
  final String clientName;

  const AddPartPage({
    super.key,
    required this.jobOrderId,
    required this.orderNumber,
    required this.itemId,
    required this.itemCode,
    required this.clientName,
  });

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  bool _saving = false;

  final _db = FirestoreService();

  // ✅ Put your printer share here (Windows shared printer)
  //static const String _printerShare = r'\\192.168.0.45\BigSticker';

  String _computeSN() {
    // Simple rule: orderNumber-itemCode-1
    // Later: can become auto-increment or unique per piece.
    return '${widget.orderNumber}-${widget.itemCode}-1';
  }

  Future<(bool, String)> _windowsPrintZpl(String zpl) async {
    if (!Platform.isWindows) {
      return (false, 'Printing is configured for Windows only.');
    }

    try {
      // Write to a temp file (reliable)
      //final dir = await Directory.systemTemp.createTemp('fab_label_');
      final file = File('label.zpl');
      await file.writeAsString(zpl);
      print(zpl);

      // Most reliable: /D:"\\server\share" "full_path_to_file"
      //final cmd = 'print /d:"$_printerShare" "${file.path}"';

      final result = await Process.run(
        'cmd',
        [
          '/C',
          r'print /d:\\192.168.0.101\BigSticker label.zpl',
        ],
      );

      final ok = result.exitCode == 0;
      final stderr = (result.stderr ?? '').toString().trim();
      final stdout = (result.stdout ?? '').toString().trim();

      if (ok) return (true, 'Sticker sent to printer.');
      return (false, 'Print failed: ${stderr.isNotEmpty ? stderr : stdout}');
    } catch (e) {
      return (false, 'Error during printing: $e');
    }
  }

  Future<bool> _printSticker(BuildContext context, Part part) async {
    // ZPL for 10x5 cm (800 x 400 dots at 203 dpi)
    final zpl = """
^XA
^PW800
^LL400
^CI28
^LH0,0



/* ---- TOP SECTION (extra top padding) ---- */
^CF0,48
^FO35,75^FD${widget.clientName}^FS

^CF0,40
^FO35,130^FDOrder:^FS
^FO150,130^FD${widget.orderNumber}^FS

^FO35,170^FDItem:^FS
^FO150,170^FD${widget.itemCode}^FS

/* ---- PART + QTY (same block) ---- */
^CF0,35
^FO35,230^FDPart:^FS

/* Part description (wraps safely) */
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

    print(zpl);

    final (ok, msg) = await _windowsPrintZpl(zpl);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }

    return ok;
  }

  Future<void> _saveAndPrint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;

      final part = Part(
        id: '',
        itemId: widget.itemId,
        description: _descCtrl.text.trim(),
        sn: _computeSN(),
        qty: qty,
        createdAt: DateTime.now(),
      );

      await _db.addPart(widget.jobOrderId, widget.itemId, part);

      final printed = await _printSticker(context, part);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              printed ? 'Part added & printed' : 'Part added (print failed)',
            ),
          ),
        );

        // Close only if print succeeded (your preference)
        if (printed) {
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sn = _computeSN();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Part'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sticker Info',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _InfoChip(
                                label: 'Client', value: widget.clientName),
                            _InfoChip(
                                label: 'Order', value: widget.orderNumber),
                            _InfoChip(label: 'Item', value: widget.itemCode),
                            _InfoChip(label: 'SN', value: sn),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Divider(color: Theme.of(context).dividerColor),
                        const SizedBox(height: 18),
                        Text(
                          'Part Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _descCtrl,
                          label: 'Part description',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _qtyCtrl,
                                label: 'Qty',
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  final t = (v ?? '').trim();
                                  final n = int.tryParse(t);
                                  if (n == null || n < 1) {
                                    return 'Enter a valid qty (>= 1)';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            _QtyStepper(
                              qtyCtrl: _qtyCtrl,
                              onChanged: () => setState(() {}),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: _saving ? 'Saving...' : 'Save & Print',
                            onPressed: _saving ? null : _saveAndPrint,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tip: Qty prints multiple copies using Zebra ^PQ.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
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

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final TextEditingController qtyCtrl;
  final VoidCallback onChanged;

  const _QtyStepper({
    required this.qtyCtrl,
    required this.onChanged,
  });

  int _qty() => int.tryParse(qtyCtrl.text.trim()) ?? 1;

  void _set(int v) {
    final safe = v < 1 ? 1 : v;
    qtyCtrl.text = safe.toString();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Decrease',
          onPressed: () => _set(_qty() - 1),
          icon: const Icon(Icons.remove_circle_outline),
        ),
        IconButton(
          tooltip: 'Increase',
          onPressed: () => _set(_qty() + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
