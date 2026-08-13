import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'dictionary_repository.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'text_scale_controller.dart';
import 'word_learning_repository.dart';
import 'word_learning_record.dart';

enum GameMode { selection, listen, match }

class MatchedPair {
  final String id;
  final String lemma;
  final String meaning;

  MatchedPair({required this.id, required this.lemma, required this.meaning});

  MatchedPair copyWith({String? id, String? lemma, String? meaning}) {
    return MatchedPair(
      id: id ?? this.id,
      lemma: lemma ?? this.lemma,
      meaning: meaning ?? this.meaning,
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.localeController,
    required this.textScaleController,
  });

  final LocaleController localeController;
  final TextScaleController textScaleController;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with TickerProviderStateMixin<GamePage> {
  final DictionaryRepository _repository = DictionaryRepository();
  final WordLearningRepository _learningRepository = WordLearningRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;
  GameMode _currentMode = GameMode.selection;
  Object? _loadError;

  final Set<String> _usedEntryIds = <String>{};
  int _listenRoundNumber = 0;
  int _listenScore = 0;
  int _listenStreak = 0;
  int _listenBestStreak = 0;
  bool _currentRoundHadWrongAttempt = false;
  bool _isListenSessionCompleted = false;
  Timer? _showAssociationTimer;

  final Set<String> _availableAudioIds = <String>{};
  String? _audioHintLemmaId;

  Map<String, dynamic>? _listenEntry;
  List<Map<String, dynamic>> _listenChoices = <Map<String, dynamic>>[];
  String? _selectedListenId;
  bool? _listenAnswerIsCorrect;

  List<Map<String, dynamic>> _matchEntries = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _leftCards = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _rightCards = <Map<String, dynamic>>[];
  final Set<String> _matchedIds = <String>{};
  String? _selectedLeftId;
  String? _selectedRightId;
  String? _wrongLeftId;
  String? _wrongRightId;
  bool _isCheckingMatch = false;
  bool _isMatchCompleted = false;
  DateTime? _matchStartedAt;
  Timer? _matchTimer;
  Duration _matchElapsed = Duration.zero;
  int _bestMatchTimeSeconds = 0;

  final List<MatchedPair> _matchedPairs = <MatchedPair>[];

  static const int _totalListenRounds = 10;

  @override
  void initState() {
    super.initState();
    _initializeGameData();
  }

  Future<void> _initializeGameData() async {
    try {
      final entries = await _repository.loadEntries();

      if (!mounted) return;

      setState(() {
        _entries = entries.cast<Map<String, dynamic>>();
      });

      await _preloadAudioAssets();
      await _loadBestScores();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _validEntries {
    return _entries
        .where((entry) {
          final lemma = (entry['lemma'] ?? '').toString().trim();
          final lemmaId = (entry['lemma_id'] ?? '').toString().trim();
          final meaning = (entry['meaning_text'] ?? '').toString().trim();
          return lemma.isNotEmpty && lemmaId.isNotEmpty && meaning.isNotEmpty;
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Future<void> _loadBestScores() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _bestMatchTimeSeconds = prefs.getInt('game_best_time_mode_b') ?? 0;
    });
  }

  Future<void> _preloadAudioAssets() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();

    final audioIds = <String>{};

    for (final entry in _validEntries) {
      final lemmaId = entry['lemma_id'].toString();
      final assetPath = 'audio/$lemmaId.wav';

      if (assets.contains(assetPath)) {
        audioIds.add(lemmaId);
      }
    }

    if (!mounted) return;

    setState(() {
      _availableAudioIds.clear();
      _availableAudioIds.addAll(audioIds);
    });

    await _learningRepository.setAudioEnabledWordIds(audioIds);
  }

  Future<void> _playAudioHint(String lemmaId) async {
    await _audioPlayer.stop();
    try {
      await _audioPlayer.play(AssetSource('audio/$lemmaId.wav'));
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n!.audioPlaybackError}: $e'),
          backgroundColor: AppPalette.brickRed,
        ),
      );
    }
  }

  Future<void> _saveMatchBestTime(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = duration.inSeconds;
    if (_bestMatchTimeSeconds == 0 || seconds < _bestMatchTimeSeconds) {
      await prefs.setInt('game_best_time_mode_b', seconds);
      if (!mounted) return;
      setState(() {
        _bestMatchTimeSeconds = seconds;
      });
    }
  }

  Future<void> _playEntryAudio(Map<String, dynamic> entry) async {
    final lemmaId = entry['lemma_id'].toString();
    await _audioPlayer.stop();
    try {
      await _audioPlayer.play(AssetSource('audio/$lemmaId.wav'));
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n!.audioPlaybackError}: $e'),
          backgroundColor: AppPalette.brickRed,
        ),
      );
    }
  }

  Color _listenChoiceColor(Map<String, dynamic> choice) {
    final choiceId = choice['lemma_id'].toString();
    final correctId = _listenEntry!['lemma_id'].toString();

    if (_listenAnswerIsCorrect == true && choiceId == correctId) {
      return AppPalette.mossGreen;
    }

    if (_listenAnswerIsCorrect == false && choiceId == _selectedListenId) {
      return AppPalette.brickRed;
    }

    if (_listenAnswerIsCorrect == false && choiceId == correctId) {
      return AppPalette.amber;
    }

    return AppPalette.mutedBrown;
  }

  Color _listenProgressColor() {
    final progress = _listenRoundNumber / _totalListenRounds;
    if (progress >= 1.0) return AppPalette.mossGreen;
    if (progress >= 0.7) return AppPalette.amber;
    return AppPalette.parchment;
  }

  Future<void> _startListenRound() async {
    if (_listenRoundNumber >= _totalListenRounds || _isListenSessionCompleted) {
      _completeListenSession();
      return;
    }

    final l10n = AppLocalizations.of(context);
    final validEntries = _validEntries;

    final audioEnabledEntries = validEntries.where((entry) {
      final id = entry['lemma_id'].toString();
      return _availableAudioIds.contains(id);
    }).toList();

    if (audioEnabledEntries.length < 4) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n!.notEnoughEntries),
          backgroundColor: AppPalette.brickRed,
        ),
      );
      return;
    }

    final random = Random();
    final availableEntries = audioEnabledEntries.where((entry) {
      final id = entry['lemma_id'].toString();
      return !_usedEntryIds.contains(id);
    }).toList();

    if (availableEntries.isEmpty) {
      _usedEntryIds.clear();
    }

    final correct = availableEntries[random.nextInt(availableEntries.length)];
    final choices = <Map<String, dynamic>>[correct];

    final distractors =
        audioEnabledEntries
            .where(
              (entry) =>
                  entry['lemma_id'].toString() !=
                  correct['lemma_id'].toString(),
            )
            .toList()
          ..shuffle(random);

    choices.addAll(distractors.take(3));
    choices.shuffle(random);

    final lemmaId = correct['lemma_id'].toString();
    _usedEntryIds.add(lemmaId);

    if (!mounted) return;
    setState(() {
      _listenEntry = correct;
      _listenChoices = choices;
      _selectedListenId = null;
      _listenAnswerIsCorrect = null;
      _currentRoundHadWrongAttempt = false;
    });

    await _playEntryAudio(correct);
  }

  Future<void> _completeListenSession() async {
    await _learningRepository.completeActiveSession();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            l10n!.listenAndGuess,
            style: const TextStyle(
              fontFamily: 'Centro',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n!.scoreOutOf(_listenScore, _totalListenRounds),
                  style: const TextStyle(fontFamily: 'Open Sans'),
                ),
                if (_listenStreak > 1)
                  Text(
                    l10n!.currentStreak(_listenStreak),
                    style: const TextStyle(fontFamily: 'Open Sans'),
                  ),
                if (_listenBestStreak > 1)
                  Text(
                    l10n!.bestStreakLabel(_listenBestStreak),
                    style: const TextStyle(fontFamily: 'Open Sans'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _resetListenSession();
              },
              child: Text(l10n!.playAgain),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _currentMode = GameMode.selection;
                });
              },
              child: Text(l10n!.backToGames),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetListenSession() async {
    await _learningRepository.completeActiveSession();
    if (!mounted) return;
    setState(() {
      _listenRoundNumber = 0;
      _listenScore = 0;
      _listenStreak = 0;
      _usedEntryIds.clear();
      _isListenSessionCompleted = false;
      _currentMode = GameMode.selection;
    });
  }

  Future<void> _startMatchRound() async {
    _audioHintLemmaId = null;

    final l10n = AppLocalizations.of(context);
    final validEntries = _validEntries;
    if (validEntries.length < 5) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n!.notEnoughEntries),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final random = Random();

    final learningRecords = await _learningRepository.getAllRecords();

    final eligibleFamiliar = <Map<String, dynamic>>[];
    final eligibleReview = <Map<String, dynamic>>[];

    for (final entry in validEntries) {
      final lemmaId = entry['lemma_id'].toString();
      if (!_availableAudioIds.contains(lemmaId)) {
        continue;
      }
      final record = learningRecords[lemmaId];
      if (record != null && record.correctCount > 0) {
        if (record.mastery == WordMastery.learned ||
            record.mastery == WordMastery.confident) {
          eligibleFamiliar.add(entry);
        } else {
          eligibleReview.add(entry);
        }
      }
    }

    List<Map<String, dynamic>>? candidateList;
    bool hasFamiliar = eligibleFamiliar.isNotEmpty;
    bool hasReview = eligibleReview.isNotEmpty;

    if (hasFamiliar && hasReview) {
      candidateList = random.nextDouble() < 0.7
          ? eligibleFamiliar
          : eligibleReview;
    } else if (hasFamiliar) {
      candidateList = eligibleFamiliar;
    } else if (hasReview) {
      candidateList = eligibleReview;
    } else {
      candidateList = null;
    }

    final selectedEntries = <Map<String, dynamic>>[];
    String? hintEntryId;

    if (candidateList != null && candidateList.isNotEmpty) {
      final hintEntry = candidateList[random.nextInt(candidateList.length)];
      hintEntryId = hintEntry['lemma_id'].toString();
      selectedEntries.add(hintEntry);
    }

    while (selectedEntries.length < 5 && validEntries.isNotEmpty) {
      final entry = validEntries[random.nextInt(validEntries.length)];
      if (!selectedEntries.any(
            (e) => e['lemma_id'].toString() == entry['lemma_id'].toString(),
          ) &&
          entry['lemma_id'].toString() != hintEntryId) {
        selectedEntries.add(entry);
      }
    }

    final leftList = List<Map<String, dynamic>>.from(selectedEntries)
      ..shuffle(random);
    final rightList = List<Map<String, dynamic>>.from(selectedEntries)
      ..shuffle(random);

    if (!mounted) return;

    setState(() {
      _matchEntries = selectedEntries;
      _leftCards = leftList;
      _rightCards = rightList;
      _matchedIds.clear();
      _matchedPairs.clear();
      _selectedLeftId = null;
      _selectedRightId = null;
      _wrongLeftId = null;
      _wrongRightId = null;
      _isCheckingMatch = false;
      _isMatchCompleted = false;
    });

    if (hintEntryId != null) {
      _audioHintLemmaId = hintEntryId;
    }

    if (_matchTimer != null) {
      _matchTimer!.cancel();
    }
    _matchStartedAt = DateTime.now();
    _matchElapsed = Duration.zero;

    _matchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _matchElapsed = DateTime.now().difference(_matchStartedAt!);
      });
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  Color _matchCardColor({
    required bool isSelected,
    required bool isMatched,
    required bool isWrong,
    required Color backgroundColor,
  }) {
    if (isMatched) {
      return AppPalette.mossGreen;
    }
    if (isWrong) {
      return AppPalette.brickRed;
    }
    if (isSelected) {
      return AppPalette.amber;
    }
    return backgroundColor;
  }

  Widget _buildMatchCard({
    required String text,
    required VoidCallback? onTap,
    required bool isSelected,
    required bool isMatched,
    required bool isWrong,
    required Alignment alignment,
    required Color backgroundColor,
    String? audioHintEntryId,
    VoidCallback? onAudioHintTapped,
    TextAlignVertical? textAlignVertical,
    TextStyle? style,
    bool? softWrap,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final Color cardColor = _matchCardColor(
      isSelected: isSelected,
      isMatched: isMatched,
      isWrong: isWrong,
      backgroundColor: backgroundColor,
    );

    final cardContent = InkWell(
      onTap: isMatched ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                text,
                softWrap: softWrap ?? true,
                maxLines: maxLines ?? 3,
                overflow: overflow ?? TextOverflow.ellipsis,
                style:
                    style ??
                    const TextStyle(
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (audioHintEntryId != null &&
                audioHintEntryId == _audioHintLemmaId &&
                onAudioHintTapped != null)
              const SizedBox(width: 8),
            if (audioHintEntryId != null &&
                audioHintEntryId == _audioHintLemmaId &&
                onAudioHintTapped != null)
              InkWell(
                onTap: isMatched ? null : onAudioHintTapped,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppPalette.amber,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.hearing,
                    size: 16,
                    color: AppPalette.parchment,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          child: cardContent,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _matchTimer?.cancel();
    _showAssociationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n!.loading),
            ],
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade200),
                const SizedBox(height: 16),
                Text(
                  l10n!.gameLoadError,
                  style: const TextStyle(fontFamily: 'Open Sans'),
                ),
                const SizedBox(height: 16),
                Text(_loadError.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _initializeGameData,
                  child: Text(l10n!.playAgain),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final children = <Widget>[];
    if (_currentMode == GameMode.selection) {
      children.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: AppPalette.mutedBrown,
                    foregroundColor: AppPalette.parchment,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentMode = GameMode.listen;
                    });
                    _startListenSession();
                  },
                  child: Text(
                    l10n!.listenAndGuess,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                      color: AppPalette.parchment,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: AppPalette.mutedBrown,
                    foregroundColor: AppPalette.parchment,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentMode = GameMode.match;
                    });
                    _startMatchRound();
                  },
                  child: Text(
                    l10n!.matchPairs,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                      color: AppPalette.parchment,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_currentMode == GameMode.listen) {
      children.add(Expanded(child: _buildListenMode()));
    } else if (_currentMode == GameMode.match) {
      children.add(Expanded(child: _buildMatchMode()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppPalette.archiveSurface,
        title: Text(
          l10n!.game,
          style: const TextStyle(
            fontFamily: 'Centro',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppPalette.parchment,
          ),
        ),
        leading: _currentMode != GameMode.selection
            ? IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  if (_currentMode == GameMode.listen && _listenEntry != null) {
                    _audioPlayer.stop();
                    _showAssociationTimer?.cancel();
                  }
                  if (_currentMode == GameMode.match && _matchTimer != null) {
                    _matchTimer!.cancel();
                  }
                  setState(() {
                    _currentMode = GameMode.selection;
                  });
                },
              )
            : null,
      ),
      body: Column(children: children),
    );
  }

  Future<void> _startListenSession() async {
    if (_validEntries.isEmpty) {
      return;
    }

    await _learningRepository.startSession();
    _listenRoundNumber = 0;
    _listenScore = 0;
    _listenStreak = 0;
    _listenBestStreak = 0;
    _usedEntryIds.clear();
    _isListenSessionCompleted = false;

    if (!mounted) return;
    setState(() {
      _currentMode = GameMode.listen;
    });

    await _startListenRound();
  }

  Future<void> _handleListenCorrect() async {
    final entryId = _listenEntry!['lemma_id'].toString();

    await _learningRepository.registerRoundResult(
      lemmaId: entryId,
      firstAttemptCorrect: !_currentRoundHadWrongAttempt,
    );

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    if (_listenStreak > _listenBestStreak) {
      _listenBestStreak = _listenStreak;
    }

    setState(() {
      _listenScore++;
    });

    final association = _listenEntry!['meaning_text'].toString();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n!.correct,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'Open Sans',
              ),
            ),
            Text(
              association,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontFamily: 'Open Sans',
              ),
            ),
          ],
        ),
        backgroundColor: AppPalette.mossGreen,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    _showAssociationTimer?.cancel();
    _showAssociationTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _listenRoundNumber++;
      if (_listenRoundNumber >= _totalListenRounds) {
        _isListenSessionCompleted = true;
        _completeListenSession();
      } else {
        _startListenRound();
      }
    });
  }

  Future<void> _handleListenWrong() async {
    final l10n = AppLocalizations.of(context);
    final chosenEntry = _listenChoices.firstWhere(
      (c) => c['lemma_id'].toString() == _selectedListenId,
    );
    final chosenMeaning = chosenEntry['meaning_text'].toString();

    await _playEntryAudio(_listenEntry!);

    if (!mounted) return;

    _currentRoundHadWrongAttempt = true;
    _listenStreak = 0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n!.wrongTryAgain} ${l10n!.listenAndGuess}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'Open Sans',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n!.wrongChoiceMeaning(
                _listenEntry!['lemma'].toString(),
                chosenMeaning,
              ),
              style: const TextStyle(fontFamily: 'Open Sans'),
            ),
          ],
        ),
        backgroundColor: AppPalette.brickRed,
        duration: const Duration(seconds: 3),
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    _reshuffleListenChoices();
  }

  void _reshuffleListenChoices() {
    final random = Random();

    setState(() {
      _listenChoices = List<Map<String, dynamic>>.from(_listenChoices)
        ..shuffle(random);

      _selectedListenId = null;
      _listenAnswerIsCorrect = null;
    });
  }

  Widget _buildListenMode() {
    final l10n = AppLocalizations.of(context);
    if (_listenEntry == null || _listenChoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n!.loading),
          ],
        ),
      );
    }

    final progress = _listenRoundNumber / _totalListenRounds;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${l10n!.listenAndGuess}: ${_listenRoundNumber + 1} / $_totalListenRounds',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Open Sans',
                  color: AppPalette.parchment,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppPalette.mutedBrown,
              valueColor: AlwaysStoppedAnimation<Color>(_listenProgressColor()),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.mutedBrown,
                  foregroundColor: AppPalette.parchment,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                onPressed: () {
                  if (_listenEntry != null) {
                    _playEntryAudio(_listenEntry!);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      size: 24,
                      color: AppPalette.parchment,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n!.listen,
                      style: const TextStyle(color: AppPalette.parchment),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          for (final choice in _listenChoices)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  backgroundColor: _listenChoiceColor(choice),
                ),
                onPressed: _listenAnswerIsCorrect == true
                    ? null
                    : () {
                        final selectedId = choice['lemma_id'].toString();
                        final correctId = _listenEntry!['lemma_id'].toString();

                        if (_selectedListenId == selectedId) {
                          return;
                        }

                        if (!mounted) return;
                        setState(() {
                          _selectedListenId = selectedId;
                          _listenAnswerIsCorrect = selectedId == correctId;
                        });
                        if (_listenAnswerIsCorrect == true) {
                          _listenStreak++;
                          _handleListenCorrect();
                        } else {
                          _handleListenWrong();
                        }
                      },
                child: Text(
                  choice['lemma'].toString(),
                  style: const TextStyle(
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                    color: AppPalette.parchment,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    l10n!.scoreOutOf(_listenScore, _totalListenRounds),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Open Sans',
                      color: AppPalette.parchment,
                    ),
                  ),
                  Text(
                    '$_listenScore',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      fontFamily: 'Open Sans',
                      color: AppPalette.parchment,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    l10n!.currentStreak(_listenStreak),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Open Sans',
                      color: AppPalette.parchment,
                    ),
                  ),
                  Text(
                    '$_listenStreak',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      fontFamily: 'Open Sans',
                      color: AppPalette.parchment,
                    ),
                  ),
                ],
              ),
              if (_listenBestStreak > 0)
                Column(
                  children: [
                    Text(
                      l10n!.bestStreakLabel(_listenBestStreak),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Open Sans',
                        color: AppPalette.parchment,
                      ),
                    ),
                    Text(
                      '$_listenBestStreak',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        fontFamily: 'Open Sans',
                        color: AppPalette.parchment,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchMode() {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_leftCards.isEmpty || _rightCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n!.loading),
          ],
        ),
      );
    }

    final int totalPairs = 5;
    final int matchedPairs = _matchedIds.length;
    final bool allMatched = matchedPairs == totalPairs;

    if (allMatched) {
      _completeMatchRound();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n!.matchCompleted,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Open Sans',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildMatchZone(
                    title: l10n!.karelianColumn,
                    backgroundColor: AppPalette.karelianPanel,
                    cards: _leftCards,
                    isLeftSide: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMatchZone(
                    title: l10n!.translationColumn,
                    backgroundColor: AppPalette.translationPanel,
                    cards: _rightCards,
                    isLeftSide: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildMatchedPairsFooter(),
      ],
    );
  }

  Widget _buildMatchZone({
    required String title,
    required Color backgroundColor,
    required List<Map<String, dynamic>> cards,
    required bool isLeftSide,
  }) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Open Sans',
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cards.length,
            itemBuilder: (BuildContext context, int index) {
              final card = cards[index];
              final cardId = card['lemma_id'].toString();

              if (_matchedIds.contains(cardId)) {
                return const SizedBox.shrink();
              }

              if (isLeftSide) {
                return _buildMatchCard(
                  text: card['lemma'].toString(),
                  onTap: () {
                    _selectLeftCard(card);
                  },
                  isSelected: _selectedLeftId == cardId,
                  isMatched: false,
                  isWrong: _wrongLeftId == cardId,
                  alignment: Alignment.centerLeft,
                  backgroundColor: backgroundColor,
                );
              } else {
                final cardStyle = const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w600,
                );
                return _buildMatchCard(
                  text: card['meaning_text'].toString(),
                  textAlignVertical: TextAlignVertical.center,
                  onTap: () {
                    _selectRightCard(card);
                  },
                  isSelected: _selectedRightId == cardId,
                  isMatched: false,
                  isWrong: _wrongRightId == cardId,
                  alignment: Alignment.centerRight,
                  backgroundColor: backgroundColor,
                  audioHintEntryId: cardId,
                  onAudioHintTapped: () => _handleAudioHintTapped(card),
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatchedPairsFooter() {
    final l10n = AppLocalizations.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.28,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: AppPalette.archiveSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n!.restoredPairs,
              style: const TextStyle(
                color: AppPalette.parchment,
                fontWeight: FontWeight.w600,
                fontFamily: 'Open Sans',
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemCount: _matchedPairs.length,
                itemBuilder: (context, index) {
                  final pair = _matchedPairs[index];

                  return AnimatedSlide(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    offset: Offset.zero,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              pair.lemma,
                              style: const TextStyle(
                                color: AppPalette.parchment,
                                fontFamily: 'Open Sans',
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: AppPalette.amber,
                          ),
                          Expanded(
                            child: Text(
                              pair.meaning,
                              style: const TextStyle(
                                color: AppPalette.parchment,
                                fontFamily: 'Open Sans',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectLeftCard(Map<String, dynamic> entry) {
    final id = entry['lemma_id'].toString();

    if (_isCheckingMatch || _matchedIds.contains(id)) {
      return;
    }

    setState(() {
      _selectedLeftId = _selectedLeftId == id ? null : id;
    });

    _checkMatch();
  }

  void _selectRightCard(Map<String, dynamic> entry) {
    final id = entry['lemma_id'].toString();

    if (_isCheckingMatch || _matchedIds.contains(id)) {
      return;
    }

    setState(() {
      _selectedRightId = _selectedRightId == id ? null : id;
    });

    _checkMatch();
  }

  Future<void> _checkMatch() async {
    final leftId = _selectedLeftId;
    final rightId = _selectedRightId;

    if (leftId == null || rightId == null || _isCheckingMatch) {
      return;
    }

    setState(() {
      _isCheckingMatch = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted) {
      return;
    }

    if (leftId == rightId) {
      final leftEntry = _leftCards.firstWhere(
        (c) => c['lemma_id'].toString() == leftId,
      );
      final rightEntry = _rightCards.firstWhere(
        (c) => c['lemma_id'].toString() == rightId,
      );

      setState(() {
        _matchedIds.add(leftId);
        _matchedPairs.add(
          MatchedPair(
            id: leftId,
            lemma: leftEntry['lemma'].toString(),
            meaning: rightEntry['meaning_text'].toString(),
          ),
        );
        _selectedLeftId = null;
        _selectedRightId = null;
        _isCheckingMatch = false;
      });

      if (_matchedIds.length == _matchEntries.length) {
        _isMatchCompleted = true;
        _matchTimer?.cancel();
        if (!mounted) return;

        await _saveMatchBestTime(_matchElapsed);
        if (!mounted) return;

        final l10n = AppLocalizations.of(context);
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(
                l10n!.matchCompleted,
                style: const TextStyle(
                  fontFamily: 'Centro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                '${l10n!.elapsedTime}: '
                '${_formatDuration(_matchElapsed)}',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _startMatchRound();
                  },
                  child: Text(l10n!.playAgain),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    setState(() {
                      _currentMode = GameMode.selection;
                    });
                  },
                  child: Text(l10n!.backToGames),
                ),
              ],
            );
          },
        );
      }
      return;
    }

    setState(() {
      _wrongLeftId = leftId;
      _wrongRightId = rightId;
      _isCheckingMatch = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    setState(() {
      _wrongLeftId = null;
      _wrongRightId = null;
      _selectedLeftId = null;
      _selectedRightId = null;
    });
  }

  void _handleAudioHintTapped(Map<String, dynamic> entry) {
    final lemmaId = entry['lemma_id'].toString();
    if (lemmaId == _audioHintLemmaId) {
      _playAudioHint(lemmaId);
    }
  }

  Future<void> _completeMatchRound() async {
    if (_isMatchCompleted) {
      return;
    }

    _isMatchCompleted = true;
    _matchTimer?.cancel();

    await _saveMatchBestTime(_matchElapsed);

    if (!mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            l10n!.matchCompleted,
            style: const TextStyle(
              fontFamily: 'Centro',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '${l10n!.elapsedTime}: '
            '${_formatDuration(_matchElapsed)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _startMatchRound();
              },
              child: Text(l10n!.playAgain),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _currentMode = GameMode.selection;
                });
              },
              child: Text(l10n!.backToGames),
            ),
          ],
        );
      },
    );
  }
}
