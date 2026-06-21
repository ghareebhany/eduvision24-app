import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
//  Theme Mode controller (light / dark / system) with local persistence.
//  يتيح للمستخدم التبديل اليدوي بين الوضع الفاتح والليلي مع حفظ الاختيار.
// ============================================================================

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  static const String _prefsKey = 'app_theme_mode';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_prefsKey);
      switch (value) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
      }
    } catch (_) {
      // تجاهل أي خطأ في القراءة ونُبقي الوضع الافتراضي.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system';
      await prefs.setString(_prefsKey, encoded);
    } catch (_) {
      // تجاهل أخطاء الحفظ.
    }
  }

  // تبديل سريع بين الفاتح والليلي (يُستخدم في زر الـ AppBar).
  void toggle(BuildContext context) {
    final isDark = state == ThemeMode.dark ||
        (state == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

// Helper: هل الوضع الحالي داكن فعليًا (بأخذ وضع النظام في الحسبان)؟
bool isDarkMode(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;
