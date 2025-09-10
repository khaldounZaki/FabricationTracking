// lib/views/admin/users_list.dart
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/user.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _db = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     tooltip: "Add User",
        //     onPressed: () => _showUserDialog(context, _db),
        //   ),
        // ],
      ),
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

  /// Show Add/Edit dialog
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
                  enabled:
                      user == null, // if editing, don't allow changing email
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
                    //DropdownMenuItem(value: "Admin", child: Text("Admin")),
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
                  // Create new user doc (admin created)
                  await db.addUser(
                    email: emailCtrl.text.trim(),
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    photoUrl: photoCtrl.text.trim(),
                    role: role,
                    isActive: isActive,
                  );
                } else {
                  // Update existing user
                  await db.updateUserInfo(
                    uid: user.uid,
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    photoUrl: photoCtrl.text.trim(),
                    role: role,
                  );
                  // Also ensure isActive synced
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
