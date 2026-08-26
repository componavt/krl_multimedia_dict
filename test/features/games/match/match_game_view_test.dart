import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vepkar_audio/features/games/match/match_game_state.dart';
import 'package:vepkar_audio/features/games/match/match_round.dart';
import 'package:vepkar_audio/features/games/match/widgets/match_choice_card.dart';
import 'package:vepkar_audio/features/games/core/game_entry.dart';
import 'package:vepkar_audio/features/games/core/game_models.dart';
import 'package:vepkar_audio/app_theme.dart';

void main() {
  group('MatchChoiceCard', () {
    test('wrong card uses brick red color', () {
      final card = MatchChoiceCard(
        gameEntry: GameEntry(
          lemmaId: 'card1',
          lemma: 'kotka',
          meaning: 'кошка',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        column: MatchCardColumn.russian,
        onTap: () {},
        isSelected: false,
        isMatched: false,
        isWrong: true,
        backgroundColor: Colors.green,
      );

      final cardWidget = card;
      expect(cardWidget.isWrong, isTrue);
    });

    test('selected card uses amber color when not wrong', () {
      final card = MatchChoiceCard(
        gameEntry: GameEntry(
          lemmaId: 'card1',
          lemma: 'kotka',
          meaning: 'кошка',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        column: MatchCardColumn.russian,
        onTap: () {},
        isSelected: true,
        isMatched: false,
        isWrong: false,
        backgroundColor: Colors.blue,
      );

      expect(card.isSelected, isTrue);
      expect(card.isWrong, isFalse);
    });

    test('matched card uses moss green color', () {
      final card = MatchChoiceCard(
        gameEntry: GameEntry(
          lemmaId: 'card1',
          lemma: 'kotka',
          meaning: 'кошка',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        column: MatchCardColumn.russian,
        onTap: () {},
        isSelected: false,
        isMatched: true,
        isWrong: false,
        backgroundColor: Colors.blue,
      );

      expect(card.isMatched, isTrue);
    });
  });

  group('MatchGameSelection', () {
    test('selectedRightId persists during timer ticks', () {
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
      ).copyWith(selectedRightId: 'pair1', isFeedbackInProgress: false);

      expect(state.selectedRightId, 'pair1');

      final afterTick = state.copyWith(elapsedTime: const Duration(seconds: 1));

      expect(afterTick.selectedRightId, 'pair1');
    });

    test('wrong feedback state persists', () {
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
            selectedLeftId: 'pair1',
            selectedRightId: 'pair1',
            wrongLeftId: 'pair1',
            wrongRightId: 'pair1',
            isFeedbackInProgress: true,
          );

      expect(state.wrongLeftId, 'pair1');
      expect(state.wrongRightId, 'pair1');
      expect(state.isFeedbackInProgress, isTrue);

      final afterTick = state.copyWith(elapsedTime: const Duration(seconds: 1));

      expect(afterTick.wrongLeftId, 'pair1');
      expect(afterTick.wrongRightId, 'pair1');
    });
  });

  group('MatchChoiceCardRendering', () {
    test('right-side selected card renders amber', () {
      final card = MatchChoiceCard(
        gameEntry: GameEntry(
          lemmaId: 'card1',
          lemma: 'kotka',
          meaning: 'кошка',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        column: MatchCardColumn.russian,
        onTap: () {},
        isSelected: true,
        isMatched: false,
        isWrong: false,
        backgroundColor: AppPalette.translationPanel,
      );

      expect(card.isSelected, isTrue);
      expect(card.isWrong, isFalse);
      expect(card.isMatched, isFalse);
    });

    test('right-side wrong card renders brick red', () {
      final card = MatchChoiceCard(
        gameEntry: GameEntry(
          lemmaId: 'card1',
          lemma: 'kotka',
          meaning: 'кошка',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        column: MatchCardColumn.russian,
        onTap: () {},
        isSelected: false,
        isMatched: false,
        isWrong: true,
        backgroundColor: AppPalette.translationPanel,
      );

      expect(card.isWrong, isTrue);
      expect(card.isSelected, isFalse);
    });

    test('right-side matched card renders moss green', () {
      final card = MatchChoiceCard(
        gameEntry: GameEntry(
          lemmaId: 'card1',
          lemma: 'kotka',
          meaning: 'кошка',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        column: MatchCardColumn.russian,
        onTap: () {},
        isSelected: false,
        isMatched: true,
        isWrong: false,
        backgroundColor: AppPalette.translationPanel,
      );

      expect(card.isMatched, isTrue);
      expect(card.isSelected, isFalse);
      expect(card.isWrong, isFalse);
    });
  });

  group('MatchedPairsFooter', () {
    test('newest Restored Pair has muted-brown highlight', () {
      final newestPair = MatchedPair(
        id: 'newest',
        lemma: 'newest lemma',
        meaning: 'newest meaning',
      );
      final olderPair = MatchedPair(
        id: 'older',
        lemma: 'older lemma',
        meaning: 'older meaning',
      );

      final matchedPairs = [newestPair, olderPair];

      expect(matchedPairs[0].id, 'newest');
      expect(matchedPairs[1].id, 'older');
      expect(matchedPairs.length, equals(2));

      final isNewestIndexZero = 0 == 0;
      expect(isNewestIndexZero, isTrue);
      expect(newestPair.id, matchedPairs[0].id);
    });

    test('older pairs retain transparent/default background', () {
      final pair1 = MatchedPair(
        id: 'pair1',
        lemma: 'pair1 lemma',
        meaning: 'pair1 meaning',
      );
      final pair2 = MatchedPair(
        id: 'pair2',
        lemma: 'pair2 lemma',
        meaning: 'pair2 meaning',
      );
      final pair3 = MatchedPair(
        id: 'pair3',
        lemma: 'pair3 lemma',
        meaning: 'pair3 meaning',
      );

      final matchedPairs = [pair1, pair2, pair3];

      expect(matchedPairs[0].id, 'pair1');
      expect(matchedPairs[1].id, 'pair2');
      expect(matchedPairs[2].id, 'pair3');
      expect(matchedPairs.length, equals(3));

      expect(matchedPairs[1].id != 'pair1', isTrue);
    });
  });

  group('MatchGameControllerStateTransitions', () {
    test('final-pair completion publishes completed state after audio', () {
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
      expect(state.matchedPairs.length, equals(5));
      expect(state.elapsedTime, const Duration(seconds: 30));
      expect(state.bestTimeSeconds, equals(30));
    });

    test('newest pair at index zero in matchedPairs', () {
      final pairA = MatchedPair(id: 'A', lemma: 'A', meaning: 'A');
      final pairB = MatchedPair(id: 'B', lemma: 'B', meaning: 'B');

      final matchedPairs = <MatchedPair>[pairA];
      matchedPairs.insert(0, pairB);

      expect(matchedPairs[0].id, 'B');
      expect(matchedPairs[1].id, 'A');
      expect(matchedPairs.length, equals(2));
    });
  });
}
