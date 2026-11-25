import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/story.dart';
import '../services/hn_api.dart';

/// Keeps story snapshots on the device (so the page opens instantly, even offline)
/// and refreshes each one from /items/:id. Also remembers when a favorite was last
/// added to the calendar, so the Favorites page can show it.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._prefs, this._api)
    : _stories = (_prefs.getStringList(_key) ?? [])
          .map((s) => Story.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList(),
      _exports = _readExports(_prefs) {
    refresh();
  }

  static const _key = 'favorites';
  static const _exportsKey = 'exports';

  final SharedPreferences _prefs;
  final HnApi _api;
  final List<Story> _stories;
  final Map<String, String> _exports; // story id -> "Mon 23 Nov, 14:00-20:00"

  List<Story> get stories => List.unmodifiable(_stories);

  bool isFavorite(String id) => _stories.any((s) => s.id == id);

  /// Text describing the last calendar export of this story, or null if none.
  String? exportLabel(String id) => _exports[id];

  /// Adds the story, or removes it if it is already a favorite.
  Future<void> toggle(Story story) async {
    if (isFavorite(story.id)) {
      _stories.removeWhere((s) => s.id == story.id);
      _exports.remove(story.id);
    } else {
      _stories.insert(0, story);
    }
    notifyListeners();
    await _save();
  }

  Future<void> markExported(String id, String label) async {
    _exports[id] = label;
    notifyListeners();
    await _save();
  }

  /// Re-fetches every favorite from /items/:id; a story that fails keeps its saved copy.
  Future<void> refresh() async {
    final fresh = await Future.wait(_stories.toList().map(_fetchOrKeep));
    final byId = {for (final s in fresh) s.id: s};
    for (var i = 0; i < _stories.length; i++) {
      _stories[i] = byId[_stories[i].id] ?? _stories[i];
    }
    notifyListeners();
    await _save();
  }

  Future<Story> _fetchOrKeep(Story saved) async {
    try {
      return await _api.fetchItem(saved.id);
    } catch (_) {
      return saved;
    }
  }

  Future<void> _save() async {
    await _prefs.setStringList(
      _key,
      _stories.map((s) => jsonEncode(s.toJson())).toList(),
    );
    await _prefs.setString(_exportsKey, jsonEncode(_exports));
  }

  static Map<String, String> _readExports(SharedPreferences prefs) {
    try {
      final raw = jsonDecode(prefs.getString(_exportsKey) ?? '{}') as Map;
      return raw.map((k, v) => MapEntry(k as String, v as String));
    } catch (_) {
      return {}; // unreadable saved data: start with no exports
    }
  }
}
