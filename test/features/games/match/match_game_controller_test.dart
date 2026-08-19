import 'package:flutter_test/flutter_test.dart';
import 'package:vepkar_audio/features/games/match/match_game_state.dart';
import 'package:vepkar_audio/features/games/match/match_round.dart';
import 'package:vepkar_audio/features/games/core/game_models.dart';

void main() {
  group('MatchGameState', () {
    test('loading state has null currentRound', () {
      final state = MatchGameState.loading();

      expect(state.isLoading, isTrue);
      expect(state.currentRound, isNull);
    });

    test('withRound creates state with round', () {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state = MatchGameState.withRound(
        round: round,
        matchedPairs: [],
        matchedEntryIds: <String>{},
        bestTimeSeconds: 0,
        elapsedTime: Duration.zero,
      );

      expect(state.isLoading, isFalse);
      expect(state.currentRound, isNotNull);
      expect(state.allMatched, isFalse);
    });

    test('completed state has isSessionCompleted true and isLoading false', () {
      final state = MatchGameState.completed(
        matchedPairs: List.generate(
          5,
          (i) =>
              MatchedPair(id: 'id$i', lemma: 'lemma$i', meaning: 'meaning$i'),
        ),
        matchedEntryIds: {'id0', 'id1', 'id2', 'id3', 'id4'},
        elapsedTime: const Duration(seconds: 30),
        bestTimeSeconds: 30,
      );

      expect(state.isSessionCompleted, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.allMatched, isTrue);
      expect(state.matchedPairs.length, equals(5));
      expect(state.elapsedTime, const Duration(seconds: 30));
      expect(state.bestTimeSeconds, equals(30));
    });

    test('completed state copyWith preserves isSessionCompleted', () {
      final state = MatchGameState.completed(
        matchedPairs: [],
        matchedEntryIds: <String>{},
        elapsedTime: Duration.zero,
        bestTimeSeconds: 0,
      );

      final newState = state.copyWith(bestTimeSeconds: 25);

      expect(newState.isSessionCompleted, isTrue);
      expect(newState.isLoading, isFalse);
    });

    test('matchedEntryIds tracks matched pairs', () {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state = MatchGameState.withRound(
        round: round,
        matchedPairs: [],
        matchedEntryIds: <String>{'pair1'},
        bestTimeSeconds: 0,
        elapsedTime: Duration.zero,
      );

      expect(state.matchedEntryIds, contains('pair1'));
    });

    test('copyWith updates matchedEntryIds', () {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state1 = MatchGameState.withRound(
        round: round,
        matchedPairs: [],
        matchedEntryIds: <String>{'pair1'},
        bestTimeSeconds: 0,
        elapsedTime: Duration.zero,
      );

      final state2 = state1.copyWith(
        matchedEntryIds: <String>{'pair1', 'pair2'},
      );

      expect(state2.matchedEntryIds, contains('pair1'));
      expect(state2.matchedEntryIds, contains('pair2'));
    });

    test('matchedEntryIds is empty by default', () {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state = MatchGameState.withRound(
        round: round,
        matchedPairs: [],
        matchedEntryIds: <String>{},
        bestTimeSeconds: 0,
        elapsedTime: Duration.zero,
      );

      expect(state.matchedEntryIds, isEmpty);
    });

    test('copyWith preserves selectedLeftId with null value', () {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state = MatchGameState.withRound(
        round: round,
        matchedPairs: [],
        matchedEntryIds: <String>{},
        bestTimeSeconds: 0,
        elapsedTime: Duration.zero,
      );

      final newState = state.copyWith(selectedLeftId: null);

      expect(newState.selectedLeftId, isNull);
    });

    test('copyWith preserves selectedRightId with null value', () {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state = MatchGameState.withRound(
        round: round,
        matchedPairs: [],
        matchedEntryIds: <String>{},
        bestTimeSeconds: 0,
        elapsedTime: Duration.zero,
      );

      final newState = state.copyWith(selectedRightId: null);

      expect(newState.selectedRightId, isNull);
    });

    test('copyWith preserves selectedLeftId when set', () {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state = MatchGameState.withRound(
        round: round,
        matchedPairs: [],
        matchedEntryIds: <String>{},
        bestTimeSeconds: 0,
        elapsedTime: Duration.zero,
      );

      final newState = state.copyWith(selectedLeftId: 'left123');

      expect(newState.selectedLeftId, 'left123');
    });

    test('copyWith preserves selectedRightId when set', () {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state = MatchGameState.withRound(
        round: round,
        matchedPairs: [],
        matchedEntryIds: <String>{},
        bestTimeSeconds: 0,
        elapsedTime: Duration.zero,
      );

      final newState = state.copyWith(selectedRightId: 'right123');

      expect(newState.selectedRightId, 'right123');
    });

    test('copyWith preserves isFeedbackInProgress', () {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state = MatchGameState.feedbackComplete(
        round: round,
        matchedPairs: [],
        matchedEntryIds: <String>{},
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
        bestTimeSeconds: 0,
        elapsedTime: Duration.zero,
      ).copyWith(isFeedbackInProgress: true);

      final newState = state.copyWith(elapsedTime: const Duration(seconds: 1));

      expect(newState.isFeedbackInProgress, isTrue);
    });
  });

  group('MatchTimer', () {
    test('timer tick preserves selection state', () {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final initialState = MatchGameState.withRound(
        round: round,
        matchedPairs: [],
        matchedEntryIds: <String>{},
        bestTimeSeconds: 0,
        elapsedTime: Duration.zero,
      ).copyWith(selectedLeftId: 'left123');

      final afterFirstTick = initialState.copyWith(
        elapsedTime: const Duration(seconds: 1),
      );

      expect(afterFirstTick.selectedLeftId, 'left123');
      expect(afterFirstTick.elapsedTime, const Duration(seconds: 1));

      final afterSecondTick = afterFirstTick.copyWith(
        elapsedTime: const Duration(seconds: 2),
      );

      expect(afterSecondTick.selectedLeftId, 'left123');
      expect(afterSecondTick.elapsedTime, const Duration(seconds: 2));
    });

    test('timer tick preserves wrong feedback selection', () {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final initialState =
          MatchGameState.feedbackComplete(
            round: round,
            matchedPairs: [],
            matchedEntryIds: <String>{},
            leftCards: [],
            rightCards: [],
            hintEntryId: null,
            bestTimeSeconds: 0,
            elapsedTime: Duration.zero,
          ).copyWith(
            selectedLeftId: 'wrongLeft',
            selectedRightId: 'wrongRight',
            isFeedbackInProgress: true,
          );

      final afterTick = initialState.copyWith(
        elapsedTime: const Duration(seconds: 1),
      );

      expect(afterTick.selectedLeftId, 'wrongLeft');
      expect(afterTick.selectedRightId, 'wrongRight');
      expect(afterTick.isFeedbackInProgress, isTrue);
    });

    test('newest matched pair is inserted at index 0', () {
      final pairA = MatchedPair(
        id: 'A',
        lemma: 'A lemma',
        meaning: 'A meaning',
      );
      final pairB = MatchedPair(
        id: 'B',
        lemma: 'B lemma',
        meaning: 'B meaning',
      );
      final pairC = MatchedPair(
        id: 'C',
        lemma: 'C lemma',
        meaning: 'C meaning',
      );

      expect([pairC, pairB, pairA][0].id, 'C');
      expect([pairC, pairB, pairA][1].id, 'B');
      expect([pairC, pairB, pairA][2].id, 'A');
    });
  });

  group('MatchGameController', () {
    test('wrong feedback has bilateral wrong IDs', () async {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state =
          MatchGameState.feedbackComplete(
            round: round,
            matchedPairs: [],
            matchedEntryIds: <String>{},
            leftCards: [],
            rightCards: [],
            hintEntryId: null,
            bestTimeSeconds: 0,
            elapsedTime: Duration.zero,
          ).copyWith(
            selectedLeftId: 'wrongLeft',
            selectedRightId: 'wrongRight',
            wrongLeftId: 'wrongLeft',
            wrongRightId: 'wrongRight',
            isFeedbackInProgress: true,
          );

      expect(state.selectedLeftId, 'wrongLeft');
      expect(state.selectedRightId, 'wrongRight');
      expect(state.wrongLeftId, 'wrongLeft');
      expect(state.wrongRightId, 'wrongRight');
      expect(state.isFeedbackInProgress, isTrue);
    });

    test('selection IDs captured before await prevent race', () async {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state =
          MatchGameState.feedbackComplete(
            round: round,
            matchedPairs: [],
            matchedEntryIds: <String>{},
            leftCards: [],
            rightCards: [],
            hintEntryId: null,
            bestTimeSeconds: 0,
            elapsedTime: Duration.zero,
          ).copyWith(
            selectedLeftId: 'left1',
            selectedRightId: 'right1',
            isFeedbackInProgress: true,
          );

      expect(state.selectedLeftId, 'left1');
      expect(state.selectedRightId, 'right1');

      final clearedState = state.copyWith(
        selectedLeftId: null,
        selectedRightId: null,
        wrongLeftId: null,
        wrongRightId: null,
        isFeedbackInProgress: false,
      );

      expect(clearedState.isFeedbackInProgress, isFalse);
    });

    test('right-side selection persists without left-side selection', () async {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final state =
          MatchGameState.feedbackComplete(
            round: round,
            matchedPairs: [],
            matchedEntryIds: <String>{},
            leftCards: [],
            rightCards: [],
            hintEntryId: null,
            bestTimeSeconds: 0,
            elapsedTime: Duration.zero,
          ).copyWith(
            selectedLeftId: null,
            selectedRightId: 'right1',
            isFeedbackInProgress: false,
          );

      expect(state.selectedRightId, 'right1');
      expect(state.selectedLeftId, isNull);
      expect(state.isFeedbackInProgress, isFalse);
    });

    test('timer ticks preserve right-side selection', () async {
      final round = MatchRound(
        entries: [],
        leftCards: [],
        rightCards: [],
        hintEntryId: null,
      );

      final initialState =
          MatchGameState.feedbackComplete(
            round: round,
            matchedPairs: [],
            matchedEntryIds: <String>{},
            leftCards: [],
            rightCards: [],
            hintEntryId: null,
            bestTimeSeconds: 0,
            elapsedTime: Duration.zero,
          ).copyWith(
            selectedLeftId: null,
            selectedRightId: 'right1',
            isFeedbackInProgress: false,
          );

      final afterFirstTick = initialState.copyWith(
        elapsedTime: const Duration(seconds: 1),
      );

      expect(afterFirstTick.selectedRightId, 'right1');
      expect(afterFirstTick.selectedLeftId, isNull);

      final afterSecondTick = afterFirstTick.copyWith(
        elapsedTime: const Duration(seconds: 2),
      );

      expect(afterSecondTick.selectedRightId, 'right1');
      expect(afterSecondTick.elapsedTime, const Duration(seconds: 2));
    });
  });
}
