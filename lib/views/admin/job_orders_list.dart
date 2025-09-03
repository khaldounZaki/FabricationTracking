import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/job_order_controller.dart';
import '../../models/job_order.dart';
import '../widgets/job_order_card.dart';
import '../../utils/constants.dart';

class JobOrdersListPage extends StatelessWidget {
  const JobOrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobOrderController(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Job Orders')),
        body: Consumer<JobOrderController>(
          builder: (context, ctrl, _) => StreamBuilder<List<JobOrder>>(
            stream: ctrl.watchJobOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return const Center(child: Text('No job orders'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: data.length,
                itemBuilder: (_, i) {
                  final jo = data[i];
                  return JobOrderCard(
                    jobOrder: jo,
                    onOpen: () => Navigator.pushNamed(
                      context,
                      Routes.jobOrderDetail,
                      arguments: jo,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
