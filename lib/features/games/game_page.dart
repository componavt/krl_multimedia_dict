import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../word_learning_repository.dart';
import 'listen/listen_game_controller.dart';
import 'listen/listen_game_view.dart';
import 'match/match_game_controller.dart';
import 'match/match_game_view.dart';
import 'core/game_id.dart';
import 'core/game_catalog.dart';
import 'core/game_catalog_impl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../locale_controller.dart';
import '../../../text_scale_controller.dart';

import 'core/game_audio_player_impl.dart';

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

class _GamePageState extends State<GamePage> {
  late final GameCatalog _catalog;
  late final GameAudioPlayerImpl _audioPlayer;
  late final WordLearningRepository _learningRepository;
  late final Random _random = Random();

  GameId _currentMode = GameId.selection;
  ListenGameController? _listenController;
  MatchGameController? _matchController;

  @override
  void initState() {
    super.initState();
    _catalog = GameCatalogImpl();
    _audioPlayer = GameAudioPlayerImpl();
    _learningRepository = WordLearningRepository();
  }

  @override
  void dispose() {
    _listenController?.dispose();
    _matchController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final children = <Widget>[];
    if (_currentMode == GameId.selection) {
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
                  onPressed: () => _startListenGame(l10n),
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
                  onPressed: () => _startMatchGame(l10n),
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
    } else if (_currentMode == GameId.listen) {
      children.add(Expanded(child: _listenView(l10n)));
    } else if (_currentMode == GameId.match) {
      children.add(Expanded(child: _matchView(l10n)));
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
        leading: _currentMode != GameId.selection
            ? IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  _stopCurrentGameAndReturn();
                },
              )
            : null,
      ),
      body: Column(children: children),
    );
  }

  Widget _listenView(AppLocalizations l10n) {
    final controller = _listenController;

    if (controller == null) {
      return const SizedBox.shrink();
    }

    return ListenGameView(controller: controller);
  }

  Widget _matchView(AppLocalizations l10n) {
    final controller = _matchController;

    if (controller == null) {
      return const SizedBox.shrink();
    }

    return MatchGameView(controller: controller);
  }

  Future<void> _startListenGame(AppLocalizations l10n) async {
    try {
      final controller = _listenController ??= ListenGameController(
        catalog: _catalog,
        audioPlayer: _audioPlayer,
        learningRepository: _learningRepository,
        random: _random,
      );

      await controller.startSession();

      if (!mounted) return;

      setState(() {
        _currentMode = GameId.listen;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.gameLoadError}: $error'),
          backgroundColor: AppPalette.brickRed,
        ),
      );
    }
  }

  Future<void> _startMatchGame(AppLocalizations l10n) async {
    try {
      final controller = _matchController ??= MatchGameController(
        catalog: _catalog,
        audioPlayer: _audioPlayer,
        learningRepository: _learningRepository,
        random: _random,
      );

      await controller.startRound();

      if (!mounted) return;

      setState(() {
        _currentMode = GameId.match;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.gameLoadError}: $error'),
          backgroundColor: AppPalette.brickRed,
        ),
      );
    }
  }

  Future<void> _stopCurrentGameAndReturn() async {
    await _audioPlayer.stop();

    _listenController?.dispose();
    _matchController?.dispose();

    _listenController = null;
    _matchController = null;

    if (!mounted) return;

    setState(() {
      _currentMode = GameId.selection;
    });
  }
}
