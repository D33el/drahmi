import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/operation.dart';

class StorageService {
  // Get the data file
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/data.json');
  }

  // Load data from file
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

  // Save data to file
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

  static Future<void> resetData() async {
    final file = await _getFile();
    final defaultData = {'balance': 0.0, 'operations': []};
    await file.writeAsString(jsonEncode(defaultData));
  }

  static Future<String> exportDataAsJson() async {
    final file = await _getFile();
    if (!await file.exists()) {
      return jsonEncode({'balance': 0.0, 'operations': []});
    }
    return await file.readAsString();
  }

  static Future<void> importDataFromJson(String jsonString) async {
    final file = await _getFile();

    try {
      final data = jsonDecode(jsonString);
      if (data is Map &&
          data.containsKey('balance') &&
          data.containsKey('operations')) {
        await file.writeAsString(jsonEncode(data));
      } else {
        throw const FormatException('Invalid JSON structure');
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
