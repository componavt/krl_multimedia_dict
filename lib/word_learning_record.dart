enum WordMastery { newWord, learning, unstable, learned, confident }

class WordLearningRecord {
  const WordLearningRecord({
    required this.lemmaId,
    required this.correctCount,
    required this.wrongCount,
    required this.recentFirstAttemptResults,
    required this.lastPractisedAt,
    required this.matchCorrectCount,
    required this.lastMatchedAt,
  });

  final String lemmaId;
  final int correctCount;
  final int wrongCount;

  final List<bool> recentFirstAttemptResults;

  final DateTime lastPractisedAt;
  final int matchCorrectCount;
  final DateTime? lastMatchedAt;

  int get totalCompletedRounds => correctCount;

  double get firstAttemptAccuracy {
    if (recentFirstAttemptResults.isEmpty) {
      return 0;
    }

    final correctFirstAttempts = recentFirstAttemptResults
        .where((result) => result)
        .length;

    return correctFirstAttempts / recentFirstAttemptResults.length;
  }

  WordMastery get mastery {
    final recent = recentFirstAttemptResults;

    if (correctCount == 0) {
      return WordMastery.newWord;
    }

    if (recent.length < 3) {
      return WordMastery.learning;
    }

    if (recent.length >= 5 && recent.take(5).every((result) => result)) {
      return WordMastery.confident;
    }

    if (correctCount >= 3 && firstAttemptAccuracy >= 0.8) {
      return WordMastery.learned;
    }

    if (firstAttemptAccuracy < 0.6 || wrongCount > correctCount) {
      return WordMastery.unstable;
    }

    return WordMastery.learning;
  }

  WordLearningRecord copyWith({
    String? lemmaId,
    int? correctCount,
    int? wrongCount,
    List<bool>? recentFirstAttemptResults,
    DateTime? lastPractisedAt,
    int? matchCorrectCount,
    DateTime? lastMatchedAt,
  }) {
    return WordLearningRecord(
      lemmaId: lemmaId ?? this.lemmaId,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      recentFirstAttemptResults:
          recentFirstAttemptResults ?? this.recentFirstAttemptResults,
      lastPractisedAt: lastPractisedAt ?? this.lastPractisedAt,
      matchCorrectCount: matchCorrectCount ?? this.matchCorrectCount,
      lastMatchedAt: lastMatchedAt ?? this.lastMatchedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lemma_id': lemmaId,
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'recent_first_attempt_results': recentFirstAttemptResults
          .map((r) => r ? 1 : 0)
          .toList(),
      'last_practised_at': lastPractisedAt.toIso8601String(),
      'match_correct_count': matchCorrectCount,
      'last_matched_at': lastMatchedAt?.toIso8601String(),
    };
  }

  factory WordLearningRecord.fromJson(Map<String, dynamic> json) {
    final recentResults = (json['recent_first_attempt_results'] as List)
        .map((r) => r == 1)
        .toList();

    return WordLearningRecord(
      lemmaId: json['lemma_id'].toString(),
      correctCount: json['correct_count'] as int,
      wrongCount: json['wrong_count'] as int,
      recentFirstAttemptResults: recentResults,
      lastPractisedAt: DateTime.parse(json['last_practised_at'] as String),
      matchCorrectCount: (json['match_correct_count'] as int?) ?? 0,
      lastMatchedAt: json['last_matched_at'] == null
          ? null
          : DateTime.parse(json['last_matched_at'] as String),
    );
  }
}

class LearningSessionSummary {
  const LearningSessionSummary({
    required this.sessionId,
    required this.startedAt,
    required this.completedRounds,
    required this.firstAttemptCorrectRounds,
    required this.roundsWithMistakes,
    required this.newlyLearnedWordIds,
    required this.needingReviewWordIds,
  });

  final String sessionId;
  final DateTime startedAt;
  final int completedRounds;
  final int firstAttemptCorrectRounds;
  final int roundsWithMistakes;

  final Set<String> newlyLearnedWordIds;
  final Set<String> needingReviewWordIds;

