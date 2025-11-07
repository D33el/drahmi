import 'package:flutter/material.dart';
import '../models/operation.dart';

class OperationTile extends StatelessWidget {
  final Operation operation;

  const OperationTile({super.key, required this.operation});

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
