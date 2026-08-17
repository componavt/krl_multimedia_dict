import '../core/game_entry.dart';

class ListenRound {
  const ListenRound({
    required this.target,
    required this.choices,
    required this.roundNumber,
  });

  final GameEntry target;
  final List<GameEntry> choices;
  final int roundNumber;

  @override
  String toString() =>
      'ListenRound(target: $target, choices: $choices, roundNumber: $roundNumber)';
}
