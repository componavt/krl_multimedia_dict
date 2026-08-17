import 'package:flutter_test/flutter_test.dart';
import 'package:vepkar_audio/features/games/core/game_models.dart';
import 'package:vepkar_audio/features/games/match/match_game_state.dart';
import 'package:vepkar_audio/features/games/match/match_round.dart';

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
  });

  group('MatchCardColumn enum', () {
    test('enum has karelian value', () {
      expect(MatchCardColumn.karelian, isNotNull);
    });

    test('enum has russian value', () {
      expect(MatchCardColumn.russian, isNotNull);
    });
  });
}
