import 'package:flutter_test/flutter_test.dart';
import 'package:vepkar_audio/features/games/listen/listen_game_state.dart';
import 'package:vepkar_audio/features/games/listen/listen_round.dart';
import 'package:vepkar_audio/features/games/core/game_entry.dart';
import 'package:flutter/foundation.dart';

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

    test('copyWith clears selectedEntryId to null', () {
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

      final newState = state.copyWith(
        selectedEntryId: null,
        answerIsCorrect: null,
        isFeedbackInProgress: false,
        isTargetReplayHighlighted: false,
        isCorrectChoiceCelebrating: false,
      );

      expect(newState.selectedEntryId, isNull);
      expect(newState.answerIsCorrect, isNull);
      expect(newState.isFeedbackInProgress, isFalse);
    });

    test('selectedEntryId is cleared properly after feedback', () {
      final round = ListenRound(
        target: GameEntry(
          lemmaId: 'target',
          lemma: 'kotka',
          meaning: 'eagle',
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
        selectedEntryId: 'target',
        answerIsCorrect: true,
        hadWrongAttempt: false,
      );

      final clearedState = state.copyWith(
        selectedEntryId: null,
        answerIsCorrect: null,
        isFeedbackInProgress: false,
        isTargetReplayHighlighted: false,
        isCorrectChoiceCelebrating: false,
      );

      expect(clearedState.selectedEntryId, isNull);
    });

    test('isTargetReplayHighlighted state is preserved', () {
      final round = ListenRound(
        target: GameEntry(
          lemmaId: 'target',
          lemma: 'kotka',
          meaning: 'eagle',
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
        selectedEntryId: null,
        answerIsCorrect: null,
        hadWrongAttempt: false,
      );

      final highlightedState = state.copyWith(
        isTargetReplayHighlighted: true,
        isFeedbackInProgress: true,
      );

      expect(highlightedState.isTargetReplayHighlighted, isTrue);
      expect(highlightedState.isFeedbackInProgress, isTrue);

      final nonHighlightedState = highlightedState.copyWith(
        isTargetReplayHighlighted: false,
      );

      expect(nonHighlightedState.isTargetReplayHighlighted, isFalse);
    });

    test('isCorrectChoiceCelebrating state is preserved', () {
      final round = ListenRound(
        target: GameEntry(
          lemmaId: 'target',
          lemma: 'kotka',
          meaning: 'eagle',
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
        selectedEntryId: 'target',
        answerIsCorrect: true,
        hadWrongAttempt: false,
      );

      final celebratingState = state.copyWith(
        isCorrectChoiceCelebrating: true,
        isTargetReplayHighlighted: true,
        isFeedbackInProgress: true,
      );

      expect(celebratingState.isCorrectChoiceCelebrating, isTrue);

      final notCelebratingState = celebratingState.copyWith(
        isCorrectChoiceCelebrating: false,
      );

      expect(notCelebratingState.isCorrectChoiceCelebrating, isFalse);
    });
  });

  group('ListenCompleteOnExitBehavior', () {
    test('ListenCompleteOnExitBehavior completes without starting new session', () {
      var onExitCalled = false;
      var startSessionCalled = false;

      final controller = _TestListenGameController(
        onInitialize: () {},
        onStartSession: () {
          startSessionCalled = true;
        },
      );

      final state = ListenGameState.completed(
        score: 10,
        streak: 5,
        bestStreak: 5,
      );

      controller.state = state;
      controller.notifyListeners();

      onExitCalled = true;

      expect(onExitCalled, isTrue);
      expect(startSessionCalled, isFalse);
    });
  });
}

class _TestListenGameController extends ChangeNotifier {
  final void Function() onInitialize;
  final void Function() onStartSession;

  ListenGameState state = ListenGameState.initial();

  _TestListenGameController({
    required this.onInitialize,
    required this.onStartSession,
  });

  Future<void> initialize() async {
    onInitialize();
    notifyListeners();
  }

  Future<void> startSession() async {
    onStartSession();
    notifyListeners();
  }

  Future<void> resetSession() async {
    notifyListeners();
  }

  Future<void> choose(GameEntry entry) async {
    notifyListeners();
  }
}
