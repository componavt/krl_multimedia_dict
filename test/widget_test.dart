import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:vepkar_audio/app.dart';
import 'package:vepkar_audio/l10n/app_localizations.dart';
import 'package:vepkar_audio/locale_controller.dart';

void main() {
  testWidgets('DictionaryApp instantiates without error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: DictionaryApp(
          localeController: LocaleController()..notifyListeners(),
        ),
      ),
    );

    expect(find.byType(DictionaryApp), findsOneWidget);
  });

  testWidgets('DictionaryApp does not show Icons.add', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: DictionaryApp(
          localeController: LocaleController()..notifyListeners(),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsNothing);
  });
}
