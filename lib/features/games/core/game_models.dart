class MatchedPair {
  const MatchedPair({
    required this.id,
    required this.lemma,
    required this.meaning,
  });

  final String id;
  final String lemma;
  final String meaning;

  MatchedPair copyWith({String? id, String? lemma, String? meaning}) {
    return MatchedPair(
      id: id ?? this.id,
      lemma: lemma ?? this.lemma,
      meaning: meaning ?? this.meaning,
    );
  }

  @override
  String toString() => 'MatchedPair(id: $id, lemma: $lemma, meaning: $meaning)';
}
