import 'package:excel/excel.dart';
import '../models/item.dart';

class ExcelService {
  /// Parse items from Excel file (Import)
  List<Item> parseItems(List<int> bytes) {
    final excel = Excel.decodeBytes(bytes);
    final List<Item> items = [];

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) continue;

      for (var row in sheet.rows.skip(1)) {
        // Skip header row
        final code = row.isNotEmpty ? row[0]?.value.toString() ?? '' : '';
        final description =
            row.length > 1 ? row[1]?.value.toString() ?? '' : '';
        final quantityStr =
            row.length > 2 ? row[2]?.value.toString() ?? '0' : '0';

        items.add(
          Item(
            id: '',
            code: code,
            description: description,
            quantity: int.tryParse(quantityStr) ?? 0,
          ),
        );
      }
    }
    return items;
  }

  /// Export items to Excel (Optional)
  List<int> exportItems(List<Item> items) {
    final excel = Excel.createExcel();
    final sheet = excel['Items'];

    // Header row
    sheet.appendRow([
      TextCellValue('Code'),
      TextCellValue('Description'),
      TextCellValue('Quantity'),
    ]);

    for (var item in items) {
      sheet.appendRow([
        TextCellValue(item.code),
        TextCellValue(item.description),
        IntCellValue(item.quantity),
      ]);
    }

    return excel.encode()!;
  }
}
