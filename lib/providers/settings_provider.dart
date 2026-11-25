import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide choices that are saved on the phone: light / dark / system theme,
/// and whether stories already read are hidden from the feed.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs)
    : _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == _prefs.getString(_themeKey),
        orElse: () => ThemeMode.system,
      ),
      _hideRead = _prefs.getBool(_hideKey) ?? false;

  static const _themeKey = 'themeMode';
  static const _hideKey = 'hideRead';

  final SharedPreferences _prefs;
  ThemeMode _themeMode;
  bool _hideRead;

  ThemeMode get themeMode => _themeMode;
  bool get hideRead => _hideRead;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> setHideRead(bool value) async {
    _hideRead = value;
    notifyListeners();
    await _prefs.setBool(_hideKey, value);
  }
}
