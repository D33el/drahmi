import 'package:drahmi/widgets/operation_dialog.dart';
import 'package:flutter/material.dart';
import '../models/operation.dart';
import '../services/storage_service.dart';
import '../widgets/operation_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double balance = 0;
  List<Operation> operations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await StorageService.loadData();
    setState(() {
      balance = data['balance'];
      operations = (data['operations'] as List)
          .map((e) => Operation.fromJson(e))
          .toList();
    });
  }

  Future<void> _openOperationDialog({
    String? type,
    Operation? operation,
  }) async {
    final isEdit = operation != null;
    final opType = type ?? operation!.type;

    await showDialog(
      context: context,
      builder: (_) => OperationDialog(
        type: opType,
        operation: operation,
        onConfirm: (op) async {
          setState(() {
            if (isEdit) {
              final index = operations.indexWhere((o) => o.id == op.id);
              if (index != -1) {
                final currentOp = operations[index];
                operations[index] = op;
                balance += op.type == 'in'
                    ? op.amount - currentOp.amount
                    : currentOp.amount - op.amount;
              }
            } else {
              operations.insert(0, op);
              balance += op.type == 'in' ? op.amount : -op.amount;
            }
          });
          await StorageService.saveData(balance, operations);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drahmi')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.blueGrey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Solde actuel',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${balance.toStringAsFixed(2)} DZD',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _openOperationDialog(type: 'in'),
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Ajouter',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[300],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _openOperationDialog(type: 'out'),
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Retirer',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[300],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (operations.isEmpty)
              const Center(
                child: Text(
                  'Aucune opération pour le moment.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            for (final op in operations)
              OperationTile(
                operation: op,
                onEdit: () => _openOperationDialog(operation: op),
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Confirmer la suppression'),
                      content: const Text(
                        'Voulez-vous vraiment supprimer cette opération ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    setState(() {
                      operations.removeWhere((o) => o.id == op.id);
                      balance += op.type == 'in' ? -op.amount : op.amount;
                    });
                    await StorageService.saveData(balance, operations);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
