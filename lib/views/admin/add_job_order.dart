import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/job_order_controller.dart';
import '../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class AddJobOrderPage extends StatefulWidget {
  const AddJobOrderPage({super.key});

  @override
  State<AddJobOrderPage> createState() => _AddJobOrderPageState();
}

class _AddJobOrderPageState extends State<AddJobOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _orderNumber = TextEditingController();
  final _clientName = TextEditingController();
  DateTime? _deliveryDate;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobOrderController(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Job Order')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomTextField(
                controller: _orderNumber,
                label: 'Order Number',
                validator: Validators.requiredText,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _clientName,
                label: 'Client Name',
                validator: Validators.requiredText,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Delivery Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _deliveryDate == null
                            ? 'Select date'
                            : DateFormat.yMMMd().format(_deliveryDate!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: now.subtract(const Duration(days: 365)),
                        lastDate: now.add(const Duration(days: 365 * 5)),
                        initialDate: now,
                      );
                      if (picked != null)
                        setState(() => _deliveryDate = picked);
                    },
                    child: const Text('Pick'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<JobOrderController>(
                builder: (context, ctrl, _) => FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    if (_deliveryDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please pick a delivery date')),
                      );
                      return;
                    }
                    await ctrl.addJobOrder(
                      orderNumber: _orderNumber.text.trim(),
                      clientName: _clientName.text.trim(),
                      deliveryDate: _deliveryDate!,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Job order saved')),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
