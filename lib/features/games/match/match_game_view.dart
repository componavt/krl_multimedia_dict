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

const String _karelianZoneKey = 'match_karelian_zone';
const String _russianZoneKey = 'match_russian_zone';
const String _matchedPairsFooterKey = 'matched_pairs_footer';

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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: MatchStatusPanel(
            elapsedTime: state.elapsedTime,
            bestTimeSeconds: state.bestTimeSeconds,
            matchedCount: state.matchedPairs.length,
            totalCount: 5,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: KeyedSubtree(
                      key: Key(_karelianZoneKey),
                      child: _buildMatchZone(
                        title: l10n.karelianColumn,
                        backgroundColor: AppPalette.karelianPanel,
                        cards: state.leftCards ?? <GameEntry>[],
                        isLeftSide: true,
                        state: state,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: KeyedSubtree(
                      key: Key(_russianZoneKey),
                      child: _buildMatchZone(
                        title: l10n.translationColumn,
                        backgroundColor: AppPalette.translationPanel,
                        cards: state.rightCards ?? <GameEntry>[],
                        isLeftSide: false,
                        state: state,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: true,
          child: KeyedSubtree(
            key: Key(_matchedPairsFooterKey),
            child: MatchedPairsFooter(matchedPairs: state.matchedPairs),
          ),
        ),
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
    final visibleCards = cards.where((card) {
      return !state.matchedPairs.any((p) => p.id == card.lemmaId);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Open Sans',
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...visibleCards.map(
          (card) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MatchChoiceCard(
              gameEntry: card,
              column: isLeftSide
                  ? MatchCardColumn.karelian
                  : MatchCardColumn.russian,
              onTap: () {
                if (isLeftSide) {
                  widget.controller.selectLeft(card);
                } else {
                  widget.controller.selectRight(card);
                }
              },
              isSelected: isLeftSide
                  ? state.selectedLeftId == card.lemmaId
                  : state.selectedRightId == card.lemmaId,
              isMatched: false,
              isWrong: isLeftSide
                  ? state.wrongLeftId == card.lemmaId
                  : state.wrongRightId == card.lemmaId,
              backgroundColor: backgroundColor,
              audioHintEntryId: !isLeftSide && state.hintEntryId == card.lemmaId
                  ? state.hintEntryId
                  : null,
            ),
          ),
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
