import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class UsersListPage extends StatelessWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final users =
        FirebaseFirestore.instance.collection('users').orderBy('email');
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: users.snapshots(),
        builder: (_, s) {
          if (!s.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = s.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No users'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final active = d['active'] as bool? ?? false;
              return SwitchListTile(
                title: Text(d['email'] ?? ''),
                subtitle: Text('Role: ${d['role'] ?? ''}'),
                value: active,
                onChanged: (val) {
                  FirestoreService.instance.setUserActive(d.id, val);
                },
              );
            },
          );
        },
      ),
    );
  }
}
