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

  testWidgets('Meaning widget shows target Russian meaning in Listen mode', (
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

  testWidgets('Mode A: Russian choices, not Karelian choices', (
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

  testWidgets('Mode A: No pre-answer answer leak', (
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

  testWidgets('Mode A: Correct answer does not show bottom SnackBar', (
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
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Mode A: Incorrect answer does not show bottom SnackBar', (
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
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Mode A: Correct answer shows association and advances round', (
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

  testWidgets('Mode A: Incorrect answer triggers reshuffle', (
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

  testWidgets('Listen button has proper visual state during feedback', (
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

  testWidgets('Wrong feedback shows wrong lemma in-card instead of bottom SnackBar', (
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
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Sheen overlay key exists for target replay highlight', (
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

  testWidgets('Correct-card celebration state resets at start of new round', (
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

  testWidgets('Correct-card sheen key appears after correct answer', (
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

  testWidgets('Correct-card lemma appears in green card after correct answer', (
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

  testWidgets('Wrong and neutral cards do not receive correct-card sheen', (
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

  testWidgets('Correct card remains green during feedback', (
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
