import 'listen_round.dart';

class ListenGameState {
  static const Object _sentinelUnset = Object();

  const ListenGameState._({
    this.loadError,
    this.currentRound,
    this.score = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.selectedEntryId,
    this.answerIsCorrect,
    this.hadWrongAttempt = false,
    this.isFeedbackInProgress = false,
    this.isTargetReplayHighlighted = false,
    this.isCorrectChoiceCelebrating = false,
    this.isSessionCompleted = false,
  });

  factory ListenGameState.initial() {
    return const ListenGameState._();
  }

  factory ListenGameState.loading() {
    return const ListenGameState._();
  }

  factory ListenGameState.error(Object? error) {
    return ListenGameState._(loadError: error);
  }

  factory ListenGameState.completed({
    required int score,
    required int streak,
    required int bestStreak,
  }) {
    return ListenGameState._(
      score: score,
      streak: streak,
      bestStreak: bestStreak,
      isSessionCompleted: true,
    );
  }

  factory ListenGameState.withRound({
    required ListenRound round,
    required int score,
    required int streak,
    required int bestStreak,
  }) {
    return ListenGameState._(
      currentRound: round,
      score: score,
      streak: streak,
      bestStreak: bestStreak,
    );
  }

  factory ListenGameState.withChoice({
    required ListenRound round,
    required int score,
    required int streak,
    required int bestStreak,
    String? selectedEntryId,
    required bool? answerIsCorrect,
    required bool hadWrongAttempt,
  }) {
    return ListenGameState._(
      currentRound: round,
      score: score,
      streak: streak,
      bestStreak: bestStreak,
      selectedEntryId: selectedEntryId,
      answerIsCorrect: answerIsCorrect,
      hadWrongAttempt: hadWrongAttempt,
    );
  }

  factory ListenGameState.withCelebration({
    required ListenRound round,
    required int score,
    required int streak,
    required int bestStreak,
    required bool isTargetReplayHighlighted,
    required bool isCorrectChoiceCelebrating,
  }) {
    return ListenGameState._(
      currentRound: round,
      score: score,
      streak: streak,
      bestStreak: bestStreak,
      isTargetReplayHighlighted: isTargetReplayHighlighted,
      isCorrectChoiceCelebrating: isCorrectChoiceCelebrating,
    );
  }

  factory ListenGameState.feedbackComplete({
    required ListenRound round,
    required int score,
    required int streak,
    required int bestStreak,
  }) {
    return ListenGameState._(
      currentRound: round,
      score: score,
      streak: streak,
      bestStreak: bestStreak,
      isFeedbackInProgress: false,
      isTargetReplayHighlighted: false,
      isCorrectChoiceCelebrating: false,
    );
  }

  final Object? loadError;
  final ListenRound? currentRound;
  final int score;
  final int streak;
  final int bestStreak;
  final String? selectedEntryId;
  final bool? answerIsCorrect;
  final bool hadWrongAttempt;
  final bool isFeedbackInProgress;
  final bool isTargetReplayHighlighted;
  final bool isCorrectChoiceCelebrating;
  final bool isSessionCompleted;

  bool get isError => loadError != null;
  bool get isLoading => currentRound == null && !isError && !isSessionCompleted;
  bool get isRoundActive =>
      currentRound != null && !isSessionCompleted && !isFeedbackInProgress;

  ListenGameState copyWith({
    Object? loadError,
    ListenRound? currentRound,
    int? score,
    int? streak,
    int? bestStreak,
    Object? selectedEntryId = _sentinelUnset,
    Object? answerIsCorrect,
    bool? hadWrongAttempt,
    Object? isFeedbackInProgress,
    Object? isTargetReplayHighlighted,
    Object? isCorrectChoiceCelebrating,
    bool? isSessionCompleted,
  }) {
    final bool resolvedFeedbackInProgress =
        identical(isFeedbackInProgress, _sentinelUnset)
        ? this.isFeedbackInProgress
        : (isFeedbackInProgress as bool?) ?? this.isFeedbackInProgress;
    final bool resolvedTargetReplayHighlighted =
        identical(isTargetReplayHighlighted, _sentinelUnset)
        ? this.isTargetReplayHighlighted
        : (isTargetReplayHighlighted as bool?) ??
              this.isTargetReplayHighlighted;
    final bool resolvedCorrectChoiceCelebrating =
        identical(isCorrectChoiceCelebrating, _sentinelUnset)
        ? this.isCorrectChoiceCelebrating
        : (isCorrectChoiceCelebrating as bool?) ??
              this.isCorrectChoiceCelebrating;

    return ListenGameState._(
      loadError: loadError ?? this.loadError,
      currentRound: currentRound ?? this.currentRound,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      selectedEntryId: identical(selectedEntryId, _sentinelUnset)
          ? this.selectedEntryId
          : selectedEntryId as String?,
      answerIsCorrect: identical(answerIsCorrect, _sentinelUnset)
          ? this.answerIsCorrect
          : answerIsCorrect as bool?,
      hadWrongAttempt: hadWrongAttempt ?? this.hadWrongAttempt,
      isFeedbackInProgress: resolvedFeedbackInProgress,
      isTargetReplayHighlighted: resolvedTargetReplayHighlighted,
      isCorrectChoiceCelebrating: resolvedCorrectChoiceCelebrating,
      isSessionCompleted: isSessionCompleted ?? this.isSessionCompleted,
    );
  }

  @override
  String toString() {
    return 'ListenGameState{loadError: $loadError, currentRound: $currentRound, score: $score, streak: $streak, bestStreak: $bestStreak, selectedEntryId: $selectedEntryId, answerIsCorrect: $answerIsCorrect, hadWrongAttempt: $hadWrongAttempt, isFeedbackInProgress: $isFeedbackInProgress, isTargetReplayHighlighted: $isTargetReplayHighlighted, isCorrectChoiceCelebrating: $isCorrectChoiceCelebrating, isSessionCompleted: $isSessionCompleted}';
  }
}
