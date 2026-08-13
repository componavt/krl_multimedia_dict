import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'dictionary_repository.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';

enum GameMode { selection, listen, match }

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final DictionaryRepository _repository = DictionaryRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<dynamic> _entries = [];
  bool _isLoading = true;
  GameMode _currentMode = GameMode.selection;
  Object? _loadError;

  Map<String, dynamic>? _listenEntry;
  List<Map<String, dynamic>> _listenChoices = <Map<String, dynamic>>[];
  String? _selectedListenId;
  bool? _listenAnswerIsCorrect;
  int _listenScore = 0;
  int _listenBestScore = 0;
  bool _isListenRoundActive = false;

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

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _loadBestScores();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await _repository.loadEntries();

      if (!mounted) return;
      setState(() {
        _entries = entries;
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
      _listenBestScore = prefs.getInt('game_best_score_mode_a') ?? 0;
      _bestMatchTimeSeconds = prefs.getInt('game_best_time_mode_b') ?? 0;
    });
  }

  Future<void> _saveListenBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    if (score > _listenBestScore) {
      await prefs.setInt('game_best_score_mode_a', score);
      if (!mounted) return;
      setState(() {
        _listenBestScore = score;
      });
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
          content: Text('${l10n.audioPlaybackError}: $e'),
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

  Future<void> _startListenRound() async {
    final l10n = AppLocalizations.of(context);
    final validEntries = _validEntries;
    if (validEntries.length < 4) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notEnoughEntries),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final random = Random();
    final correct = validEntries[random.nextInt(validEntries.length)];
    final choices = <Map<String, dynamic>>[correct];

    final distractors =
        validEntries
            .where(
              (entry) =>
                  entry['lemma_id'].toString() !=
                  correct['lemma_id'].toString(),
            )
            .toList()
          ..shuffle(random);

    choices.addAll(distractors.take(3));
    choices.shuffle(random);

    if (!mounted) return;
    setState(() {
      _listenEntry = correct;
      _listenChoices = choices;
      _selectedListenId = null;
      _listenAnswerIsCorrect = null;
      _isListenRoundActive = true;
    });

    await _playEntryAudio(correct);
  }

  Future<void> _startMatchRound() async {
    final l10n = AppLocalizations.of(context);
    final validEntries = _validEntries;
    if (validEntries.length < 5) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notEnoughEntries),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final random = Random();
    final selectedEntries = <Map<String, dynamic>>[];
    while (selectedEntries.length < 5 && validEntries.isNotEmpty) {
      final entry = validEntries[random.nextInt(validEntries.length)];
      if (!selectedEntries.any(
        (e) => e['lemma_id'].toString() == entry['lemma_id'].toString(),
      )) {
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
      _selectedLeftId = null;
      _selectedRightId = null;
      _wrongLeftId = null;
      _wrongRightId = null;
      _isCheckingMatch = false;
      _isMatchCompleted = false;
    });

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
    return AppPalette.parchment;
  }

  Widget _buildMatchCard({
    required String text,
    required VoidCallback? onTap,
    required bool isSelected,
    required bool isMatched,
    required bool isWrong,
    required Alignment alignment,
  }) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Material(
          color: _matchCardColor(
            isSelected: isSelected,
            isMatched: isMatched,
            isWrong: isWrong,
          ),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: isMatched ? null : onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                text,
                softWrap: true,
                style: const TextStyle(
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _matchTimer?.cancel();
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
              Text(l10n.loading),
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
                  l10n.gameLoadError,
                  style: const TextStyle(fontFamily: 'Open Sans'),
                ),
                const SizedBox(height: 16),
                Text(_loadError.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadEntries,
                  child: Text(l10n.playAgain),
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
                    _startListenRound();
                  },
                  child: Text(
                    l10n.listenAndGuess,
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
                    l10n.matchPairs,
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
          l10n.game,
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
                  if (_currentMode == GameMode.listen && _isListenRoundActive) {
                    _audioPlayer.stop();
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

  Widget _buildListenMode() {
    final l10n = AppLocalizations.of(context);
    if (_listenEntry == null || _listenChoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loading),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            l10n.listenInstruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Open Sans',
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
                      l10n.listen,
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
                          _listenScore++;
                          if (_listenScore > _listenBestScore) {
                            _saveListenBestScore(_listenScore);
                          }
                          Future.delayed(const Duration(seconds: 1), () {
                            if (!mounted) return;
                            _startListenRound();
                          });
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.wrongTryAgain),
                              backgroundColor: AppPalette.brickRed,
                            ),
                          );
                          _playEntryAudio(_listenEntry!);
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
                    l10n.score,
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
                    l10n.bestScore,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Open Sans',
                      color: AppPalette.parchment,
                    ),
                  ),
                  Text(
                    '$_listenBestScore',
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
    if (_leftCards.isEmpty || _rightCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loading),
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
                l10n.matchCompleted,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.game,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Open Sans',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.pairsMatched}: '
                  '$matchedPairs / $totalPairs',
                  style: const TextStyle(fontFamily: 'Open Sans'),
                ),
                Text(
                  '${l10n.elapsedTime}: '
                  '${_formatDuration(_matchElapsed)}',
                  style: const TextStyle(fontFamily: 'Open Sans'),
                ),
                if (_bestMatchTimeSeconds > 0)
                  Text(
                    '${l10n.bestTime}: '
                    '${_formatDuration(Duration(seconds: _bestMatchTimeSeconds))}',
                    style: const TextStyle(fontFamily: 'Open Sans'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.karelianColumn,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Open Sans',
                  ),
                ),
              ),
              for (int i = 0; i < _leftCards.length; i++)
                if (!_matchedIds.contains(_leftCards[i]['lemma_id'].toString()))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildMatchCard(
                      text: _leftCards[i]['lemma'].toString(),
                      onTap: () {
                        _selectLeftCard(_leftCards[i]);
                      },
                      isSelected:
                          _selectedLeftId ==
                          _leftCards[i]['lemma_id'].toString(),
                      isMatched: _matchedIds.contains(
                        _leftCards[i]['lemma_id'].toString(),
                      ),
                      isWrong:
                          _wrongLeftId == _leftCards[i]['lemma_id'].toString(),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.translationColumn,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Open Sans',
                  ),
                ),
              ),
              for (int i = 0; i < _rightCards.length; i++)
                if (!_matchedIds.contains(
                  _rightCards[i]['lemma_id'].toString(),
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildMatchCard(
                      text: _rightCards[i]['meaning_text'].toString(),
                      onTap: () {
                        _selectRightCard(_rightCards[i]);
                      },
                      isSelected:
                          _selectedRightId ==
                          _rightCards[i]['lemma_id'].toString(),
                      isMatched: _matchedIds.contains(
                        _rightCards[i]['lemma_id'].toString(),
                      ),
                      isWrong:
                          _wrongRightId ==
                          _rightCards[i]['lemma_id'].toString(),
                      alignment: Alignment.centerRight,
                    ),
                  ),
            ],
          ),
        ],
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
      setState(() {
        _matchedIds.add(leftId);
        _selectedLeftId = null;
        _selectedRightId = null;
        _isCheckingMatch = false;
      });

      if (_matchedIds.length == _matchEntries.length) {
        await _completeMatchRound();
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
            l10n.matchCompleted,
            style: const TextStyle(
              fontFamily: 'Centro',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '${l10n.elapsedTime}: '
            '${_formatDuration(_matchElapsed)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _startMatchRound();
              },
              child: Text(l10n.playAgain),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _currentMode = GameMode.selection;
                });
              },
              child: Text(l10n.backToGames),
            ),
          ],
        );
      },
    );
  }
}
