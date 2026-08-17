// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Karelian Multimedia Dictionary';

  @override
  String get searchHint => 'Search';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get menuTitle => 'Menu';

  @override
  String get play => 'Play';

  @override
  String get searchMode => 'Search mode';

  @override
  String get searchAtStart => 'At the beginning';

  @override
  String get searchInside => 'Inside the word';

  @override
  String get searchAtEnd => 'At the end';

  @override
  String get about => 'About';

  @override
  String get switchToRussian => 'русский';

  @override
  String get switchToEnglish => 'English';

  @override
  String get noResults => 'No results found';

  @override
  String get searchHistory => 'Search history';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get listenAndGuess => 'Listen and guess';

  @override
  String get matchPairs => 'Match pairs';

  @override
  String get game => 'Game';

  @override
  String get listenInstruction =>
      'Listen to the word and choose the correct answer';

  @override
  String get listen => 'Listen';

  @override
  String get archiveCard => 'Archive card';

  @override
  String get listenMeaningQuestion => 'What does this word mean?';

  @override
  String listenCorrectAssociation(Object lemma, Object meaning) {
    return '$lemma — $meaning';
  }

  @override
  String get score => 'Score';

  @override
  String get bestScore => 'Best score';

  @override
  String get bestTime => 'Best time';

  @override
  String get loading => 'Loading...';

  @override
  String get notEnoughEntries => 'Not enough dictionary entries';

  @override
  String get audioPreparing => 'Preparing audio archive...';

  @override
  String get wrongTryAgain => 'Incorrect. Listen again.';

  @override
  String get correct => 'Correct!';

  @override
  String get noMatch => 'The pair does not match';

  @override
  String get matchCompleted => 'All pairs matched!';

  @override
  String get playAgain => 'Play again';

  @override
  String get backToGames => 'Back to games';

  @override
  String get back => 'Back';

  @override
  String get dictionaryLoadError => 'Failed to load dictionary';

  @override
  String get gameLoadError => 'Failed to load game data';

  @override
  String get audioPlaybackError => 'Audio playback error';

  @override
  String get partOfSpeech => 'part of speech';

  @override
  String get meanings => 'meanings';

  @override
  String get aboutDescription =>
      'An audio dictionary of the Livvi dialect of the Karelian language.';

  @override
  String get dictionarySource => 'Dictionary data source:';

  @override
  String get versionLabel => 'Version';

  @override
  String get pairsMatched => 'Matched pairs';

  @override
  String get elapsedTime => 'Time';

  @override
  String get karelianColumn => 'Karelian';

  @override
  String get translationColumn => 'Russian';

  @override
  String get learningStatistics => 'Statistics';

  @override
  String get statisticsLoadError => 'Failed to load statistics';

  @override
  String get myWordArchive => 'My Word Archive';

  @override
  String get wordsEncountered => 'Words encountered';

  @override
  String get wordsLearned => 'Words learned';

  @override
  String get confidentWords => 'Confident words';

  @override
  String get needsReview => 'Needs review';

  @override
  String get currentSession => 'Current session';

  @override
  String get previousSession => 'Previous session';

  @override
  String get restoredCards => 'Restored cards';

  @override
  String get firstAttemptCorrect => 'First-attempt correct';

  @override
  String get newlyLearned => 'Newly learned';

  @override
  String get noLearningDataYet => 'No learning data yet. Start playing!';

  @override
  String get restoredPairs => 'Restored pairs';

  @override
  String get pairsMatchedTotal => 'Pairs matched';

  @override
  String get wordsReinforced => 'Words reinforced';

  @override
  String get textSize => 'Text size';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeMedium => 'Medium';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get hint => 'Hint';

  @override
  String hintCharacters(Object count) {
    return '$count characters';
  }

  @override
  String hintStartsWith(Object letter) {
    return 'starts with \'$letter\'';
  }

  @override
  String hintPattern(Object pattern) {
    return '$pattern';
  }

  @override
  String wrongChoiceMeaning(Object lemma, Object meaning) {
    return '$lemma means $meaning';
  }

  @override
  String get sessionCompleted => 'Session Completed';

  @override
  String get restoreArchiveCard => 'Restore the archive card';

  @override
  String get cardsNeedReview => 'Cards needing review';

  @override
  String scoreOutOf(Object score, Object total) {
    return 'Score: $score / $total';
  }

  @override
  String currentStreak(Object count) {
    return 'Streak: $count';
  }

  @override
  String bestStreakLabel(Object count) {
    return 'Best streak: $count';
  }
}
