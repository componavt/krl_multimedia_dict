import 'package:flutter_test/flutter_test.dart';

import 'package:vepkar_audio/word_learning_record.dart';

void main() {
  test('WordMastery enum values work correctly', () {
    expect(WordMastery.newWord.index, 0);
    expect(WordMastery.learning.index, 1);
    expect(WordMastery.unstable.index, 2);
    expect(WordMastery.learned.index, 3);
    expect(WordMastery.confident.index, 4);
  });

  test('WordLearningRecord calculates mastery correctly for new word', () {
    final record = WordLearningRecord(
      lemmaId: 'test',
      correctCount: 0,
      wrongCount: 0,
      recentFirstAttemptResults: [],
      lastPractisedAt: DateTime.now(),
      matchCorrectCount: 0,
      lastMatchedAt: null,
    );
    expect(record.mastery, WordMastery.newWord);
  });

  test('WordLearningRecord calculates mastery correctly for learning', () {
    final record = WordLearningRecord(
      lemmaId: 'test',
      correctCount: 1,
      wrongCount: 0,
      recentFirstAttemptResults: [true],
      lastPractisedAt: DateTime.now(),
      matchCorrectCount: 0,
      lastMatchedAt: null,
    );
    expect(record.mastery, WordMastery.learning);
  });

  test('WordLearningRecord calculates mastery correctly for unstable', () {
    final record = WordLearningRecord(
      lemmaId: 'test',
      correctCount: 2,
      wrongCount: 5,
      recentFirstAttemptResults: [true, false, true, false, true],
      lastPractisedAt: DateTime.now(),
      matchCorrectCount: 0,
      lastMatchedAt: null,
    );
    expect(record.mastery, WordMastery.unstable);
  });

  test('WordLearningRecord calculates mastery correctly for confident', () {
    final record = WordLearningRecord(
      lemmaId: 'confident_lemma',
      correctCount: 10,
      wrongCount: 0,
      recentFirstAttemptResults: [
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
      ],
      lastPractisedAt: DateTime.now(),
      matchCorrectCount: 0,
      lastMatchedAt: null,
    );
    expect(record.mastery, WordMastery.confident);
  });

  test('WordLearningRecord calculates firstAttemptAccuracy', () {
    final record = WordLearningRecord(
      lemmaId: 'test',
      correctCount: 3,
      wrongCount: 0,
      recentFirstAttemptResults: [true, true, false],
      lastPractisedAt: DateTime.now(),
      matchCorrectCount: 0,
      lastMatchedAt: null,
    );
    expect(record.firstAttemptAccuracy, 2 / 3);
  });

  test('WordLearningRecord copyWith creates new instance', () {
    final record = WordLearningRecord(
      lemmaId: 'test',
      correctCount: 1,
      wrongCount: 0,
      recentFirstAttemptResults: [true],
      lastPractisedAt: DateTime.now(),
      matchCorrectCount: 0,
      lastMatchedAt: null,
    );

    final updated = record.copyWith(correctCount: 5);
    expect(updated.correctCount, 5);
    expect(record.correctCount, 1);
  });

  test('WordLearningRecord toJson converts to map', () {
    final record = WordLearningRecord(
      lemmaId: 'test',
      correctCount: 3,
      wrongCount: 1,
      recentFirstAttemptResults: [true, false, true],
      lastPractisedAt: DateTime(2023, 1, 1),
      matchCorrectCount: 0,
      lastMatchedAt: null,
    );

    final json = record.toJson();
    expect(json['lemma_id'], 'test');
    expect(json['correct_count'], 3);
    expect(json['wrong_count'], 1);
    expect(json['recent_first_attempt_results'], [1, 0, 1]);
  });

  test('WordLearningRecord fromJson creates instance from map', () {
    final json = {
      'lemma_id': 'test',
      'correct_count': 3,
      'wrong_count': 1,
      'recent_first_attempt_results': [1, 0, 1],
      'last_practised_at': '2023-01-01T00:00:00.000',
      'match_correct_count': 0,
      'last_matched_at': null,
    };

    final record = WordLearningRecord.fromJson(json);
    expect(record.lemmaId, 'test');
    expect(record.correctCount, 3);
    expect(record.wrongCount, 1);
    expect(record.recentFirstAttemptResults, [true, false, true]);
  });

  test('LearningSessionSummary creates session with correct defaults', () {
    final session = LearningSessionSummary(
      sessionId: 'test_session',
      startedAt: DateTime.now(),
      completedRounds: 0,
      firstAttemptCorrectRounds: 0,
      roundsWithMistakes: 0,
      newlyLearnedWordIds: <String>{},
      needingReviewWordIds: <String>{},
    );

    expect(session.sessionId, 'test_session');
    expect(session.completedRounds, 0);
    expect(session.firstAttemptCorrectRounds, 0);
    expect(session.roundsWithMistakes, 0);
  });

  test('LearningSessionSummary copyWith updates values', () {
    final session = LearningSessionSummary(
      sessionId: 'test_session',
      startedAt: DateTime.now(),
      completedRounds: 5,
      firstAttemptCorrectRounds: 3,
      roundsWithMistakes: 2,
      newlyLearnedWordIds: <String>{},
      needingReviewWordIds: <String>{},
    );

    final updated = session.copyWith(completedRounds: 10);
    expect(updated.completedRounds, 10);
    expect(session.completedRounds, 5);
  });

  test('LearningSessionSummary toJson converts to map', () {
    final session = LearningSessionSummary(
      sessionId: 'test_session',
      startedAt: DateTime(2023, 1, 1),
      completedRounds: 5,
      firstAttemptCorrectRounds: 3,
      roundsWithMistakes: 2,
      newlyLearnedWordIds: <String>{'word1'},
      needingReviewWordIds: <String>{'word2'},
    );

    final json = session.toJson();
    expect(json['session_id'], 'test_session');
    expect(json['completed_rounds'], 5);
    expect(json['first_attempt_correct_rounds'], 3);
    expect(json['rounds_with_mistakes'], 2);
  });

  test('LearningSessionSummary fromJson creates instance from map', () {
    final json = {
      'session_id': 'test_session',
      'started_at': '2023-01-01T00:00:00.000',
      'completed_rounds': 5,
      'first_attempt_correct_rounds': 3,
      'rounds_with_mistakes': 2,
      'newly_learned_word_ids': ['word1', 'word2'],
      'needing_review_word_ids': ['word3'],
    };

    final session = LearningSessionSummary.fromJson(json);
    expect(session.sessionId, 'test_session');
    expect(session.completedRounds, 5);
    expect(session.newlyLearnedWordIds, {'word1', 'word2'});
    expect(session.needingReviewWordIds, {'word3'});
  });

  test('LearningStatistics creates correct counts', () {
    final stats = LearningStatistics(
      totalWordsWithAtLeastOneCorrect: 10,
      wordsLearned: 5,
      wordsConfident: 3,
      wordsUnstable: 2,
      wordsNeedingReview: 4,
      wordsReinforcedInMatch: 0,
      pairsMatched: 0,
      activeSession: null,
      previousSession: null,
    );

    expect(stats.totalWordsWithAtLeastOneCorrect, 10);
    expect(stats.wordsLearned, 5);
    expect(stats.wordsConfident, 3);
    expect(stats.wordsUnstable, 2);
    expect(stats.wordsNeedingReview, 4);
  });
}
