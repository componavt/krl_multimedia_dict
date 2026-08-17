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
  bool _isSessionCompleted = false;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _hadWrongAttempt = false;
  DateTime _lastChoiceTime = DateTime.now();

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
    _isSessionCompleted = false;
    await _startRound();
  }

  Future<void> completeSession() async {
    await learningRepository.completeActiveSession();
    _isSessionCompleted = true;
    notifyListeners();
  }

  Future<void> resetSession() async {
    await learningRepository.completeActiveSession();
    _roundNumber = 0;
    _score = 0;
    _streak = 0;
    _usedEntryIds.clear();
    _isSessionCompleted = false;
    notifyListeners();
  }

  Future<void> choose(GameEntry entry) async {
    if (_currentState.isFeedbackInProgress ||
        _currentState.answerIsCorrect == true) {
      return;
    }

    _lastChoiceTime = DateTime.now();

    if (entry.lemmaId == _currentState.currentRound!.target.lemmaId) {
      await _handleCorrect(entry);
    } else {
      await _handleWrong(entry);
    }
  }

  Future<void> _handleCorrect(GameEntry entry) async {
    await learningRepository.registerRoundResult(
      lemmaId: entry.lemmaId,
      firstAttemptCorrect: !_hadWrongAttempt,
    );

    _score++;
    _streak++;
    if (_streak > _bestStreak) {
      _bestStreak = _streak;
    }

    final sheenStartedAt = DateTime.now();

    _currentState = ListenGameState.withCelebration(
      round: _currentState.currentRound!,
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
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

    _currentState = ListenGameState.feedbackComplete(
      round: _currentState.currentRound!,
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
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
    _hadWrongAttempt = true;

    _currentState = ListenGameState.withChoice(
      round: _currentState.currentRound!,
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
      selectedEntryId: entry.lemmaId,
      answerIsCorrect: false,
      hadWrongAttempt: _hadWrongAttempt,
    );
    notifyListeners();

    await audioPlayer.playAndWait(entry.lemmaId);

    _currentState = ListenGameState.withCelebration(
      round: _currentState.currentRound!,
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
      isTargetReplayHighlighted: true,
      isCorrectChoiceCelebrating: false,
    );
    notifyListeners();

    await audioPlayer.playAndWait(_currentState.currentRound!.target.lemmaId);

    final elapsed = DateTime.now().difference(_lastChoiceTime);
    final remaining = _minimumTargetSheenDuration - elapsed;

    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    _currentState = ListenGameState.feedbackComplete(
      round: _currentState.currentRound!,
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
    );
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 800));

    _reshuffleChoices();
  }

  void _reshuffleChoices() {
    final round = _currentState.currentRound!;
    final choices = List<GameEntry>.from(round.choices)..shuffle(_random);

    final newRound = ListenRound(
      target: round.target,
      choices: choices,
      roundNumber: round.roundNumber,
    );

    _currentState = ListenGameState.withChoice(
      round: newRound,
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
      selectedEntryId: null,
      answerIsCorrect: null,
      hadWrongAttempt: _hadWrongAttempt,
    );
    notifyListeners();
  }

  Future<void> _startRound() async {
    if (_roundNumber >= _totalListenRounds || _isSessionCompleted) {
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

    _currentState = ListenGameState.withRound(
      round: round,
      score: _score,
      streak: _streak,
      bestStreak: _bestStreak,
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
