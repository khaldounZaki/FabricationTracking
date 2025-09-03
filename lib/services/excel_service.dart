import 'dart:io';
import 'package:excel/excel.dart';

class ExcelService {
  /// Expected columns: Code | Description | Quantity
  /// Returns a list of maps: {code, description, quantity}
  List<Map<String, dynamic>> parseItemsExcel(File file) {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final out = <Map<String, dynamic>>[];

    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table]!;
      if (sheet.maxRows <= 1) continue; // skip header only
      // Assume first row is header
      for (var r = 1; r < sheet.maxRows; r++) {
        final row = sheet.row(r);
        if (row.isEmpty) continue;
        final code = row[0]?.value?.toString().trim() ?? '';
        final desc = row[1]?.value?.toString().trim() ?? '';
        final qtyStr = row[2]?.value?.toString().trim() ?? '0';
        final qty = int.tryParse(qtyStr) ?? 0;
        if (code.isEmpty) continue;
        out.add({'code': code, 'description': desc, 'quantity': qty});
      }
    }
    return out;
  }
}
