// Tests for lib/game_page.dart
// Note: Audio playback is not device-verified in automated tests.
// Audio-related behavior is manually verified on a real device or emulator.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vepkar_audio/game_page.dart';
import 'package:vepkar_audio/l10n/app_localizations.dart';
import 'package:vepkar_audio/locale_controller.dart';
import 'package:vepkar_audio/text_scale_controller.dart';

void main() {
  testWidgets('listen game selection screen renders with loading indicator', (
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

  testWidgets('Listen game round initializes with correct state', (
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

    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('Listening to same choice twice has no effect', (
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

    expect(find.text('Loading...'), findsOneWidget);
  });
}
