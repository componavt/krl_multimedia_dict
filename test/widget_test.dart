import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vepkar_audio/dictionary_home_page.dart';
import 'package:vepkar_audio/l10n/app_localizations.dart';
import 'package:vepkar_audio/locale_controller.dart';
import 'package:vepkar_audio/text_scale_controller.dart';

void main() {
  testWidgets('search input is readable (has text, search icon, clear icon)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MyApp(
          localeController: LocaleController(),
          textScaleController: TextScaleController(),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsNothing);

    await tester.enterText(find.byType(TextField), 'test');
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets('Drawer has hamburger menu icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MyApp(
          localeController: LocaleController(),
          textScaleController: TextScaleController(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();

    expect(find.text('Menu'), findsOneWidget);
  });

  testWidgets('statistics Drawer item exists', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MyApp(
          localeController: LocaleController(),
          textScaleController: TextScaleController(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();

    expect(find.text('Statistics'), findsOneWidget);
  });

  testWidgets('language switch is last Drawer item', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MyApp(
          localeController: LocaleController(),
          textScaleController: TextScaleController(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();

    expect(find.byIcon(Icons.language), findsOneWidget);
  });
}
