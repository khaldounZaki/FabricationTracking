import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/auth/login_page.dart';
import 'views/admin/job_orders_list.dart';

class FabricationApp extends StatelessWidget {
  const FabricationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fabrication Tracking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show splash while checking auth
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            // User is logged in → go to admin page (JobOrdersListPage)
            return const JobOrdersListPage();
          } else {
            // No user → show login
            return const LoginPage();
          }
        },
      ),
    );
  }
}
