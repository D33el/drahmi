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

  String formatWithSpaces(double value) {
    final sign = value < 0 ? '-' : '';
    final absVal = value.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final frac = parts[1];
    final sb = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      sb.write(intPart[i]);
      count++;
      if (count % 3 == 0 && i != 0) sb.write(' ');
    }
    final spacedInt = sb.toString().split('').reversed.join();
    return '$sign$spacedInt.$frac';
  }

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
          '${formatWithSpaces(operation.amount)} DZD',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(operation.reason.isEmpty ? 'Aucune raison' : operation.reason),
            const SizedBox(height: 4),
            Text(
              '${(operation.date).day.toString().padLeft(2, '0')}/${(operation.date).month.toString().padLeft(2, '0')}/${(operation.date).year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
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
