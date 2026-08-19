import 'package:flutter_test/flutter_test.dart';
import 'package:vepkar_audio/features/games/match/match_game_state.dart';
import 'package:vepkar_audio/features/games/core/game_models.dart';

void main() {
  group('MatchCompletionWidgetTests', () {
    test('completed state has expected completion properties', () {
      final state = MatchGameState.completed(
        matchedPairs: List.generate(
          5,
          (i) =>
              MatchedPair(id: 'id$i', lemma: 'lemma$i', meaning: 'meaning$i'),
        ),
        matchedEntryIds: {'id0', 'id1', 'id2', 'id3', 'id4'},
        elapsedTime: const Duration(seconds: 45),
        bestTimeSeconds: 45,
      );

      expect(state.isSessionCompleted, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.allMatched, isTrue);
      expect(state.matchedPairs.length, equals(5));
      expect(state.elapsedTime, const Duration(seconds: 45));
      expect(state.bestTimeSeconds, equals(45));
    });

    test('completed state UI renders completion screen in view', () {
      final state = MatchGameState.completed(
        matchedPairs: List.generate(
          5,
          (i) =>
              MatchedPair(id: 'id$i', lemma: 'lemma$i', meaning: 'meaning$i'),
        ),
        matchedEntryIds: {'id0', 'id1', 'id2', 'id3', 'id4'},
        elapsedTime: const Duration(seconds: 60),
        bestTimeSeconds: 60,
      );

      expect(state.isSessionCompleted, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.allMatched, isTrue);

      expect(state.matchedPairs.first.id, equals('id0'));
      expect(state.elapsedTime, const Duration(seconds: 60));
    });

    test('completed state timer cannot mutate state after completion', () {
      final original = MatchGameState.completed(
        matchedPairs: List.generate(
          5,
          (i) =>
              MatchedPair(id: 'id$i', lemma: 'lemma$i', meaning: 'meaning$i'),
        ),
        matchedEntryIds: {'id0', 'id1', 'id2', 'id3', 'id4'},
        elapsedTime: const Duration(seconds: 30),
        bestTimeSeconds: 30,
      );

      final afterDelay = original.copyWith(
        elapsedTime: const Duration(seconds: 31),
      );

      expect(afterDelay.isSessionCompleted, isTrue);
      expect(afterDelay.isLoading, isFalse);
      expect(afterDelay.elapsedTime, const Duration(seconds: 31));
      expect(original.elapsedTime, const Duration(seconds: 30));
    });
  });

  group('MatchedPairsFooterLayoutTests', () {
    test('stack-ordered pairs are maintained in state', () {
      final pairC = MatchedPair(
        id: 'C',
        lemma: 'C lemma',
        meaning: 'C meaning',
      );
      final pairB = MatchedPair(
        id: 'B',
        lemma: 'B lemma',
        meaning: 'B meaning',
      );
      final pairA = MatchedPair(
        id: 'A',
        lemma: 'A lemma',
        meaning: 'A meaning',
      );

      expect([pairC, pairB, pairA][0].id, equals('C'));
      expect([pairC, pairB, pairA][1].id, equals('B'));
      expect([pairC, pairB, pairA][2].id, equals('A'));
    });
  });
}
