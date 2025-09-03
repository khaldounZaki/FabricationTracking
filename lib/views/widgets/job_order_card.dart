import 'package:flutter/material.dart';
import '../../models/job_order.dart';
import 'package:intl/intl.dart';

class JobOrderCard extends StatelessWidget {
  final JobOrder jobOrder;
  final VoidCallback onOpen;

  const JobOrderCard({super.key, required this.jobOrder, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${jobOrder.orderNumber} — ${jobOrder.clientName}'),
        subtitle: Text(
          'Delivery: ${DateFormat.yMMMd().format(jobOrder.deliveryDate)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: onOpen,
        ),
      ),
    );
  }
}
