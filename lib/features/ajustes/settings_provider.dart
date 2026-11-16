import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider de Ajustes y Accesibilidad de la Aplicación.
///
/// Gestiona con persistencia local (SharedPreferences):
/// 1. Modo Oscuro / Claro / Adaptado al Sistema del dispositivo.
/// 2. Tamaño de texto accesible (Normal / Grande 1.25x para WCAG AA).
/// 3. Modo Demostración (simulación de GPS para defensa académica).
class SettingsProvider extends ChangeNotifier {
  static const String _prefThemeKey = 'app_theme_mode';
  static const String _prefLargeTextKey = 'app_large_text';
  static const String _prefDemoModeKey = 'app_demo_mode';

  SharedPreferences? _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLargeText = false;
  bool _isDemoMode = false;

  SettingsProvider({SharedPreferences? prefs}) {
    if (prefs != null) {
      _prefs = prefs;
      _loadFromPrefs();
    } else {
      _initPrefs();
    }
  }

  ThemeMode get themeMode => _themeMode;
  bool get isLargeText => _isLargeText;
  bool get isDemoMode => _isDemoMode;

  double get textScaleFactor => _isLargeText ? 1.25 : 1.0;

  /// Indica si la app sigue automáticamente el modo claro/oscuro del dispositivo
  bool get isFollowingSystem => _themeMode == ThemeMode.system;

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadFromPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Aviso: SharedPreferences no disponible en este entorno ($e)');
    }
  }

  void _loadFromPrefs() {
    if (_prefs == null) return;

    // Tema: 'system', 'light', 'dark'. Por defecto 'system' (se adapta al dispositivo)
    final themeStr = _prefs!.getString(_prefThemeKey);
    if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    _isLargeText = _prefs!.getBool(_prefLargeTextKey) ?? false;
    _isDemoMode = _prefs!.getBool(_prefDemoModeKey) ?? false;
  }

  /// Establecer tema directamente
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      final modeStr = mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.light
              ? 'light'
              : 'system';
      await _prefs?.setString(_prefThemeKey, modeStr);
    }
  }

  /// Conmutar tema oscuro/claro manual
  Future<void> toggleThemeMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _prefs?.setString(_prefThemeKey, isDark ? 'dark' : 'light');
  }

  /// Restablecer para seguir automáticamente el tema del sistema/dispositivo
  Future<void> useSystemTheme() async {
    _themeMode = ThemeMode.system;
    notifyListeners();
    await _prefs?.setString(_prefThemeKey, 'system');
  }

  /// Alternar tamaño de texto grande accesible (1.25x)
  Future<void> toggleLargeText(bool value) async {
    _isLargeText = value;
    notifyListeners();
    await _prefs?.setBool(_prefLargeTextKey, value);
  }

  /// Alternar modo demostración académica (para defensa en aula)
  Future<void> toggleDemoMode(bool value) async {
    _isDemoMode = value;
    notifyListeners();
    await _prefs?.setBool(_prefDemoModeKey, value);
  }
}
