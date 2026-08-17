import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/game_audio_player.dart';
import '../core/game_catalog.dart';
import '../core/game_entry.dart';
import '../core/game_models.dart';
import 'match_game_state.dart';
import 'match_round.dart';
import '../../../word_learning_repository.dart';
import '../../../word_learning_record.dart';

class MatchGameController extends ChangeNotifier {
  MatchGameController({
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

  MatchGameState _state = MatchGameState.loading();
  MatchRound? _currentRound;
  final List<MatchedPair> _matchedPairs = <MatchedPair>[];
  DateTime? _startTime;
  Timer? _timer;
  int _bestTimeSeconds = 0;
  final int _totalPairs = 5;

  MatchGameState get state => _state;

  int get score => _matchedPairs.length;
  int get bestTimeSeconds => _bestTimeSeconds;

  Future<void> initialize() async {
    notifyListeners();
  }

  Future<void> startRound() async {
    final entries = await _catalog.loadEntries();

    if (entries.length < 5) {
      _state = MatchGameState.error(Exception('Not enough entries'));
      notifyListeners();
      return;
    }

    final learningRecords = await learningRepository.getAllRecords();
    final eligibleFamiliar = <GameEntry>[];
    final eligibleReview = <GameEntry>[];

    for (final entry in entries.where((e) => e.hasAudio)) {
      final record = learningRecords[entry.lemmaId];
      if (record != null && record.correctCount > 0) {
        if (record.mastery == WordMastery.learned ||
            record.mastery == WordMastery.confident) {
          eligibleFamiliar.add(entry);
        } else {
          eligibleReview.add(entry);
        }
      }
    }

    List<GameEntry>? candidateList;
    bool hasFamiliar = eligibleFamiliar.isNotEmpty;
    bool hasReview = eligibleReview.isNotEmpty;

    if (hasFamiliar && hasReview) {
      candidateList = _random.nextDouble() < 0.7
          ? eligibleFamiliar
          : eligibleReview;
    } else if (hasFamiliar) {
      candidateList = eligibleFamiliar;
    } else if (hasReview) {
      candidateList = eligibleReview;
    } else {
      candidateList = null;
    }

    final selectedEntries = <GameEntry>[];
    String? hintEntryId;

    if (candidateList != null && candidateList.isNotEmpty) {
      final hintEntry = candidateList[_random.nextInt(candidateList.length)];
      hintEntryId = hintEntry.lemmaId;
      selectedEntries.add(hintEntry);
    }

    while (selectedEntries.length < 5 && entries.isNotEmpty) {
      final entry = entries[_random.nextInt(entries.length)];
      if (!selectedEntries.any((e) => e.lemmaId == entry.lemmaId) &&
          entry.lemmaId != hintEntryId) {
        selectedEntries.add(entry);
      }
    }

    final leftList = List<GameEntry>.from(selectedEntries)..shuffle(_random);
    final rightList = List<GameEntry>.from(selectedEntries)..shuffle(_random);

    final round = MatchRound(
      entries: selectedEntries,
      leftCards: leftList,
      rightCards: rightList,
      hintEntryId: hintEntryId,
    );

    _currentRound = round;
    _matchedPairs.clear();
    _state = MatchGameState.withRound(
      round: round,
      matchedPairs: _matchedPairs,
      bestTimeSeconds: _bestTimeSeconds,
      elapsedTime: Duration.zero,
    );
    notifyListeners();

    if (_timer != null) {
      _timer!.cancel();
    }
    _startTime = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_currentRound != null) {
        final newElapsedTime = DateTime.now().difference(_startTime!);
        _state = MatchGameState.withElapsed(
          round: _currentRound!,
          matchedPairs: _matchedPairs,
          elapsedTime: newElapsedTime,
        );
        notifyListeners();
      } else {
        t.cancel();
      }
    });
  }

  Duration get _elapsedTime => _state.elapsedTime;

  void selectLeft(GameEntry entry) {
    if (_state.isCheckingMatch || _isMatched(entry.lemmaId)) {
      return;
    }

    final selectedId = _state.selectedLeftId == entry.lemmaId
        ? null
        : entry.lemmaId;

    _state = MatchGameState.withSelection(
      round: _currentRound!,
      matchedPairs: _matchedPairs,
      selectedLeftId: selectedId ?? '',
      leftCards: _currentRound!.leftCards,
      rightCards: _currentRound!.rightCards,
      elapsedTime: _elapsedTime,
    );
    notifyListeners();

    _checkMatch();
  }

  void selectRight(GameEntry entry) {
    if (_state.isCheckingMatch || _isMatched(entry.lemmaId)) {
      return;
    }

    final selectedId = _state.selectedRightId == entry.lemmaId
        ? null
        : entry.lemmaId;

    _state = MatchGameState.withSelection(
      round: _currentRound!,
      matchedPairs: _matchedPairs,
      selectedRightId: selectedId ?? '',
      leftCards: _currentRound!.leftCards,
      rightCards: _currentRound!.rightCards,
      elapsedTime: _elapsedTime,
    );
    notifyListeners();

    if (entry.lemmaId == _currentRound!.hintEntryId) {
      audioPlayer.play(entry.lemmaId);
    }

    _checkMatch();
  }

  Future<void> _checkMatch() async {
    final leftId = _state.selectedLeftId;
    final rightId = _state.selectedRightId;

    if (leftId == null || rightId == null || _state.isCheckingMatch) {
      return;
    }

    _state = MatchGameState.withSelection(
      round: _currentRound!,
      matchedPairs: _matchedPairs,
      selectedLeftId: leftId,
      selectedRightId: rightId,
      leftCards: _currentRound!.leftCards,
      rightCards: _currentRound!.rightCards,
      elapsedTime: _elapsedTime,
    );
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (leftId == rightId) {
      final leftEntry = _currentRound!.leftCards.firstWhere(
        (c) => c.lemmaId == leftId,
      );
      final rightEntry = _currentRound!.rightCards.firstWhere(
        (c) => c.lemmaId == rightId,
      );

      _matchedPairs.add(
        MatchedPair(
          id: leftId,
          lemma: leftEntry.lemma,
          meaning: rightEntry.meaning,
        ),
      );

      await learningRepository.registerMatchSuccess(lemmaId: leftId);

      if (_currentRound!.entries.any(
        (e) => e.lemmaId == leftId && e.hasAudio,
      )) {
        await audioPlayer.play(leftId);
      }

      if (_matchedPairs.length == _totalPairs) {
        _timer?.cancel();
        final elapsedTime = DateTime.now().difference(_startTime!);
        final seconds = elapsedTime.inSeconds;
        if (_bestTimeSeconds == 0 || seconds < _bestTimeSeconds) {
          _bestTimeSeconds = seconds;
        }

        _state = MatchGameState.completed(
          matchedPairs: _matchedPairs,
          elapsedTime: elapsedTime,
          bestTimeSeconds: _bestTimeSeconds,
        );
        notifyListeners();
      } else {
        _state = MatchGameState.withMatchResult(
          round: _currentRound!,
          matchedPairs: _matchedPairs,
          leftCards: _currentRound!.leftCards,
          rightCards: _currentRound!.rightCards,
          matchedId: leftId,
          startTime: _startTime!,
          elapsedTime: _elapsedTime,
        );
        notifyListeners();

        await Future<void>.delayed(const Duration(milliseconds: 1500));
        _resetSelection();
      }
    } else {
      _state = MatchGameState.withWrongMatch(
        round: _currentRound!,
        matchedPairs: _matchedPairs,
        leftCards: _currentRound!.leftCards,
        rightCards: _currentRound!.rightCards,
        wrongLeftId: leftId,
        wrongRightId: rightId,
        selectedLeftId: leftId,
        selectedRightId: rightId,
        elapsedTime: _elapsedTime,
      );
      notifyListeners();

      await Future<void>.delayed(const Duration(milliseconds: 500));
      _resetSelection();
    }
  }

  void _resetSelection() {
    _state = MatchGameState.feedbackComplete(
      round: _currentRound!,
      matchedPairs: _matchedPairs,
      leftCards: _currentRound!.leftCards,
      rightCards: _currentRound!.rightCards,
      hintEntryId: _currentRound!.hintEntryId,
      bestTimeSeconds: _bestTimeSeconds,
      elapsedTime: _elapsedTime,
    );
    notifyListeners();
  }

  bool _isMatched(String id) {
    return _matchedPairs.any((p) => p.id == id);
  }
}
