import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DictionaryRepository {
  Future<List<dynamic>> loadEntries() async {
    final jsonString = await rootBundle.loadString('assets/dict.json');
    final decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException(
        'assets/dict.json must contain a JSON array.',
      );
    }

    return decoded;
  }
}
