import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  Widget _tile(
      BuildContext context, String title, String route, IconData icon) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _tile(context, 'Job Orders', Routes.jobOrdersList, Icons.work_outline),
      _tile(
          context, 'Add Job Order', Routes.addJobOrder, Icons.add_box_outlined),
      _tile(context, 'Add Items', Routes.addItems, Icons.playlist_add),
      _tile(context, 'Import Items (Excel)', Routes.importItemsExcel,
          Icons.table_view),
      _tile(context, 'Add Parts', Routes.addParts, Icons.build_outlined),
      _tile(
          context, 'Print Sticker', Routes.printSticker, Icons.print_outlined),
      _tile(context, 'Users', Routes.usersList, Icons.people_alt_outlined),
      _tile(context, 'Reports', Routes.reports, Icons.bar_chart_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: tiles,
      ),
    );
  }
}
