import 'package:flutter/material.dart';

import '../../../../app_theme.dart';

class StreakArchiveMark extends StatelessWidget {
  const StreakArchiveMark({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    if (streak < 3) {
      return const SizedBox.shrink();
    }

    final stars = streak >= 8
        ? '***'
        : streak >= 5
        ? '**'
        : '*';

    return Text(
      stars,
      style: const TextStyle(
        color: AppPalette.amber,
        fontFamily: 'Centro',
        fontWeight: FontWeight.w700,
        letterSpacing: 3,
      ),
    );
  }
}
