import 'package:flutter/widgets.dart';

import 'app.dart';
import 'locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeController = LocaleController();
  await localeController.load();

  runApp(DictionaryApp(localeController: localeController));
}
