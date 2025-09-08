import 'package:flutter/material.dart';
import '../../models/job_order.dart';
import 'package:intl/intl.dart';

class JobOrderCard extends StatelessWidget {
  final JobOrder order;
  final VoidCallback onOpen;

  const JobOrderCard({
    super.key,
    required this.order,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd();
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.inventory_2, size: 42),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.orderNumber,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(order.clientName),
                    Text('Delivery: ${df.format(order.deliveryDate)}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
