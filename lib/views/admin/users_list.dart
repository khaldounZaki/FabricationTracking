import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../services/firestore_service.dart';
import '../../models/user.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _db = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: StreamBuilder<List<AppUser>>(
        stream: _db.getUsers(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snap.data ?? [];
          if (users.isEmpty) return const Center(child: Text('No users.'));

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Active')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: users.map((u) {
                  final avatar = u.photoUrl.isNotEmpty
                      ? CircleAvatar(backgroundImage: NetworkImage(u.photoUrl))
                      : CircleAvatar(
                          child: Text(
                            (u.name.isNotEmpty
                                    ? u.name[0]
                                    : (u.email.isNotEmpty ? u.email[0] : '?'))
                                .toUpperCase(),
                          ),
                        );

                  return DataRow(cells: [
                    DataCell(Row(children: [
                      avatar,
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.name.isNotEmpty ? u.name : '(no name)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(u.phone.isNotEmpty ? u.phone : '',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      )
                    ])),
                    DataCell(Text(u.email)),
                    DataCell(Text(u.role)),
                    DataCell(Icon(
                      u.isActive ? Icons.check_circle : Icons.remove_circle,
                      color: u.isActive ? Colors.green : Colors.red,
                    )),
                    DataCell(Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            await _db.updateUserStatus(u.uid, !u.isActive);
                          },
                          child: Text(u.isActive ? 'Block' : 'Activate'),
                        ),
                        TextButton(
                          onPressed: () =>
                              _showUserDialog(context, _db, user: u),
                          child: const Text("Edit"),
                        ),
                        TextButton(
                          onPressed: () =>
                              _showReportDialog(context, _db, user: u),
                          child: const Text("Report"),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 📄 Show Report Options (Date range + type)
  void _showReportDialog(BuildContext context, FirestoreService db,
      {required AppUser user}) async {
    DateTimeRange? pickedRange;
    String reportType = "pdf";

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Generate Report for ${user.name}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final firstDate = DateTime(now.year - 1);
                    final lastDate = DateTime(now.year + 1);
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: firstDate,
                      lastDate: lastDate,
                      initialDateRange: pickedRange ??
                          DateTimeRange(
                              start: now.subtract(const Duration(days: 30)),
                              end: now),
                    );
                    if (range != null) {
                      setState(() => pickedRange = range);
                    }
                  },
                  child: Text(pickedRange == null
                      ? "Select Date Range"
                      : "${pickedRange!.start.toLocal()} → ${pickedRange!.end.toLocal()}"),
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: reportType,
                  items: const [
                    DropdownMenuItem(value: "pdf", child: Text("PDF")),
                    DropdownMenuItem(value: "excel", child: Text("Excel")),
                  ],
                  onChanged: (val) => setState(() => reportType = val!),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                onPressed: pickedRange == null
                    ? null
                    : () async {
                        Navigator.pop(context);
                        await _generateReport(context, db,
                            user: user, range: pickedRange!, type: reportType);
                      },
                child: const Text("Generate"),
              ),
            ],
          );
        });
      },
    );
  }

  /// 📄 Generate Report (PDF or Excel)
  Future<void> _generateReport(BuildContext context, FirestoreService db,
      {required AppUser user,
      required DateTimeRange range,
      required String type}) async {
    final logs = await db.getUserScanLogs(user.uid);

    final filteredLogs = logs.where((log) {
      final date = DateTime.tryParse(log["timestamp"].toString());
      if (date == null) return false;
      return date.isAfter(range.start) && date.isBefore(range.end);
    }).toList();

    if (filteredLogs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No scan logs in this date range.")),
        );
      }
      return;
    }

    // Pick save folder
    final outputDir = await FilePicker.platform.getDirectoryPath();

    if (outputDir == null) return;

    final fileName =
        "${user.name}_report_${range.start.toString().split(' ').first}_${range.end.toString().split(' ').first}";

    if (type == "excel") {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Report'];
      sheet.appendRow([
        TextCellValue("Job Order Number"),
        TextCellValue("Client Name"),
        TextCellValue("Item Code"),
        TextCellValue("Item Description"),
        TextCellValue("SN"),
        TextCellValue("Reason"),
        TextCellValue("Date of Scan"),
      ]);

      for (var log in filteredLogs) {
        sheet.appendRow([
          TextCellValue(log["jobOrderNumber"] ?? ""),
          TextCellValue(log["clientName"] ?? ""),
          TextCellValue(log["itemCode"] ?? ""),
          TextCellValue(log["itemDescription"] ?? ""),
          TextCellValue(log["sn"] ?? ""),
          TextCellValue(log["reason"] ?? ""),
          TextCellValue(log["timestamp"].toString()),
        ]);
      }

      final file = File("$outputDir/$fileName.xlsx")
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Excel saved to ${file.path}")),
        );
      }
    } else {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context ctx) => [
            pw.Header(
              level: 0,
              child: pw.Text("Scan Report",
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Text("User: ${user.name} (${user.email})"),
            pw.Text("Role: ${user.role}"),
            pw.Text("Date range: ${range.start} → ${range.end}"),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                "Job Order Number",
                "Client Name",
                "Item Code",
                "Item Description",
                "SN",
                "Reason",
                "Date of Scan"
              ],
              data: filteredLogs.map((log) {
                return [
                  log["jobOrderNumber"],
                  log["clientName"],
                  log["itemCode"],
                  log["itemDescription"],
                  log["sn"],
                  log["reason"],
                  log["timestamp"].toString(),
                ];
              }).toList(),
            )
          ],
        ),
      );

      final file = File("$outputDir/$fileName.pdf")
        ..writeAsBytesSync(await pdf.save());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF saved to ${file.path}")),
        );
      }
    }
  }

  /// Show Add/Edit dialog (unchanged)
  void _showUserDialog(BuildContext context, FirestoreService db,
      {AppUser? user}) {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final photoCtrl = TextEditingController(text: user?.photoUrl ?? '');
    String role = user?.role ?? "Welder";
    bool isActive = user?.isActive ?? true;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(user == null ? "Add User" : "Edit User"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                  enabled: user == null,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: photoCtrl,
                  decoration: const InputDecoration(labelText: "Photo URL"),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(
                        value: "Assembler", child: Text("Assembler")),
                    DropdownMenuItem(value: "Welder", child: Text("Welder")),
                    DropdownMenuItem(
                        value: "Polisher", child: Text("Polisher")),
                    DropdownMenuItem(
                        value: "Quality Checker",
                        child: Text("Quality Checker")),
                    DropdownMenuItem(
                        value: "Installer", child: Text("Installer")),
                    DropdownMenuItem(value: "", child: Text("")),
                  ],
                  onChanged: (val) => role = val ?? role,
                  decoration: const InputDecoration(labelText: "Role"),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Active:'),
                    const SizedBox(width: 8),
                    Switch(
                        value: isActive,
                        onChanged: (v) {
                          isActive = v;
                        }),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (user == null) {
                  await db.addUser(
                    email: emailCtrl.text.trim(),
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    photoUrl: photoCtrl.text.trim(),
                    role: role,
                    isActive: isActive,
                  );
                } else {
                  await db.updateUserInfo(
                    uid: user.uid,
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    photoUrl: photoCtrl.text.trim(),
                    role: role,
                  );
                  await db.updateUserStatus(user.uid, isActive);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
