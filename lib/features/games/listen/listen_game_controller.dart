import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/game_audio_player.dart';
import '../core/game_catalog.dart';
import '../core/game_entry.dart';
import 'listen_game_state.dart';
import 'listen_round.dart';
import '../../../../word_learning_repository.dart';

class ListenGameController extends ChangeNotifier {
  ListenGameController({
    required GameCatalog catalog,
    required this.audioPlayer,
    required this.learningRepository,
    required Random random,
  }) : _catalog = catalog,
       _random = random;

  final GameCatalog _catalog;
  final GameAudioPlayer audioPlayer;
  final WordLearningRepository learningRepository;
  final Random _random;

  final Set<String> _usedEntryIds = <String>{};
  int _roundNumber = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;

  ListenGameState _currentState = ListenGameState.initial();

  ListenGameState get state => _currentState;

  int get score => _score;
  int get streak => _streak;
  int get bestStreak => _bestStreak;

  Future<void> initialize() async {
    notifyListeners();
  }

  Future<void> startSession() async {
    await learningRepository.startSession();
    _roundNumber = 0;
    _score = 0;
    _streak = 0;
    _bestStreak = 0;
    _usedEntryIds.clear();
    await _startRound();
  }

  Future<void> completeSession() async {
    await learningRepository.completeActiveSession();

    _currentState = ListenGameState.completed(
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
    );

    notifyListeners();
  }

  Future<void> resetSession() async {
    await learningRepository.completeActiveSession();
    _roundNumber = 0;
    _score = 0;
    _streak = 0;
    _bestStreak = 0;
    _usedEntryIds.clear();
    await _startRound();
  }

  Future<void> choose(GameEntry entry) async {
    if (_currentState.isFeedbackInProgress ||
        _currentState.selectedEntryId != null) {
      return;
    }

    if (entry.lemmaId == _currentState.currentRound!.target.lemmaId) {
      await _handleCorrect(entry);
    } else {
      await _handleWrong(entry);
    }
  }

  Future<void> _handleCorrect(GameEntry entry) async {
    final currentState = _currentState;
    await learningRepository.registerRoundResult(
      lemmaId: entry.lemmaId,
      firstAttemptCorrect: !currentState.hadWrongAttempt,
    );

    _score++;
    _streak++;
    if (_streak > _bestStreak) {
      _bestStreak = _streak;
    }

    final sheenStartedAt = DateTime.now();

    _currentState = _currentState.copyWith(
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
      selectedEntryId: entry.lemmaId,
      answerIsCorrect: true,
      isFeedbackInProgress: true,
      isTargetReplayHighlighted: true,
      isCorrectChoiceCelebrating: true,
    );
    notifyListeners();

    await audioPlayer.play(entry.lemmaId);

    final elapsed = DateTime.now().difference(sheenStartedAt);
    final remaining = _minimumTargetSheenDuration - elapsed;

    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    _currentState = _currentState.copyWith(
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
      selectedEntryId: null,
      answerIsCorrect: null,
      isFeedbackInProgress: false,
      isTargetReplayHighlighted: false,
      isCorrectChoiceCelebrating: false,
    );
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 1500));

    _roundNumber++;
    if (_roundNumber >= _totalListenRounds) {
      await completeSession();
    } else {
      await _startRound();
    }
  }

  Future<void> _handleWrong(GameEntry entry) async {
    _streak = 0;

    final startTime = DateTime.now();

    _currentState = _currentState.copyWith(
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
      selectedEntryId: entry.lemmaId,
      answerIsCorrect: false,
      isFeedbackInProgress: true,
      isTargetReplayHighlighted: false,
      isCorrectChoiceCelebrating: false,
      hadWrongAttempt: true,
    );
    notifyListeners();

    await audioPlayer.playAndWait(entry.lemmaId);

    _currentState = _currentState.copyWith(isTargetReplayHighlighted: true);
    notifyListeners();

    await audioPlayer.playAndWait(_currentState.currentRound!.target.lemmaId);

    final elapsed = DateTime.now().difference(startTime);
    final remaining = _minimumTargetSheenDuration - elapsed;

    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    _currentState = _currentState.copyWith(
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
      selectedEntryId: null,
      answerIsCorrect: null,
      isFeedbackInProgress: false,
      isTargetReplayHighlighted: false,
      isCorrectChoiceCelebrating: false,
    );
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  Future<void> _startRound() async {
    if (_roundNumber >= _totalListenRounds) {
      await completeSession();
      return;
    }

    final entries = await _catalog.loadEntries();
    final audioEnabled = entries.where((e) => e.hasAudio).toList();

    if (audioEnabled.length < 4) {
      notifyListeners();
      return;
    }

    final available = audioEnabled
        .where((e) => !_usedEntryIds.contains(e.lemmaId))
        .toList();

    if (available.isEmpty) {
      _usedEntryIds.clear();
      return _startRound();
    }

    final target = available[_random.nextInt(available.length)];
    final choices = <GameEntry>[target];
    final usedMeanings = <String>{_normalizedMeaning(target)};

    final distractors =
        audioEnabled
            .where(
              (e) =>
                  e.lemmaId != target.lemmaId &&
                  usedMeanings.contains(_normalizedMeaning(e)) == false,
            )
            .toList()
          ..shuffle(_random);

    for (final distractor in distractors) {
      if (choices.length == 4) break;
      choices.add(distractor);
      usedMeanings.add(_normalizedMeaning(distractor));
    }

    if (choices.length < 4) {
      notifyListeners();
      return;
    }

    choices.shuffle(_random);
    _usedEntryIds.add(target.lemmaId);

    final round = ListenRound(
      target: target,
      choices: choices,
      roundNumber: _roundNumber,
    );

    final newState = ListenGameState.withRound(
      round: round,
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
    );

    _currentState = newState.copyWith(
      selectedEntryId: null,
      answerIsCorrect: null,
      hadWrongAttempt: false,
      isFeedbackInProgress: false,
      isTargetReplayHighlighted: false,
      isCorrectChoiceCelebrating: false,
      isSessionCompleted: false,
    );
    notifyListeners();

    await audioPlayer.play(target.lemmaId);
  }

  int get _totalListenRounds => 10;

  Duration get _minimumTargetSheenDuration =>
      const Duration(milliseconds: 1600);

  String _normalizedMeaning(GameEntry entry) {
    return entry.meaning.trim().toLowerCase();
  }
}
