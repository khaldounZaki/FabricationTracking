import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class PrintStickerPage extends StatefulWidget {
  const PrintStickerPage({super.key});

  @override
  State<PrintStickerPage> createState() => _PrintStickerPageState();
}

class _PrintStickerPageState extends State<PrintStickerPage> {
  final _client = TextEditingController();
  final _orderNumber = TextEditingController();
  final _itemCode = TextEditingController();
  final _part = TextEditingController();

  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();
    final sn = '${_orderNumber.text.trim()}-${_itemCode.text.trim()}';

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(_client.text.trim(),
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Order: ${_orderNumber.text.trim()}'),
                pw.Text('Item Code: ${_itemCode.text.trim()}'),
                pw.Text('Part: ${_part.text.trim()}'),
                pw.SizedBox(height: 10),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: sn,
                  width: 120,
                  height: 120,
                ),
                pw.SizedBox(height: 8),
                pw.Text('SN: $sn'),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Sticker')),
      // body: ListView(
      //   padding: const EdgeInsets.all(16),
      //   children: [
      //     CustomTextField(
      //         controller: _client,
      //         label: 'Client',
      //         validator: Validators.requiredText),
      //     const SizedBox(height: 12),
      //     CustomTextField(
      //         controller: _orderNumber,
      //         label: 'Order Number',
      //         validator: Validators.requiredText),
      //     const SizedBox(height: 12),
      //     CustomTextField(
      //         controller: _itemCode,
      //         label: 'Item Code',
      //         validator: Validators.requiredText),
      //     const SizedBox(height: 12),
      //     CustomTextField(
      //         controller: _part,
      //         label: 'Part',
      //         validator: Validators.requiredText),
      //     const SizedBox(height: 24),
      //     FilledButton.icon(
      //       icon: const Icon(Icons.print),
      //       label: const Text('Preview & Print'),
      //       onPressed: () async {
      //         await Printing.layoutPdf(onLayout: (_) => _buildPdf());
      //       },
      //     ),
      //   ],
      // ),
    );
  }
}
