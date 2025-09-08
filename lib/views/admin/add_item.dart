import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../../services/firestore_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../../utils/validators.dart';

class AddItemPage extends StatefulWidget {
  final String jobOrderId;
  const AddItemPage({super.key, required this.jobOrderId});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  bool _saving = false;

  final _db = FirestoreService();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = Item(
      id: '',
      code: _codeCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      quantity: int.tryParse(_qtyCtrl.text) ?? 1,
    );
    await _db.addItem(widget.jobOrderId, item);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added')),
      );
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: _codeCtrl,
                      label: 'Item Code',
                      validator: Validators.requiredField,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _descCtrl,
                      label: 'Description',
                      validator: Validators.requiredField,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _qtyCtrl,
                      label: 'Quantity',
                      keyboardType: TextInputType.number,
                      validator: Validators.positiveInt,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          text: 'Cancel',
                          onPressed: () => Navigator.pop(context),
                          isSecondary: true,
                        ),
                        const SizedBox(width: 12),
                        CustomButton(
                          text: _saving ? 'Saving...' : 'Save',
                          onPressed: _saving ? null : _save,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
