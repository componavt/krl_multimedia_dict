import 'package:flutter/material.dart';

import '../../../../app_theme.dart';
import '../../core/game_models.dart';

class MatchedPairsFooter extends StatelessWidget {
  const MatchedPairsFooter({super.key, required this.matchedPairs});

  final List<MatchedPair> matchedPairs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppPalette.archiveSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restored Pairs',
            style: const TextStyle(
              color: AppPalette.parchment,
              fontWeight: FontWeight.w600,
              fontFamily: 'Open Sans',
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              itemCount: matchedPairs.length,
              itemBuilder: (context, index) {
                final pair = matchedPairs[index];

                return AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  offset: Offset.zero,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            pair.lemma,
                            style: const TextStyle(
                              color: AppPalette.parchment,
                              fontFamily: 'Open Sans',
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppPalette.amber,
                        ),
                        Expanded(
                          child: Text(
                            pair.meaning,
                            style: const TextStyle(
                              color: AppPalette.parchment,
                              fontFamily: 'Open Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
