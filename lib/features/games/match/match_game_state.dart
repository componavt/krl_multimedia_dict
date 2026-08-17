import '../core/game_entry.dart';
import '../core/game_models.dart';
import 'match_round.dart';

class MatchGameState {
  const MatchGameState._({
    this.loadError,
    this.currentRound,
    this.leftCards,
    this.rightCards,
    this.matchedPairs = const [],
    this.matchedEntryIds = const <String>{},
    this.selectedLeftId,
    this.selectedRightId,
    this.wrongLeftId,
    this.wrongRightId,
    this.isCheckingMatch = false,
    this.isFeedbackInProgress = false,
    this.startTime,
    this.elapsedTime = Duration.zero,
    this.bestTimeSeconds = 0,
    this.hintEntryId,
  });

  factory MatchGameState.loading() {
    return MatchGameState._();
  }

  factory MatchGameState.error(Object? error) {
    return MatchGameState._(loadError: error);
  }

  factory MatchGameState.withRound({
    required MatchRound round,
    required List<MatchedPair> matchedPairs,
    required Set<String> matchedEntryIds,
    required int? bestTimeSeconds,
    Duration? elapsedTime,
  }) {
    return MatchGameState._(
      currentRound: round,
      leftCards: round.leftCards,
      rightCards: round.rightCards,
      matchedPairs: matchedPairs,
      matchedEntryIds: matchedEntryIds,
      startTime: DateTime.now(),
      elapsedTime: elapsedTime ?? Duration.zero,
      bestTimeSeconds: bestTimeSeconds ?? 0,
    );
  }

  factory MatchGameState.withSelection({
    required MatchRound round,
    required List<MatchedPair> matchedPairs,
    Set<String>? matchedEntryIds,
    String? selectedLeftId,
    String? selectedRightId,
    required List<GameEntry> leftCards,
    required List<GameEntry> rightCards,
    Duration? elapsedTime,
    String? hintEntryId,
  }) {
    return MatchGameState._(
      currentRound: round,
      matchedPairs: matchedPairs,
      matchedEntryIds: matchedEntryIds ?? <String>{},
      selectedLeftId: selectedLeftId,
      selectedRightId: selectedRightId,
      leftCards: leftCards,
      rightCards: rightCards,
      elapsedTime: elapsedTime ?? Duration.zero,
      hintEntryId: hintEntryId,
      isCheckingMatch: false,
    );
  }

  factory MatchGameState.withMatchResult({
    required MatchRound round,
    required List<MatchedPair> matchedPairs,
    required Set<String> matchedEntryIds,
    required List<GameEntry> leftCards,
    required List<GameEntry> rightCards,
    required String matchedId,
    required DateTime startTime,
    Duration? elapsedTime,
  }) {
    return MatchGameState._(
      currentRound: round,
      matchedPairs: matchedPairs,
      matchedEntryIds: matchedEntryIds,
      leftCards: leftCards,
      rightCards: rightCards,
      selectedLeftId: null,
      selectedRightId: null,
      isCheckingMatch: false,
      startTime: startTime,
      elapsedTime: elapsedTime ?? Duration.zero,
    );
  }

  factory MatchGameState.withWrongMatch({
    required MatchRound round,
    required List<MatchedPair> matchedPairs,
    required Set<String> matchedEntryIds,
    required List<GameEntry> leftCards,
    required List<GameEntry> rightCards,
    required String wrongLeftId,
    required String wrongRightId,
    required String selectedLeftId,
    required String selectedRightId,
    Duration? elapsedTime,
    String? hintEntryId,
  }) {
    return MatchGameState._(
      currentRound: round,
      matchedPairs: matchedPairs,
      matchedEntryIds: matchedEntryIds,
      leftCards: leftCards,
      rightCards: rightCards,
      wrongLeftId: wrongLeftId,
      wrongRightId: wrongRightId,
      selectedLeftId: selectedLeftId,
      selectedRightId: selectedRightId,
      elapsedTime: elapsedTime ?? Duration.zero,
      hintEntryId: hintEntryId,
      isCheckingMatch: false,
      isFeedbackInProgress: true,
    );
  }

