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
}
