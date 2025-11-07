import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/operation.dart';

class StorageService {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/data.json');
  }

  static Future<Map<String, dynamic>> loadData() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return {'balance': 0.0, 'operations': []};
      }
      final content = await file.readAsString();
      return jsonDecode(content);
    } catch (_) {
      return {'balance': 0.0, 'operations': []};
    }
  }

  static Future<void> saveData(
    double balance,
    List<Operation> operations,
  ) async {
    final file = await _getFile();
    final data = {
      'balance': balance,
      'operations': operations.map((op) => op.toJson()).toList(),
    };
    await file.writeAsString(jsonEncode(data));
  }
}
