import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'l10n/app_localizations.dart';
import 'word_learning_repository.dart';
import 'word_learning_record.dart';

class LearningStatisticsPage extends StatefulWidget {
  const LearningStatisticsPage({super.key});

  @override
  State<LearningStatisticsPage> createState() => _LearningStatisticsPageState();
}

class _LearningStatisticsPageState extends State<LearningStatisticsPage> {
  final WordLearningRepository _repository = WordLearningRepository();
  late Future<LearningStatistics> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _statisticsFuture = _repository.getStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppPalette.archiveSurface,
        title: Text(
          l10n.learningStatistics,
          style: const TextStyle(
            fontFamily: 'Centro',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppPalette.parchment,
          ),
        ),
      ),
      body: FutureBuilder<LearningStatistics>(
        future: _statisticsFuture,
        builder: (BuildContext context, AsyncSnapshot<LearningStatistics> snapshot) {
          if (snapshot.hasError) {
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
                      l10n.statisticsLoadError,
                      style: const TextStyle(fontFamily: 'Open Sans'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data!;

          return ScrollableProvider(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.myWordArchive,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Open Sans',
                      color: AppPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppPalette.parchment,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppPalette.amber, width: 1.2),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(
                          l10n.wordsEncountered,
                          '${stats.totalWordsWithAtLeastOneCorrect}',
                        ),
                        _buildStatRow(
                          l10n.wordsLearned,
                          '${stats.wordsLearned}',
                        ),
                        _buildStatRow(
                          l10n.confidentWords,
                          '${stats.wordsConfident}',
                        ),
                        _buildStatRow(
                          l10n.needsReview,
                          '${stats.wordsNeedingReview}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (stats.activeSession != null) ...[
                    Text(
                      l10n.currentSession,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Open Sans',
                        color: AppPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppPalette.parchment,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppPalette.amber, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          _buildStatRow(
                            l10n.restoredCards,
                            '${stats.activeSession!.completedRounds} / 10',
                          ),
                          _buildStatRow(
                            l10n.firstAttemptCorrect,
                            '${stats.activeSession!.firstAttemptCorrectRounds}',
                          ),
                          _buildStatRow(
                            l10n.needsReview,
                            '${stats.activeSession!.roundsWithMistakes}',
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (stats.previousSession != null) ...[
                    Text(
                      l10n.previousSession,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Open Sans',
                        color: AppPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppPalette.parchment,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppPalette.amber, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          _buildStatRow(
                            l10n.restoredCards,
                            '${stats.previousSession!.completedRounds} / 10',
                          ),
                          _buildStatRow(
                            l10n.newlyLearned,
                            '${stats.previousSession!.newlyLearnedWordIds.length}',
                          ),
                          _buildStatRow(
                            l10n.needsReview,
                            '${stats.previousSession!.needingReviewWordIds.length}',
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (stats.activeSession == null &&
                      stats.previousSession == null) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppPalette.parchment,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppPalette.amber, width: 1.2),
                      ),
                      child: Text(
                        l10n.noLearningDataYet,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w700,
              color: AppPalette.mutedBrown,
            ),
          ),
        ],
      ),
    );
  }
}

class ScrollableProvider extends InheritedWidget {
  const ScrollableProvider({super.key, required super.child});

  static ScrollableProvider of(BuildContext context) {
    final ScrollableProvider? result = context
        .dependOnInheritedWidgetOfExactType<ScrollableProvider>();
    assert(result != null, 'No ScrollableProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ScrollableProvider oldDelegate) => false;
}
