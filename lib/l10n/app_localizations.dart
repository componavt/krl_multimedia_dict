import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Karelian Multimedia Dictionary'**
  String get appTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @searchMode.
  ///
  /// In en, this message translates to:
  /// **'Search mode'**
  String get searchMode;

  /// No description provided for @searchAtStart.
  ///
  /// In en, this message translates to:
  /// **'At the beginning'**
  String get searchAtStart;

  /// No description provided for @searchInside.
  ///
  /// In en, this message translates to:
  /// **'Inside the word'**
  String get searchInside;

  /// No description provided for @searchAtEnd.
  ///
  /// In en, this message translates to:
  /// **'At the end'**
  String get searchAtEnd;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @switchToRussian.
  ///
  /// In en, this message translates to:
  /// **'русский'**
  String get switchToRussian;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get switchToEnglish;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search history'**
  String get searchHistory;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @listenAndGuess.
  ///
  /// In en, this message translates to:
  /// **'Listen and guess'**
  String get listenAndGuess;

  /// No description provided for @matchPairs.
  ///
  /// In en, this message translates to:
  /// **'Match pairs'**
  String get matchPairs;

  /// No description provided for @game.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// No description provided for @listenInstruction.
  ///
  /// In en, this message translates to:
  /// **'Listen to the word and choose the correct answer'**
  String get listenInstruction;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @archiveCard.
  ///
  /// In en, this message translates to:
  /// **'Archive card'**
  String get archiveCard;

  /// Question prompt shown before player answers a listening comprehension round
  ///
  /// In en, this message translates to:
  /// **'What does this word mean?'**
  String get listenMeaningQuestion;

  /// Association shown after correct answer, with lemma and meaning separated by em dash
  ///
  /// In en, this message translates to:
  /// **'{lemma} — {meaning}'**
  String listenCorrectAssociation(Object lemma, Object meaning);

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score'**
  String get bestScore;

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best time'**
  String get bestTime;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @notEnoughEntries.
  ///
  /// In en, this message translates to:
  /// **'Not enough dictionary entries'**
  String get notEnoughEntries;

  /// No description provided for @audioPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing audio archive...'**
  String get audioPreparing;

  /// No description provided for @wrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Incorrect. Listen again.'**
  String get wrongTryAgain;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'The pair does not match'**
  String get noMatch;

  /// No description provided for @matchCompleted.
  ///
  /// In en, this message translates to:
  /// **'All pairs matched!'**
  String get matchCompleted;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @backToGames.
  ///
  /// In en, this message translates to:
  /// **'Back to games'**
  String get backToGames;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @dictionaryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dictionary'**
  String get dictionaryLoadError;

  /// No description provided for @gameLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load game data'**
  String get gameLoadError;

  /// No description provided for @audioPlaybackError.
  ///
  /// In en, this message translates to:
  /// **'Audio playback error'**
  String get audioPlaybackError;

  /// No description provided for @partOfSpeech.
  ///
  /// In en, this message translates to:
  /// **'part of speech'**
  String get partOfSpeech;

  /// No description provided for @meanings.
  ///
  /// In en, this message translates to:
  /// **'meanings'**
  String get meanings;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'An audio dictionary of the Livvi dialect of the Karelian language.'**
  String get aboutDescription;

  /// No description provided for @dictionarySource.
  ///
  /// In en, this message translates to:
  /// **'Dictionary data source:'**
  String get dictionarySource;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @pairsMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched pairs'**
  String get pairsMatched;

  /// No description provided for @elapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get elapsedTime;

  /// No description provided for @karelianColumn.
  ///
  /// In en, this message translates to:
  /// **'Karelian'**
  String get karelianColumn;

  /// No description provided for @translationColumn.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get translationColumn;

  /// No description provided for @learningStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get learningStatistics;

  /// No description provided for @statisticsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load statistics'**
  String get statisticsLoadError;

  /// No description provided for @myWordArchive.
  ///
  /// In en, this message translates to:
  /// **'My Word Archive'**
  String get myWordArchive;

  /// No description provided for @wordsEncountered.
  ///
  /// In en, this message translates to:
  /// **'Words encountered'**
  String get wordsEncountered;

  /// No description provided for @wordsLearned.
  ///
  /// In en, this message translates to:
  /// **'Words learned'**
  String get wordsLearned;

  /// No description provided for @confidentWords.
  ///
  /// In en, this message translates to:
  /// **'Confident words'**
  String get confidentWords;

  /// No description provided for @needsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get needsReview;

  /// No description provided for @currentSession.
  ///
  /// In en, this message translates to:
  /// **'Current session'**
  String get currentSession;

  /// No description provided for @previousSession.
  ///
  /// In en, this message translates to:
  /// **'Previous session'**
  String get previousSession;

  /// No description provided for @restoredCards.
  ///
  /// In en, this message translates to:
  /// **'Restored cards'**
  String get restoredCards;

  /// No description provided for @firstAttemptCorrect.
  ///
  /// In en, this message translates to:
  /// **'First-attempt correct'**
  String get firstAttemptCorrect;

  /// No description provided for @newlyLearned.
  ///
  /// In en, this message translates to:
  /// **'Newly learned'**
  String get newlyLearned;

  /// No description provided for @noLearningDataYet.
  ///
  /// In en, this message translates to:
  /// **'No learning data yet. Start playing!'**
  String get noLearningDataYet;

  /// No description provided for @restoredPairs.
  ///
  /// In en, this message translates to:
  /// **'Restored pairs'**
  String get restoredPairs;

  /// No description provided for @pairsMatchedTotal.
  ///
  /// In en, this message translates to:
  /// **'Pairs matched'**
  String get pairsMatchedTotal;

  /// No description provided for @wordsReinforced.
  ///
  /// In en, this message translates to:
  /// **'Words reinforced'**
  String get wordsReinforced;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @textSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSizeSmall;

  /// No description provided for @textSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get textSizeMedium;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @hintCharacters.
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String hintCharacters(Object count);

  /// No description provided for @hintStartsWith.
  ///
  /// In en, this message translates to:
  /// **'starts with \'{letter}\''**
  String hintStartsWith(Object letter);

  /// No description provided for @hintPattern.
  ///
  /// In en, this message translates to:
  /// **'{pattern}'**
  String hintPattern(Object pattern);

  /// No description provided for @wrongChoiceMeaning.
  ///
  /// In en, this message translates to:
  /// **'{lemma} means {meaning}'**
  String wrongChoiceMeaning(Object lemma, Object meaning);

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Session Completed'**
  String get sessionCompleted;

  /// No description provided for @restoreArchiveCard.
  ///
  /// In en, this message translates to:
  /// **'Restore the archive card'**
  String get restoreArchiveCard;

  /// No description provided for @cardsNeedReview.
  ///
  /// In en, this message translates to:
  /// **'Cards needing review'**
  String get cardsNeedReview;

  /// No description provided for @scoreOutOf.
  ///
  /// In en, this message translates to:
  /// **'Score: {score} / {total}'**
  String scoreOutOf(Object score, Object total);

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak: {count}'**
  String currentStreak(Object count);

  /// No description provided for @bestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Best streak: {count}'**
  String bestStreakLabel(Object count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
