import 'package:flutter/material.dart';
import '../models/operation.dart';

class OperationDialog extends StatefulWidget {
  final Operation? operation; // null for Add, non-null for Edit
  final String type; // 'in' or 'out'
  final void Function(Operation operation) onConfirm;

  const OperationDialog({
    super.key,
    required this.type,
    required this.onConfirm,
    this.operation,
  });

  bool get isEdit => operation != null;

  @override
  State<OperationDialog> createState() => _OperationDialogState();
}

class _OperationDialogState extends State<OperationDialog> {
  late TextEditingController _amountController;
  late TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.operation?.amount.toString() ?? '',
    );
    _reasonController = TextEditingController(
      text: widget.operation?.reason ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final amount = double.tryParse(_amountController.text);
    final reason = _reasonController.text.trim();

    if (amount == null || amount <= 0) return;

    final op = Operation(
      id:
          widget.operation?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: widget.type,
      reason: reason,
      date: widget.operation?.date ?? DateTime.now(),
    );

    widget.onConfirm(op);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == 'in';
    final isEdit = widget.isEdit;

    return AlertDialog(
      title: Text(
        isEdit
            ? (isIncome ? 'Modifier une entrée' : 'Modifier une sortie')
            : (isIncome ? 'Ajouter de l’argent' : 'Retirer de l’argent'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Montant',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Raison',
              prefixIcon: Icon(Icons.note_alt_outlined),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          child: Text(isEdit ? 'Modifier' : 'Confirmer'),
        ),
      ],
    );
  }
}
