import 'package:flutter/material.dart';

import '../../../../app_theme.dart';
import '../../core/game_entry.dart';
import 'replay_border_sheen.dart';

class ListenChoiceCard extends StatelessWidget {
  const ListenChoiceCard({
    super.key,
    required this.gameEntry,
    required this.color,
    required this.isSelected,
    required this.isCorrect,
    required this.showLemma,
    required this.onTap,
    required this.celebrationAnimation,
    required this.sheenAnimation,
  });

  final GameEntry gameEntry;
  final Color color;
  final bool isSelected;
  final bool isCorrect;
  final bool showLemma;
  final VoidCallback? onTap;
  final Animation<double> celebrationAnimation;
  final Animation<double> sheenAnimation;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 280),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          _wrapCorrectChoiceCelebration(
            isCorrectChoice: isCorrect,
            animation: celebrationAnimation,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                backgroundColor: color,
                textStyle: const TextStyle(
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w600,
                  color: AppPalette.parchment,
                ),
              ),
              onPressed: onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gameEntry.meaning,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showLemma) ...[
                    const SizedBox(height: 6),
                    Text(
                      gameEntry.lemma,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isCorrect)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: sheenAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ReplayBorderSheen(
                        progress: sheenAnimation.value,
                        borderRadius: 10,
                        color: AppPalette.parchment,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _wrapCorrectChoiceCelebration({
    required bool isCorrectChoice,
    required Animation<double> animation,
    required Widget child,
  }) {
    if (!isCorrectChoice || !animation.isAnimating) {
      return child;
    }

    final correctScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.035), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.035, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    final correctRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.026), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.026, end: -0.018), weight: 40),
      TweenSequenceItem(tween: Tween(begin: -0.018, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, card) {
        return Transform.rotate(
          angle: correctRotation.value,
          child: Transform.scale(scale: correctScale.value, child: card),
        );
      },
    );
  }
}