  factory MatchGameState.feedbackComplete({
    required MatchRound round,
    required List<MatchedPair> matchedPairs,
    required Set<String> matchedEntryIds,
    required List<GameEntry> leftCards,
    required List<GameEntry> rightCards,
    required String? hintEntryId,
    required int? bestTimeSeconds,
    Duration? elapsedTime,
  }) {
    return MatchGameState._(
      currentRound: round,
      matchedPairs: matchedPairs,
      matchedEntryIds: matchedEntryIds,
      leftCards: leftCards,
      rightCards: rightCards,
      selectedLeftId: null,
      selectedRightId: null,
      wrongLeftId: null,
      wrongRightId: null,
      isFeedbackInProgress: false,
      isCheckingMatch: false,
      startTime: DateTime.now(),
      elapsedTime: elapsedTime ?? Duration.zero,
      hintEntryId: hintEntryId,
      bestTimeSeconds: bestTimeSeconds ?? 0,
    );
  }

  factory MatchGameState.withElapsed({
    required MatchRound round,
    required List<MatchedPair> matchedPairs,
    required Set<String> matchedEntryIds,
    required Duration elapsedTime,
  }) {
    return MatchGameState._(
      currentRound: round,
      leftCards: round.leftCards,
      rightCards: round.rightCards,
      matchedPairs: matchedPairs,
      matchedEntryIds: matchedEntryIds,
      elapsedTime: elapsedTime,
      startTime: DateTime.now(),
      hintEntryId: round.hintEntryId,
    );
  }

  factory MatchGameState.completed({
    required List<MatchedPair> matchedPairs,
    required Set<String> matchedEntryIds,
    required Duration elapsedTime,
    required int? bestTimeSeconds,
  }) {
    return MatchGameState._(
      matchedPairs: matchedPairs,
      matchedEntryIds: matchedEntryIds,
      elapsedTime: elapsedTime,
      bestTimeSeconds: bestTimeSeconds ?? 0,
    );
  }

  final Object? loadError;
  final MatchRound? currentRound;
  final List<GameEntry>? leftCards;
  final List<GameEntry>? rightCards;
  final List<MatchedPair> matchedPairs;
  final Set<String> matchedEntryIds;
  final String? selectedLeftId;
  final String? selectedRightId;
  final String? wrongLeftId;
  final String? wrongRightId;
  final bool isCheckingMatch;
  final bool isFeedbackInProgress;
  final DateTime? startTime;
  final Duration elapsedTime;
  final int? bestTimeSeconds;
  final String? hintEntryId;

  bool get isError => loadError != null;
  bool get isLoading => currentRound == null && !isError;
  bool get allMatched => matchedPairs.length == 5;

  MatchGameState copyWith({
    Object? loadError,
    MatchRound? currentRound,
    List<GameEntry>? leftCards,
    List<GameEntry>? rightCards,
    List<MatchedPair>? matchedPairs,
    Set<String>? matchedEntryIds,
    String? selectedLeftId,
    String? selectedRightId,
    String? wrongLeftId,
    String? wrongRightId,
    bool? isCheckingMatch,
    bool? isFeedbackInProgress,
    DateTime? startTime,
    Duration? elapsedTime,
    int? bestTimeSeconds,
    String? hintEntryId,
  }) {
    return MatchGameState._(
      loadError: loadError ?? this.loadError,
      currentRound: currentRound ?? this.currentRound,
      leftCards: leftCards ?? this.leftCards,
      rightCards: rightCards ?? this.rightCards,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      matchedEntryIds: matchedEntryIds ?? this.matchedEntryIds,
      selectedLeftId: selectedLeftId ?? this.selectedLeftId,
      selectedRightId: selectedRightId ?? this.selectedRightId,
      wrongLeftId: wrongLeftId ?? this.wrongLeftId,
      wrongRightId: wrongRightId ?? this.wrongRightId,
      isCheckingMatch: isCheckingMatch ?? this.isCheckingMatch,
      isFeedbackInProgress: isFeedbackInProgress ?? this.isFeedbackInProgress,
      startTime: startTime ?? this.startTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      hintEntryId: hintEntryId ?? this.hintEntryId,
    );
  }

  @override
  String toString() {
    return 'MatchGameState{loadError: $loadError, currentRound: $currentRound, matchedPairs: $matchedPairs, matchedEntryIds: $matchedEntryIds, selectedLeftId: $selectedLeftId, selectedRightId: $selectedRightId, isFeedbackInProgress: $isFeedbackInProgress, isCheckingMatch: $isCheckingMatch, allMatched: $allMatched, elapsedTime: $elapsedTime, bestTimeSeconds: $bestTimeSeconds}';
  }
}
