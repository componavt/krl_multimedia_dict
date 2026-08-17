import 'package:flutter/services.dart' show rootBundle, AssetManifest;

import 'game_entry.dart';
import 'game_catalog.dart';

class GameCatalogImpl implements GameCatalog {
  final Set<String> _audioEnabledWordIds = <String>{};

  @override
  Future<List<GameEntry>> loadEntries() async {
    await _loadAudioEnabledWordIds();

    final jsonString = await rootBundle.loadString('assets/dict.json');
    final decoded = jsonString as List<dynamic>;

    final entries = <GameEntry>[];
    for (final rawEntry in decoded) {
      final entry = _parseEntry(rawEntry);
      if (entry != null) {
        entries.add(entry);
      }
    }

    return entries;
  }

  GameEntry? _parseEntry(dynamic rawEntry) {
    final lemma = (rawEntry['lemma'] ?? '').toString().trim();
    final lemmaId = (rawEntry['lemma_id'] ?? '').toString().trim();
    final meaning = (rawEntry['meaning_text'] ?? '').toString().trim();
    final partOfSpeech = (rawEntry['part_of_speech'] ?? '').toString().trim();

    if (lemma.isEmpty || lemmaId.isEmpty || meaning.isEmpty) {
      return null;
    }

    return GameEntry(
      lemmaId: lemmaId,
      lemma: lemma,
      meaning: meaning,
      partOfSpeech: partOfSpeech,
      hasAudio: _audioEnabledWordIds.contains(lemmaId),
    );
  }

  Future<void> _loadAudioEnabledWordIds() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    final audioIds = <String>{};
    final pattern = RegExp(r'^assets/audio/([^/]+)\.wav$');

    for (final assetPath in manifest.listAssets()) {
      final match = pattern.firstMatch(assetPath);
      if (match != null) {
        audioIds.add(match.group(1)!);
      }
    }

    _audioEnabledWordIds.addAll(audioIds);
  }
}
