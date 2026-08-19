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
}
