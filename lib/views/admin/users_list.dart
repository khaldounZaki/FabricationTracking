import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

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
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Active')),
                DataColumn(label: Text('Actions')),
              ],
              rows: users.map((u) {
                return DataRow(cells: [
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
                    ],
                  )),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
