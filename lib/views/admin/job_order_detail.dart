import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/job_order_controller.dart';
import '../../models/job_order.dart';
import '../../models/item.dart';
import '../widgets/item_card.dart';

class JobOrderDetailPage extends StatelessWidget {
  const JobOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final jo = ModalRoute.of(context)!.settings.arguments as JobOrder?;
    if (jo == null) {
      return const Scaffold(body: Center(child: Text('No job order provided')));
    }
    return ChangeNotifierProvider(
      create: (_) => JobOrderController(),
      child: Scaffold(
        appBar: AppBar(title: Text('Order ${jo.orderNumber}')),
        body: Consumer<JobOrderController>(
          builder: (context, ctrl, _) => StreamBuilder<List<Item>>(
            stream: ctrl.watchItems(jo.id),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snap.data ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('No items yet'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (_, i) => ItemCard(item: items[i]),
              );
            },
          ),
        ),
      ),
    );
  }
}
