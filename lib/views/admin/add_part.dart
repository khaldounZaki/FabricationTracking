import 'package:flutter/material.dart';
import '../../models/part.dart';
import '../../services/firestore_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../../utils/validators.dart';

class AddPartPage extends StatefulWidget {
  final String jobOrderId;
  final String orderNumber;
  final String itemId;
  final String itemCode;

  const AddPartPage({
    super.key,
    required this.jobOrderId,
    required this.orderNumber,
    required this.itemId,
    required this.itemCode,
  });

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  bool _saving = false;

  final _db = FirestoreService();

  String _computeSN() {
    // Simple rule (you can extend later): orderNumber-itemCode-1
    // If you later want unique per piece or per part, you’ll adjust here.
    return '${widget.orderNumber}-${widget.itemCode}-1';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final part = Part(
      id: '',
      itemId: widget.itemId,
      description: _descCtrl.text.trim(),
      sn: _computeSN(),
      createdAt: DateTime.now(),
    );
    await _db.addPart(widget.jobOrderId, widget.itemId, part);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Part added')));
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sn = _computeSN();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Part')),
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
                      controller: _descCtrl,
                      label: 'Part Description (e.g. Top, Shelf, Leg)',
                      validator: Validators.requiredField,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('SN will be: $sn',
                          style: Theme.of(context).textTheme.bodySmall),
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
