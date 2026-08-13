import 'package:flutter/widgets.dart';

import 'app.dart';
import 'locale_controller.dart';
import 'text_scale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeController = LocaleController();
  await localeController.load();

  final textScaleController = TextScaleController();
  await textScaleController.load();

  runApp(
    DictionaryApp(
      localeController: localeController,
      textScaleController: textScaleController,
    ),
  );
}
