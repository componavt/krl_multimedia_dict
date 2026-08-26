import 'package:flutter/material.dart';

import '../../../../app_theme.dart';

class MatchStatusPanel extends StatelessWidget {
  const MatchStatusPanel({
    super.key,
    required this.matchedCount,
    required this.totalCount,
  });

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
            valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.amber),
            minHeight: 12,
          ),
        ),
      ],
    );
  }
}
