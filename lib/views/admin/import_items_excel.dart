import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/excel_service.dart';
import '../../controllers/job_order_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class ImportItemsExcelPage extends StatefulWidget {
  const ImportItemsExcelPage({super.key});

  @override
  State<ImportItemsExcelPage> createState() => _ImportItemsExcelPageState();
}

class _ImportItemsExcelPageState extends State<ImportItemsExcelPage> {
  final _orderNumber = TextEditingController();
  File? _file;
  List<Map<String, dynamic>> _rows = [];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobOrderController(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Import Items from Excel')),
        //   body: Padding(
        //     padding: const EdgeInsets.all(16),
        //     child: Column(
        //       children: [
        //         Form(
        //           child: CustomTextField(
        //             controller: _orderNumber,
        //             label: 'Order Number (existing)',
        //             validator: Validators.requiredText,
        //           ),
        //         ),
        //         const SizedBox(height: 12),
        //         Row(
        //           children: [
        //             CustomButton(
        //               label: 'Pick Excel File',
        //               onPressed: () async {
        //                 final result = await FilePicker.platform.pickFiles(
        //                   type: FileType.custom,
        //                   allowedExtensions: ['xlsx', 'xls'],
        //                 );
        //                 if (result != null && result.files.single.path != null) {
        //                   final file = File(result.files.single.path!);
        //                   final rows = ExcelService().parseItemsExcel(file);
        //                   setState(() {
        //                     _file = file;
        //                     _rows = rows;
        //                   });
        //                 }
        //               },
        //             ),
        //             const SizedBox(width: 12),
        //             Text(_file == null ? 'No file selected' : _file!.path),
        //           ],
        //         ),
        //         const SizedBox(height: 12),
        //         Expanded(
        //           child: _rows.isEmpty
        //               ? const Center(child: Text('No rows parsed'))
        //               : ListView.builder(
        //                   itemCount: _rows.length,
        //                   itemBuilder: (_, i) {
        //                     final r = _rows[i];
        //                     return ListTile(
        //                       title: Text('${r['code']} — ${r['description']}'),
        //                       trailing: Text('QTY: ${r['quantity']}'),
        //                     );
        //                   },
        //                 ),
        //         ),
        //         Consumer<JobOrderController>(
        //           builder: (context, ctrl, _) => FilledButton.icon(
        //             icon: const Icon(Icons.upload),
        //             label: const Text('Import'),
        //             onPressed: _rows.isEmpty || _orderNumber.text.isEmpty
        //                 ? null
        //                 : () async {
        //                     for (final r in _rows) {
        //                       await ctrl.addItem(
        //                         orderId: _orderNumber.text.trim(),
        //                         code: r['code'],
        //                         description: r['description'],
        //                         quantity: r['quantity'],
        //                       );
        //                     }
        //                     if (context.mounted) {
        //                       ScaffoldMessenger.of(context).showSnackBar(
        //                         const SnackBar(content: Text('Items imported')),
        //                       );
        //                     }
        //                   },
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
      ),
    );
  }
}
