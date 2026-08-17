import 'package:flutter_test/flutter_test.dart';
import 'package:vepkar_audio/features/games/listen/listen_game_state.dart';
import 'package:vepkar_audio/features/games/listen/listen_round.dart';
import 'package:vepkar_audio/features/games/core/game_entry.dart';

void main() {
  group('ListenGameState', () {
    test('initial state has null currentRound', () {
      final state = ListenGameState.initial();

      expect(state.isLoading, isTrue);
      expect(state.currentRound, isNull);
    });

    test('loading state has null currentRound', () {
      final state = ListenGameState.loading();

      expect(state.isLoading, isTrue);
      expect(state.currentRound, isNull);
    });

    test('error state has loadError', () {
      final state = ListenGameState.error(Exception('test error'));

      expect(state.isError, isTrue);
      expect(state.loadError, isNotNull);
      expect(state.isLoading, isFalse);
    });

    test('completed state has isSessionCompleted', () {
      final state = ListenGameState.completed(
        score: 10,
        streak: 5,
        bestStreak: 5,
      );

      expect(state.isSessionCompleted, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('withRound creates state with round', () {
      final round = ListenRound(
        target: GameEntry(
          lemmaId: 'test',
          lemma: 'test',
          meaning: 'test',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        choices: [],
        roundNumber: 0,
      );

      final state = ListenGameState.withRound(
        round: round,
        score: 0,
        streak: 0,
        bestStreak: 0,
      );

      expect(state.currentRound, isNotNull);
      expect(state.isRoundActive, isTrue);
    });

    test('withChoice creates state with selection', () {
      final round = ListenRound(
        target: GameEntry(
          lemmaId: 'test',
          lemma: 'test',
          meaning: 'test',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        choices: [],
        roundNumber: 0,
      );

      final state = ListenGameState.withChoice(
        round: round,
        score: 0,
        streak: 0,
        bestStreak: 0,
        selectedEntryId: 'test',
        answerIsCorrect: true,
        hadWrongAttempt: false,
      );

      expect(state.selectedEntryId, 'test');
      expect(state.answerIsCorrect, isTrue);
    });

    test('feedbackInProgress prevents round activity', () {
      final round = ListenRound(
        target: GameEntry(
          lemmaId: 'test',
          lemma: 'test',
          meaning: 'test',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        choices: [],
        roundNumber: 0,
      );

      final state = ListenGameState.withChoice(
        round: round,
        score: 0,
        streak: 0,
        bestStreak: 0,
        selectedEntryId: 'test',
        answerIsCorrect: true,
        hadWrongAttempt: false,
      ).copyWith(isFeedbackInProgress: true);

      expect(state.isRoundActive, isFalse);
    });

    test('copyWith updates answerIsCorrect', () {
      final round = ListenRound(
        target: GameEntry(
          lemmaId: 'test',
          lemma: 'test',
          meaning: 'test',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        choices: [],
        roundNumber: 0,
      );

      final state1 = ListenGameState.withChoice(
        round: round,
        score: 0,
        streak: 0,
        bestStreak: 0,
        selectedEntryId: 'test',
        answerIsCorrect: true,
        hadWrongAttempt: false,
      );

      final state2 = state1.copyWith(answerIsCorrect: false);

      expect(state2.answerIsCorrect, isFalse);
      expect(state1.answerIsCorrect, isTrue);
    });
  });
}
