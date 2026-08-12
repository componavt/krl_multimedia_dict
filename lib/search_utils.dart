enum SearchMode {
  atStart,
  inside,
  atEnd,
}

class SearchUtils {
  static List<dynamic> filterEntries(
    List<dynamic> entries,
    String query,
    SearchMode mode,
  ) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return List<dynamic>.from(entries);
    }

    return entries.where((dynamic element) {
      final lemma = (element['lemma'] ?? '').toString().toLowerCase();
      final meaning = (element['meaning_text'] ?? '').toString().toLowerCase();

      final bool lemmaMatches;
      switch (mode) {
        case SearchMode.atStart:
          lemmaMatches = lemma.startsWith(normalizedQuery);
          break;
        case SearchMode.inside:
          lemmaMatches = lemma.contains(normalizedQuery);
          break;
        case SearchMode.atEnd:
          lemmaMatches = lemma.endsWith(normalizedQuery);
          break;
      }

      return lemmaMatches || meaning.contains(normalizedQuery);
    }).toList();
  }

  static String serializeSearchMode(SearchMode mode) {
    switch (mode) {
      case SearchMode.atStart:
        return 'atStart';
      case SearchMode.inside:
        return 'inside';
      case SearchMode.atEnd:
        return 'atEnd';
    }
  }

  static SearchMode deserializeSearchMode(String serialized) {
    switch (serialized) {
      case 'atStart':
        return SearchMode.atStart;
      case 'inside':
        return SearchMode.inside;
      case 'atEnd':
        return SearchMode.atEnd;
      default:
        return SearchMode.inside;
    }
  }
}