  LearningSessionSummary copyWith({
    String? sessionId,
    DateTime? startedAt,
    int? completedRounds,
    int? firstAttemptCorrectRounds,
    int? roundsWithMistakes,
    Set<String>? newlyLearnedWordIds,
    Set<String>? needingReviewWordIds,
  }) {
    return LearningSessionSummary(
      sessionId: sessionId ?? this.sessionId,
      startedAt: startedAt ?? this.startedAt,
      completedRounds: completedRounds ?? this.completedRounds,
      firstAttemptCorrectRounds:
          firstAttemptCorrectRounds ?? this.firstAttemptCorrectRounds,
      roundsWithMistakes: roundsWithMistakes ?? this.roundsWithMistakes,
      newlyLearnedWordIds: newlyLearnedWordIds ?? this.newlyLearnedWordIds,
      needingReviewWordIds: needingReviewWordIds ?? this.needingReviewWordIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'started_at': startedAt.toIso8601String(),
      'completed_rounds': completedRounds,
      'first_attempt_correct_rounds': firstAttemptCorrectRounds,
      'rounds_with_mistakes': roundsWithMistakes,
      'newly_learned_word_ids': newlyLearnedWordIds.toList(),
      'needing_review_word_ids': needingReviewWordIds.toList(),
    };
  }

  factory LearningSessionSummary.fromJson(Map<String, dynamic> json) {
    return LearningSessionSummary(
      sessionId: json['session_id'].toString(),
      startedAt: DateTime.parse(json['started_at'] as String),
      completedRounds: json['completed_rounds'] as int,
      firstAttemptCorrectRounds: json['first_attempt_correct_rounds'] as int,
      roundsWithMistakes: json['rounds_with_mistakes'] as int,
      newlyLearnedWordIds: (json['newly_learned_word_ids'] as List)
          .map((e) => e.toString())
          .toSet(),
      needingReviewWordIds: (json['needing_review_word_ids'] as List)
          .map((e) => e.toString())
          .toSet(),
    );
  }
}

class LearningStatistics {
  const LearningStatistics({
    required this.totalWordsWithAtLeastOneCorrect,
    required this.wordsLearned,
    required this.wordsConfident,
    required this.wordsUnstable,
    required this.wordsNeedingReview,
    required this.wordsReinforcedInMatch,
    required this.pairsMatched,
    this.activeSession,
    this.previousSession,
  });

  final int totalWordsWithAtLeastOneCorrect;
  final int wordsLearned;
  final int wordsConfident;
  final int wordsUnstable;
  final int wordsNeedingReview;
  final int wordsReinforcedInMatch;
  final int pairsMatched;

  final LearningSessionSummary? activeSession;
  final LearningSessionSummary? previousSession;

  factory LearningStatistics.fromJson(Map<String, dynamic> json) {
    return LearningStatistics(
      totalWordsWithAtLeastOneCorrect:
          json['total_words_with_at_least_one_correct'] as int,
      wordsLearned: json['words_learned'] as int,
      wordsConfident: json['words_confident'] as int,
      wordsUnstable: json['words_unstable'] as int,
      wordsNeedingReview: json['words_needing_review'] as int,
      wordsReinforcedInMatch: (json['words_reinforced_in_match'] as int?) ?? 0,
      pairsMatched: (json['pairs_matched'] as int?) ?? 0,
      activeSession: json['active_session'] != null
          ? LearningSessionSummary.fromJson(
              json['active_session'] as Map<String, dynamic>,
            )
          : null,
      previousSession: json['previous_session'] != null
          ? LearningSessionSummary.fromJson(
              json['previous_session'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_words_with_at_least_one_correct': totalWordsWithAtLeastOneCorrect,
      'words_learned': wordsLearned,
      'words_confident': wordsConfident,
      'words_unstable': wordsUnstable,
      'words_needing_review': wordsNeedingReview,
      'words_reinforced_in_match': wordsReinforcedInMatch,
      'pairs_matched': pairsMatched,
      'active_session': activeSession?.toJson(),
      'previous_session': previousSession?.toJson(),
    };
  }
}
