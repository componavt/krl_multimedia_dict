import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:vepkar_audio/game_page.dart';
import 'package:vepkar_audio/locale_controller.dart';
import 'package:vepkar_audio/l10n/app_localizations.dart';

void main() {
  testWidgets('GamePage instantiates without error', (
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
        home: GamePage(localeController: LocaleController()..notifyListeners()),
      ),
    );

    expect(find.byType(GamePage), findsOneWidget);
  });
}
