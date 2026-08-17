class GameEntry {
  const GameEntry({
    required this.lemmaId,
    required this.lemma,
    required this.meaning,
    required this.partOfSpeech,
    required this.hasAudio,
  });

  final String lemmaId;
  final String lemma;
  final String meaning;
  final String partOfSpeech;
  final bool hasAudio;

  @override
  String toString() =>
      'GameEntry(lemmaId: $lemmaId, lemma: $lemma, meaning: $meaning, partOfSpeech: $partOfSpeech, hasAudio: $hasAudio)';
}
