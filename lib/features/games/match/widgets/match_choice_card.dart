import 'package:flutter/material.dart';

import '../../../../app_theme.dart';
import '../../core/game_entry.dart';
import '../../core/game_models.dart';

class MatchChoiceCard extends StatelessWidget {
  const MatchChoiceCard({
    super.key,
    required this.gameEntry,
    required this.column,
    required this.onTap,
    required this.isSelected,
    required this.isMatched,
    required this.isWrong,
    required this.backgroundColor,
    this.audioHintEntryId,
  });

  final GameEntry gameEntry;
  final MatchCardColumn column;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isMatched;
  final bool isWrong;
  final Color backgroundColor;
  final String? audioHintEntryId;

  @override
  Widget build(BuildContext context) {
    final Color cardColor = _cardColor;
    final displayText = _getDisplayText();

    final cardContent = InkWell(
      onTap: isMatched ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                displayText,
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (audioHintEntryId != null &&
                audioHintEntryId == gameEntry.lemmaId)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.hearing, size: 16, color: AppPalette.amber),
              ),
          ],
        ),
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        child: cardContent,
      ),
    );
  }

  String _getDisplayText() {
    switch (column) {
      case MatchCardColumn.karelian:
        return gameEntry.lemma;
      case MatchCardColumn.russian:
        return gameEntry.meaning;
    }
  }

  Color get _cardColor {
    if (isMatched) {
      return AppPalette.mossGreen;
    }
    if (isWrong) {
      return AppPalette.brickRed;
    }
    if (isSelected) {
      return AppPalette.amber;
    }
    return backgroundColor;
  }
}
