import 'package:flutter/material.dart';
import '../models/operation.dart';

class OperationTile extends StatelessWidget {
  final Operation operation;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const OperationTile({
    super.key,
    required this.operation,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = operation.type == 'in' ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          operation.type == 'in' ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
        title: Text(
          '${operation.amount.toStringAsFixed(2)} DZD',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        subtitle: Text(
          operation.reason.isEmpty ? 'Aucune raison' : operation.reason,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit' && onEdit != null) {
              onEdit!();
            } else if (value == 'delete' && onDelete != null) {
              onDelete!();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 6),
                  Text('Modifier'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18),
                  SizedBox(width: 6),
                  Text('Supprimer'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
