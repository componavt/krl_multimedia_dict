// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Karelian Multimedia Dictionary';

  @override
  String get searchHint => 'Поиск';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get menuTitle => 'Меню';

  @override
  String get play => 'Играть';

  @override
  String get searchMode => 'Режим поиска';

  @override
  String get searchAtStart => 'В начале слова';

  @override
  String get searchInside => 'Внутри слова';

  @override
  String get searchAtEnd => 'В конце слова';

  @override
  String get about => 'О приложении';

  @override
  String get switchToRussian => 'русский';

  @override
  String get switchToEnglish => 'English';

  @override
  String get noResults => 'Ничего не найдено';

  @override
  String get searchHistory => 'История поиска';

  @override
  String get clearHistory => 'Очистить историю';

  @override
  String get listenAndGuess => 'Слушать и угадывать';

  @override
  String get matchPairs => 'Собери пары';

  @override
  String get game => 'Игра';

  @override
  String get listenInstruction =>
      'Прослушайте слово и выберите правильный вариант';

  @override
  String get listen => 'Прослушать';

  @override
  String get score => 'Счёт';

  @override
  String get bestScore => 'Рекорд';

  @override
  String get bestTime => 'Лучшее время';

  @override
  String get loading => 'Загрузка...';

  @override
  String get notEnoughEntries => 'Недостаточно записей в словаре';

  @override
  String get wrongTryAgain => 'Неверно. Послушайте ещё раз.';

  @override
  String get correct => 'Верно!';

  @override
  String get noMatch => 'Пара не совпала';

  @override
  String get matchCompleted => 'Все пары собраны!';

  @override
  String get playAgain => 'Играть ещё раз';

  @override
  String get backToGames => 'К выбору игр';

  @override
  String get back => 'Назад';

  @override
  String get dictionaryLoadError => 'Не удалось загрузить словарь';

  @override
  String get gameLoadError => 'Не удалось загрузить данные игры';

  @override
  String get audioPlaybackError => 'Ошибка воспроизведения';

  @override
  String get partOfSpeech => 'часть речи';

  @override
  String get meanings => 'значения';

  @override
  String get aboutDescription =>
      'Приложение аудио-словаря карельского языка ливвиковского наречия.';

  @override
  String get dictionarySource => 'Данные взяты с сайта:';

  @override
  String get versionLabel => 'Версия';

  @override
  String get pairsMatched => 'Собрано пар';

  @override
  String get elapsedTime => 'Время';

  @override
  String get karelianColumn => 'Карельское';

  @override
  String get translationColumn => 'Перевод';
}
