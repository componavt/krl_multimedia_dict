import 'package:flutter_test/flutter_test.dart';

import 'package:vepkar_audio/dictionary_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DictionaryRepository loads entries from dict.json', () async {
    final repository = DictionaryRepository();
    final entries = await repository.loadEntries();

    expect(entries, isNotEmpty);
    expect(entries, hasLength(greaterThan(0)));

    if (entries.isNotEmpty) {
      final firstEntry = entries[0];
      expect(firstEntry.containsKey('lemma'), isTrue);
      expect(firstEntry.containsKey('lemma_id'), isTrue);
      expect(firstEntry.containsKey('meaning_text'), isTrue);
    }
  });
}
