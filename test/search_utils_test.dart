import 'package:flutter_test/flutter_test.dart';

import 'package:vepkar_audio/search_utils.dart';

void main() {
  test('SearchUtils filter with empty query returns all entries', () {
    final entries = <dynamic>[
      {'lemma': 'kala', 'meaning_text': 'fish'},
      {'lemma': 'koti', 'meaning_text': 'home'},
    ];

    final result = SearchUtils.filterEntries(entries, '', SearchMode.inside);
    expect(result, hasLength(2));
  });

  test('SearchUtils filter at start matches', () {
    final entries = <dynamic>[
      {'lemma': 'kala', 'meaning_text': 'fish'},
      {'lemma': 'koti', 'meaning_text': 'home'},
      {'lemma': 'sika', 'meaning_text': 'deer'},
    ];

    final result = SearchUtils.filterEntries(entries, 'ka', SearchMode.atStart);
    expect(result, hasLength(1));
    expect(result[0]['lemma'], 'kala');
  });

  test('SearchUtils filter inside matches', () {
    final entries = <dynamic>[
      {'lemma': 'kala', 'meaning_text': 'fish'},
      {'lemma': 'sika', 'meaning_text': 'deer'},
    ];

    final result = SearchUtils.filterEntries(entries, 'al', SearchMode.inside);
    expect(result, hasLength(1));
    expect(result[0]['lemma'], 'kala');
  });

  test('SearchUtils filter at end matches', () {
    final entries = <dynamic>[
      {'lemma': 'kala', 'meaning_text': 'fish'},
      {'lemma': 'sika', 'meaning_text': 'deer'},
    ];

    final result = SearchUtils.filterEntries(entries, 'la', SearchMode.atEnd);
    expect(result, hasLength(1));
    expect(result[0]['lemma'], 'kala');
  });

  test('SearchUtils filter checks Russian meaning with contains', () {
    final entries = <dynamic>[
      {'lemma': 'kala', 'meaning_text': 'кала (рыба)'},
      {'lemma': 'sika', 'meaning_text': 'сика (олень)'},
    ];

    final result = SearchUtils.filterEntries(
      entries,
      'кала',
      SearchMode.atStart,
    );
    expect(result, hasLength(1));
    expect(result[0]['lemma'], 'kala');
  });

  test('SearchUtils serialize and deserialize search modes', () {
    expect(SearchUtils.serializeSearchMode(SearchMode.atStart), 'atStart');
    expect(SearchUtils.serializeSearchMode(SearchMode.inside), 'inside');
    expect(SearchUtils.serializeSearchMode(SearchMode.atEnd), 'atEnd');

    expect(SearchUtils.deserializeSearchMode('atStart'), SearchMode.atStart);
    expect(SearchUtils.deserializeSearchMode('inside'), SearchMode.inside);
    expect(SearchUtils.deserializeSearchMode('atEnd'), SearchMode.atEnd);
  });
}
