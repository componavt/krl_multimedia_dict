import 'package:flutter/material.dart';

import '../../../../app_theme.dart';

class MatchStatusPanel extends StatelessWidget {
  const MatchStatusPanel({
    super.key,
    required this.elapsedTime,
    required this.bestTimeSeconds,
    required this.matchedCount,
    required this.totalCount,
  });

  final Duration elapsedTime;
  final int? bestTimeSeconds;
  final int matchedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final progress = matchedCount / totalCount;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$matchedCount / $totalCount',
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
            valueColor: AlwaysStoppedAnimation<Color>(_progressColor(progress)),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatDuration(elapsedTime),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Open Sans',
            color: AppPalette.parchment,
          ),
        ),
        if (bestTimeSeconds != null && bestTimeSeconds! > 0)
          Text(
            'Best: ${_formatDuration(Duration(seconds: bestTimeSeconds!))}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Open Sans',
              color: AppPalette.amber,
            ),
          ),
      ],
    );
  }

  Color _progressColor(double progress) {
    if (progress >= 1.0) return AppPalette.mossGreen;
    if (progress >= 0.7) return AppPalette.amber;
    return AppPalette.parchment;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
