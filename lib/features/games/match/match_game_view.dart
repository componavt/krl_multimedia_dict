import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'match_game_controller.dart';
import 'match_game_state.dart';
import 'widgets/match_choice_card.dart';
import 'widgets/matched_pairs_footer.dart';
import 'widgets/match_status_panel.dart';
import '../core/game_entry.dart';
import '../core/game_models.dart';

class MatchGameView extends StatefulWidget {
  const MatchGameView({
    super.key,
    required this.controller,
    required this.onExit,
  });

  final MatchGameController controller;
  final VoidCallback onExit;

  @override
  State<MatchGameView> createState() => _MatchGameViewState();
}

class _MatchGameViewState extends State<MatchGameView> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
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
                      widget.controller.startRound();
                    },
                    child: Text(l10n.playAgain),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.isSessionCompleted) {
          return _buildMatchComplete(l10n, state);
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

        return _buildMatchMode(l10n, state);
      },
    );
  }

  Widget _buildMatchComplete(AppLocalizations l10n, MatchGameState state) {
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
            const SizedBox(height: 16),
            Text(
              '${l10n.elapsedTime}: ${_formatDuration(state.elapsedTime)}',
              style: const TextStyle(fontFamily: 'Open Sans'),
            ),
            if (state.bestTimeSeconds != null && state.bestTimeSeconds! > 0)
              Text(
                'Best: ${_formatDuration(Duration(seconds: state.bestTimeSeconds!))}',
                style: const TextStyle(fontFamily: 'Open Sans'),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                widget.controller.startRound();
              },
              child: Text(l10n.playAgain),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                widget.onExit();
              },
              child: Text(l10n.backToGames),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchMode(AppLocalizations l10n, MatchGameState state) {
    return Column(
      children: [
        MatchStatusPanel(
          elapsedTime: state.elapsedTime,
          bestTimeSeconds: state.bestTimeSeconds,
          matchedCount: state.matchedPairs.length,
          totalCount: 5,
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildMatchZone(
                    title: l10n.karelianColumn,
                    backgroundColor: AppPalette.karelianPanel,
                    cards: state.leftCards ?? <GameEntry>[],
                    isLeftSide: true,
                    state: state,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMatchZone(
                    title: l10n.translationColumn,
                    backgroundColor: AppPalette.translationPanel,
                    cards: state.rightCards ?? <GameEntry>[],
                    isLeftSide: false,
                    state: state,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: MatchedPairsFooter(matchedPairs: state.matchedPairs)),
      ],
    );
  }

  Widget _buildMatchZone({
    required String title,
    required Color backgroundColor,
    required List<GameEntry> cards,
    required bool isLeftSide,
    required MatchGameState state,
  }) {
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            final cardId = card.lemmaId;

            if (state.matchedPairs.any((p) => p.id == cardId)) {
              return const SizedBox.shrink();
            }

            if (isLeftSide) {
              return MatchChoiceCard(
                gameEntry: card,
                column: MatchCardColumn.karelian,
                onTap: () {
                  widget.controller.selectLeft(card);
                },
                isSelected: state.selectedLeftId == cardId,
                isMatched: false,
                isWrong: state.wrongLeftId == cardId,
                backgroundColor: backgroundColor,
              );
            } else {
              return MatchChoiceCard(
                gameEntry: card,
                column: MatchCardColumn.russian,
                onTap: () {
                  widget.controller.selectRight(card);
                },
                isSelected: state.selectedRightId == cardId,
                isMatched: false,
                isWrong: state.wrongRightId == cardId,
                backgroundColor: backgroundColor,
                audioHintEntryId: state.hintEntryId,
              );
            }
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
