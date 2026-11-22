import 'package:flutter/services.dart';

import '../models/tree_model.dart';

class TreeRepository {
  static const _datasetPath = 'dataset for tree recommendation/trees.csv';
  Future<List<TreeModel>>? _trees;

  Future<List<TreeModel>> getTrees() async {
    final cached = _trees;
    if (cached != null) return cached;
    try {
      final trees = await _loadTrees();
      _trees = Future.value(trees);
      return trees;
    } catch (_) {
      _trees = null;
      rethrow;
    }
  }

  Future<List<TreeModel>> _loadTrees() async {
    final csv = await rootBundle.loadString(_datasetPath);
    final rows = _parseCsv(csv);
    if (rows.length < 2) {
      throw const FormatException(
          'The tree dataset does not contain any trees.');
    }
    final headers = rows.first.map((header) => header.trim()).toList();
    return rows
        .skip(1)
        .where((row) => row.any((field) => field.trim().isNotEmpty))
        .map((row) {
      if (row.length != headers.length) {
        throw const FormatException(
            'A tree row has an unexpected number of columns.');
      }
      return TreeModel.fromCsvRow({
        for (var i = 0; i < headers.length; i++) headers[i]: row[i].trim(),
      });
    }).toList(growable: false);
  }

  List<List<String>> _parseCsv(String input) {
    final rows = <List<String>>[];
    var row = <String>[];
    final field = StringBuffer();
    var quoted = false;
    for (var i = 0; i < input.length; i++) {
      final character = input[i];
      if (character == '"') {
        if (quoted && i + 1 < input.length && input[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (character == ',' && !quoted) {
        row.add(field.toString());
        field.clear();
      } else if ((character == '\n' || character == '\r') && !quoted) {
        if (character == '\r' && i + 1 < input.length && input[i + 1] == '\n') {
          i++;
        }
        row.add(field.toString());
        field.clear();
        rows.add(row);
        row = <String>[];
      } else {
        field.write(character);
      }
    }
    if (field.isNotEmpty || row.isNotEmpty) {
      row.add(field.toString());
      rows.add(row);
    }
    return rows;
  }
}
