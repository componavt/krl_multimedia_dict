import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_theme.dart';
import 'dictionary_home_page.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'text_scale_controller.dart';

class DictionaryApp extends StatelessWidget {
  const DictionaryApp({
    super.key,
    required this.localeController,
    required this.textScaleController,
  });

  final LocaleController localeController;
  final TextScaleController textScaleController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([localeController, textScaleController]),
      builder: (context, child) {
        return MaterialApp(
          title: 'Karelian Multimedia Dictionary',
          debugShowCheckedModeBanner: false,
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: buildAppTheme(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScaleController.scale),
              ),
              child: child!,
            );
          },
          home: MyApp(
            localeController: localeController,
            textScaleController: textScaleController,
          ),
        );
      },
    );
  }
}
