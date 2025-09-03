import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/job_order_controller.dart';
import '../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class AddItemsPage extends StatefulWidget {
  const AddItemsPage({super.key});

  @override
  State<AddItemsPage> createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  final _formKey = GlobalKey<FormState>();
  final _orderNumber = TextEditingController();
  final _code = TextEditingController();
  final _description = TextEditingController();
  final _qty = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobOrderController(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Items to Job Order')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomTextField(
                controller: _orderNumber,
                label: 'Order Number (existing)',
                validator: Validators.requiredText,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _code,
                label: 'Item Code',
                validator: Validators.requiredText,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _description,
                label: 'Description',
                validator: Validators.requiredText,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _qty,
                label: 'Quantity',
                keyboardType: TextInputType.number,
                validator: Validators.requiredPositiveInt,
              ),
              const SizedBox(height: 24),
              Consumer<JobOrderController>(
                builder: (context, ctrl, _) => FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    await ctrl.addItem(
                      orderId: _orderNumber.text.trim(),
                      code: _code.text.trim(),
                      description: _description.text.trim(),
                      quantity: int.parse(_qty.text.trim()),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Item ${_code.text} added')),
                      );
                      _code.clear();
                      _description.clear();
                      _qty.text = '1';
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
