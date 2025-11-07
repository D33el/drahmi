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

  Future<void> _addOperation(String type) async {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          type == 'in' ? 'Ajouter de l’argent' : 'Retirer de l’argent',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Montant',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            TextField(
              controller: reasonController,
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
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              final reason = reasonController.text.trim();
              if (amount != null && amount > 0) {
                final op = Operation(
                  id: "0",
                  amount: amount,
                  type: type,
                  reason: reason,
                  date: DateTime.now(),
                );
                setState(() {
                  operations.insert(0, op);
                  balance += type == 'in' ? amount : -amount;
                });
                await StorageService.saveData(balance, operations);
                Navigator.pop(context);
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
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
                          onPressed: () => _addOperation('in'),
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
                          onPressed: () => _addOperation('out'),
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
            for (final op in operations) OperationTile(operation: op),
          ],
        ),
      ),
    );
  }
}
