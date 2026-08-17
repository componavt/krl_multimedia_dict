import 'game_entry.dart';

abstract class GameCatalog {
  Future<List<GameEntry>> loadEntries();
}
