import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vepkar_audio/game_page.dart';
import 'package:vepkar_audio/l10n/app_localizations.dart';
import 'package:vepkar_audio/locale_controller.dart';
import 'package:vepkar_audio/text_scale_controller.dart';

void main() {
  testWidgets('listen game selection screen renders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GamePage(
          localeController: LocaleController(),
          textScaleController: TextScaleController(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
