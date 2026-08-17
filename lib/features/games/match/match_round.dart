import '../core/game_entry.dart';

class MatchRound {
  const MatchRound({
    required this.entries,
    required this.leftCards,
    required this.rightCards,
    this.hintEntryId,
  });

  final List<GameEntry> entries;
  final List<GameEntry> leftCards;
  final List<GameEntry> rightCards;
  final String? hintEntryId;

  @override
  String toString() =>
      'MatchRound(entries: $entries, leftCards: $leftCards, rightCards: $rightCards, hintEntryId: $hintEntryId)';
}
