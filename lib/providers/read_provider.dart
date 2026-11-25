import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which stories the user has opened (in the browser or the comments page).
class ReadProvider extends ChangeNotifier {
  ReadProvider(this._prefs)
    : _read = (_prefs.getStringList(_key) ?? []).toSet();

  static const _key = 'read';

  final SharedPreferences _prefs;
  final Set<String> _read;

  bool isRead(String id) => _read.contains(id);

  Future<void> markRead(String id) async {
    // already read: nothing to save, nothing to redraw
    if (!_read.add(id)) return;
    notifyListeners();
    await _prefs.setStringList(_key, _read.toList());
  }
}
