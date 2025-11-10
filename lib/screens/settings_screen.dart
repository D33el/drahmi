import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = false;

  Future<void> _resetData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialisation des données'),
        content: const Text('Ceci va supprimer toutes les donnés. Continuer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      await StorageService.resetData();
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les données ont été réinitialisés.')),
        );
      }
    }
  }

  Future<void> _exportData() async {
    setState(() => _loading = true);
    final jsonString = await StorageService.exportDataAsJson();
    setState(() => _loading = false);

    if (!mounted) return;

    // Show dialog with copy option
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('JSON exporté'),
        content: SingleChildScrollView(
          child: SelectableText(
            jsonString,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.red),
                  title: const Text('Réinitialiser'),
                  subtitle: const Text(
                    'Effacer toutes les operations et le solde',
                  ),
                  onTap: _resetData,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.upload_file, color: Colors.blue),
                  title: const Text('Exporter les donnés'),
                  subtitle: const Text('Voir et copier les donnés.'),
                  onTap: _exportData,
                ),
              ],
            ),
    );
  }
}
