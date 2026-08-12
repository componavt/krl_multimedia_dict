import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:vepkar_audio/locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('LocaleController default locale is Russian', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = LocaleController();
    expect(controller.locale, const Locale('ru'));
  });

  test('LocaleController setLocale updates locale', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = LocaleController();

    await controller.setLocale(const Locale('en'));
    expect(controller.locale, const Locale('en'));

    await controller.setLocale(const Locale('ru'));
    expect(controller.locale, const Locale('ru'));
  });

  test('LocaleController loads saved locale', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('interface_locale', 'en');

    final controller = LocaleController();
    await controller.load();

    expect(controller.locale, const Locale('en'));

    await prefs.setString('interface_locale', 'ru');
    final controller2 = LocaleController();
    await controller2.load();
    expect(controller2.locale, const Locale('ru'));
  });
}