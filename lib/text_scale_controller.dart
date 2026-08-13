import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTextSize { small, medium, large }

class TextScaleController extends ChangeNotifier {
  static const String _storageKey = 'app_text_size';

  AppTextSize _size = AppTextSize.medium;

  AppTextSize get size => _size;

  double get scale {
    switch (_size) {
      case AppTextSize.small:
        return 0.95;
      case AppTextSize.medium:
        return 1.25;
      case AppTextSize.large:
        return 1.75;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);

    if (stored != null) {
      final parsed = AppTextSize.values
          .where((value) => value.name == stored)
          .toList();
      if (parsed.isNotEmpty) {
        _size = parsed.first;
        notifyListeners();
      } else {
        _size = AppTextSize.medium;
        notifyListeners();
        await prefs.setString(_storageKey, _size.name);
      }
    }
  }

  Future<void> setSize(AppTextSize value) async {
    if (_size == value) {
      return;
    }

    _size = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, value.name);
  }
}
