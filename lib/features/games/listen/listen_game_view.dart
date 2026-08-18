import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'listen_game_controller.dart';
import 'listen_game_state.dart';
import 'widgets/listen_choice_card.dart';
import 'widgets/listen_replay_button.dart';
import 'widgets/streak_archive_mark.dart';
import '../core/game_entry.dart';

class ListenGameView extends StatefulWidget {
  const ListenGameView({super.key, required this.controller});

  final ListenGameController controller;

  @override
  State<ListenGameView> createState() => _ListenGameViewState();
}

class _ListenGameViewState extends State<ListenGameView>
    with TickerProviderStateMixin<ListenGameView> {
  late final AnimationController _targetReplaySheenController;
  late final AnimationController _correctChoiceController;

  @override
  void initState() {
    super.initState();
    _targetReplaySheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _correctChoiceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    widget.controller.initialize();
    widget.controller.addListener(_syncAnimationsWithState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncAnimationsWithState);
    _targetReplaySheenController.dispose();
    _correctChoiceController.dispose();
    super.dispose();
  }

  void _syncAnimationsWithState() {
    final state = widget.controller.state;

    if (state.isTargetReplayHighlighted) {
      if (!_targetReplaySheenController.isAnimating) {
        _targetReplaySheenController.repeat();
      }
    } else {
      _targetReplaySheenController
        ..stop()
        ..reset();
    }

    if (state.isCorrectChoiceCelebrating) {
      if (!_correctChoiceController.isAnimating) {
        _correctChoiceController.forward(from: 0);
      }
    } else {
      _correctChoiceController
        ..stop()
        ..reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final l10n = AppLocalizations.of(context);

        if (state.isError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.gameLoadError,
                    style: const TextStyle(fontFamily: 'Open Sans'),
                  ),
                  const SizedBox(height: 16),
                  Text(state.loadError.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      widget.controller.resetSession();
                    },
                    child: Text(l10n.playAgain),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.isLoading) {
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

        if (state.isSessionCompleted) {
          return _buildSessionComplete(l10n, state);
        }

        return _buildListenMode(l10n, state);
      },
    );
  }

  Widget _buildSessionComplete(AppLocalizations l10n, ListenGameState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.listenAndGuess,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Open Sans',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.scoreOutOf(state.score, 10),
              style: const TextStyle(fontFamily: 'Open Sans'),
            ),
            if (state.streak > 1)
              Text(
                l10n.currentStreak(state.streak),
                style: const TextStyle(fontFamily: 'Open Sans'),
              ),
            if (state.bestStreak > 1)
              Text(
                l10n.bestStreakLabel(state.bestStreak),
                style: const TextStyle(fontFamily: 'Open Sans'),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                widget.controller.resetSession();
              },
              child: Text(l10n.playAgain),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                widget.controller.startSession();
              },
              child: Text(l10n.backToGames),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListenMode(AppLocalizations l10n, ListenGameState state) {
    final round = state.currentRound!;
    final progress = round.roundNumber / 10;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${l10n.archiveCard}: ${round.roundNumber + 1} / 10',
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
              valueColor: AlwaysStoppedAnimation<Color>(
                _listenProgressColor(round.roundNumber),
              ),
              minHeight: 12,
            ),
          ),
          if (state.hadWrongAttempt)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppPalette.parchment,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPalette.amber, width: 1.2),
              ),
              child: Text(
                round.target.lemma,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppPalette.ink,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListenReplayButton(
                onPressed: state.isRoundActive
                    ? () async {
                        await widget.controller.audioPlayer.play(
                          round.target.lemmaId,
                        );
                      }
                    : null,
                isTargetReplayHighlighted: state.isTargetReplayHighlighted,
                sheenAnimation: _targetReplaySheenController,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.listenMeaningQuestion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppPalette.ink,
            ),
          ),
          const SizedBox(height: 24),
          IgnorePointer(
            ignoring: state.isFeedbackInProgress,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: round.choices.map((choice) {
                final isSelected = state.selectedEntryId == choice.lemmaId;
                final isCorrectChoice =
                    state.answerIsCorrect == true && isSelected;
                final isWrongChoice =
                    state.answerIsCorrect == false && isSelected;
                final shouldShowLemma = isWrongChoice || isCorrectChoice;

                return ListenChoiceCard(
                  key: Key('choice-${choice.lemmaId}'),
                  gameEntry: choice,
                  color: _listenChoiceColor(choice, state),
                  isSelected: isSelected,
                  isCorrect: isCorrectChoice,
                  showLemma: shouldShowLemma,
                  sheenAnimation: _sheenAnimationForChoice(
                    state,
                    choice,
                    _targetReplaySheenController,
                  ),
                  celebrationAnimation: isCorrectChoice
                      ? _correctChoiceController
                      : _correctChoiceController,
                  onTap: () => widget.controller.choose(choice),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    l10n.scoreOutOf(state.score, 10),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Open Sans',
                      color: AppPalette.parchment,
                    ),
                  ),
                  Text(
                    '${state.score}',
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
                    l10n.currentStreak(state.streak),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Open Sans',
                      color: AppPalette.parchment,
                    ),
                  ),
                  Text(
                    '${state.streak}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      fontFamily: 'Open Sans',
                      color: AppPalette.parchment,
                    ),
                  ),
                  StreakArchiveMark(streak: state.streak),
                ],
              ),
              if (state.bestStreak > 0)
                Column(
                  children: [
                    Text(
                      l10n.bestStreakLabel(state.bestStreak),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Open Sans',
                        color: AppPalette.parchment,
                      ),
                    ),
                    Text(
                      '${state.bestStreak}',
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

  Color _listenChoiceColor(GameEntry choice, ListenGameState state) {
    if (state.answerIsCorrect == true &&
        choice.lemmaId == state.selectedEntryId) {
      return AppPalette.mossGreen;
    }

    if (state.answerIsCorrect == false &&
        choice.lemmaId == state.selectedEntryId) {
      return AppPalette.brickRed;
    }

    return AppPalette.mutedBrown;
  }

  Color _listenProgressColor(int roundNumber) {
    final progress = roundNumber / 10;
    if (progress >= 1.0) return AppPalette.mossGreen;
    if (progress >= 0.7) return AppPalette.amber;
    return AppPalette.parchment;
  }

  Animation<double> _sheenAnimationForChoice(
    ListenGameState state,
    GameEntry choice,
    AnimationController controller,
  ) {
    if (state.answerIsCorrect == true &&
        choice.lemmaId == state.selectedEntryId) {
      return state.isCorrectChoiceCelebrating
          ? _correctChoiceController
          : _correctChoiceController;
    }
    return AlwaysStoppedAnimation<double>(0);
  }
}
