import 'package:flutter_test/flutter_test.dart';
import 'package:vepkar_audio/features/games/listen/listen_game_state.dart';
import 'package:vepkar_audio/word_learning_record.dart';

void main() {
  group('ListenGameController', () {
    test(
      'ListenGameState.completed() has isSessionCompleted=true and isLoading=false',
      () {
        final state = ListenGameState.completed(
          score: 8,
          streak: 5,
          bestStreak: 5,
        );

        expect(state.isSessionCompleted, isTrue);
        expect(state.isLoading, isFalse);
        expect(state.score, 8);
        expect(state.streak, 5);
        expect(state.bestStreak, 5);
      },
    );

    test(
      'ListenGameState.withRound has isRoundActive=true',
      () {
        final state = ListenGameState.loading();

        expect(state.isLoading, isTrue);
        expect(state.currentRound, isNull);
        expect(state.isSessionCompleted, isFalse);
      },
    );

    test(
      'LearnedSessionSummary.fromJson deserializes correctly',
      () {
        final json = {
          'session_id': 'test123',
          'started_at': '2026-08-18T12:00:00.000Z',
          'completed_rounds': 10,
          'first_attempt_correct_rounds': 8,
          'rounds_with_mistakes': 2,
          'newly_learned_word_ids': ['word1', 'word2'],
          'needing_review_word_ids': ['word3'],
        };

        final session = LearningSessionSummary.fromJson(json);

        expect(session.sessionId, 'test123');
        expect(session.completedRounds, 10);
        expect(session.firstAttemptCorrectRounds, 8);
        expect(session.roundsWithMistakes, 2);
        expect(session.newlyLearnedWordIds.length, 2);
        expect(session.needingReviewWordIds.length, 1);
      },
    );
  });
}
