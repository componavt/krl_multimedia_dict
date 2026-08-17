import 'package:flutter/material.dart';

import '../../../../app_theme.dart';
import 'replay_border_sheen.dart';

class ListenReplayButton extends StatelessWidget {
  const ListenReplayButton({
    super.key,
    required this.onPressed,
    required this.isTargetReplayHighlighted,
    required this.sheenAnimation,
  });

  final VoidCallback? onPressed;
  final bool isTargetReplayHighlighted;
  final Animation<double> sheenAnimation;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: isTargetReplayHighlighted ? const [] : const [],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.mutedBrown,
                  foregroundColor: AppPalette.parchment,
                ),
                onPressed: onPressed,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 24),
                    const SizedBox(width: 8),
                    Text('Listen'),
                  ],
                ),
              ),
            ),
            if (isTargetReplayHighlighted)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: sheenAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ReplayBorderSheen(
                          progress: sheenAnimation.value,
                          borderRadius: 10,
                          color: AppPalette.amber,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
