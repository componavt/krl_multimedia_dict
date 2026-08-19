import 'package:flutter_test/flutter_test.dart';
import 'package:vepkar_audio/features/games/listen/listen_game_state.dart';
import 'package:vepkar_audio/features/games/listen/listen_round.dart';
import 'package:vepkar_audio/features/games/core/game_entry.dart';
import 'package:vepkar_audio/word_learning_record.dart';

void main() {
  group('ListenGameState', () {
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

    test('ListenGameState.withRound has isRoundActive=true', () {
      final state = ListenGameState.loading();

      expect(state.isLoading, isTrue);
      expect(state.currentRound, isNull);
      expect(state.isSessionCompleted, isFalse);
    });

    test('hadWrongAttempt remains true through wrong-feedback cleanup', () {
      final round = ListenRound(
        target: GameEntry(
          lemmaId: 'target1',
          lemma: 'kotka',
          meaning: 'eagle',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        choices: [
          GameEntry(
            lemmaId: 'target1',
            lemma: 'kotka',
            meaning: 'eagle',
            partOfSpeech: 'noun',
            hasAudio: true,
          ),
          GameEntry(
            lemmaId: 'distractor1',
            lemma: 'koira',
            meaning: 'eagle',
            partOfSpeech: 'noun',
            hasAudio: true,
          ),
        ],
        roundNumber: 0,
      );

      final state = ListenGameState.withChoice(
        round: round,
        score: 0,
        streak: 0,
        bestStreak: 0,
        selectedEntryId: 'distractor1',
        answerIsCorrect: false,
        hadWrongAttempt: true,
      );

      expect(state.hadWrongAttempt, isTrue);

      final clearedState = state.copyWith(
        selectedEntryId: null,
        answerIsCorrect: null,
        isFeedbackInProgress: false,
        isTargetReplayHighlighted: false,
        isCorrectChoiceCelebrating: false,
      );

      expect(clearedState.hadWrongAttempt, isTrue);
    });

    test('new round resets hadWrongAttempt to false', () {
      final round = ListenRound(
        target: GameEntry(
          lemmaId: 'target1',
          lemma: 'kotka',
          meaning: 'eagle',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        choices: [],
        roundNumber: 1,
      );

      final state =
          ListenGameState.withRound(
            round: round,
            score: 0,
            streak: 0,
            bestStreak: 0,
          ).copyWith(
            hadWrongAttempt: false,
            selectedEntryId: null,
            answerIsCorrect: null,
            isFeedbackInProgress: false,
            isTargetReplayHighlighted: false,
            isCorrectChoiceCelebrating: false,
          );

      expect(state.hadWrongAttempt, isFalse);
    });

    test('wrong answer does not advance to next round', () {
      final round = ListenRound(
        target: GameEntry(
          lemmaId: 'target1',
          lemma: 'kotka',
          meaning: 'eagle',
          partOfSpeech: 'noun',
          hasAudio: true,
        ),
        choices: [
          GameEntry(
            lemmaId: 'target1',
            lemma: 'kotka',
            meaning: 'eagle',
            partOfSpeech: 'noun',
            hasAudio: true,
          ),
          GameEntry(
            lemmaId: 'distractor1',
            lemma: 'koira',
            meaning: 'dog',
            partOfSpeech: 'noun',
            hasAudio: true,
          ),
          GameEntry(
            lemmaId: 'distractor2',
            lemma: 'losi',
            meaning: 'moose',
            partOfSpeech: 'noun',
            hasAudio: true,
          ),
          GameEntry(
            lemmaId: 'distractor3',
            lemma: 'hiiri',
            meaning: 'mouse',
            partOfSpeech: 'noun',
            hasAudio: true,
          ),
        ],
        roundNumber: 3,
      );

      final state =
          ListenGameState.withRound(
            round: round,
            score: 0,
            streak: 0,
            bestStreak: 0,
          ).copyWith(
            hadWrongAttempt: false,
            selectedEntryId: null,
            answerIsCorrect: null,
            isFeedbackInProgress: false,
            isTargetReplayHighlighted: false,
            isCorrectChoiceCelebrating: false,
          );

      final wrongEntry = round.choices[1];
      final clearedState = state.copyWith(
        selectedEntryId: wrongEntry.lemmaId,
        answerIsCorrect: false,
        isFeedbackInProgress: true,
        isTargetReplayHighlighted: false,
        isCorrectChoiceCelebrating: false,
        hadWrongAttempt: true,
      );

      final feedbackClearedState = clearedState.copyWith(
        selectedEntryId: null,
        answerIsCorrect: null,
        isFeedbackInProgress: false,
        isTargetReplayHighlighted: false,
        isCorrectChoiceCelebrating: false,
      );

      expect(feedbackClearedState.currentRound, isNotNull);
      expect(feedbackClearedState.currentRound!.target.lemmaId, 'target1');
      expect(
        feedbackClearedState.currentRound!.choices
            .map((e) => e.lemmaId)
            .toList(),
        containsAllInOrder([
          'target1',
          'distractor1',
          'distractor2',
          'distractor3',
        ]),
      );
      expect(feedbackClearedState.currentRound!.roundNumber, 3);
      expect(feedbackClearedState.hadWrongAttempt, isTrue);
    });

    test('LearnedSessionSummary.fromJson deserializes correctly', () {
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
    });
  });
}
