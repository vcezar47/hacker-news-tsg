import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/feed.dart';
import '../models/story.dart';
import '../services/hn_api.dart';

class StoriesProvider extends ChangeNotifier {
  StoriesProvider(this._api, this._prefs) {
    load();
  }

  final HnApi _api;
  final SharedPreferences _prefs;

  // Last known list per feed: filled from the saved copy first, then from the network.
  final Map<Feed, List<Story>> _lists = {};
  Feed _feed = Feed.top;
  String _query = '';

  bool loading = false;
  String? error;

  /// True when the last refresh failed and the saved copy is being shown.
  bool offline = false;

  Feed get feed => _feed;

  bool get hasStories => _list(_feed).isNotEmpty;

  /// The current feed, filtered by the search text (title or author).
  List<Story> get stories {
    final q = _query.trim().toLowerCase();
    final all = _list(_feed);
    if (q.isEmpty) return all;
    return all
        .where(
          (s) =>
              s.title.toLowerCase().contains(q) ||
              s.author.toLowerCase().contains(q),
        )
        .toList();
  }

  void setFeed(Feed feed) {
    if (feed == _feed) return;
    _feed = feed;
    load();
  }

  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  Future<void> load() async {
    final feed = _feed; // the user may switch tabs while this request runs
    loading = true;
    error = null;
    offline = false;
    notifyListeners();
    try {
      final fresh = await _api.fetchFeed(feed);
      _lists[feed] = fresh;
      await _prefs.setStringList(
        _cacheKey(feed),
        fresh.map((s) => jsonEncode(s.toJson())).toList(),
      );
    } catch (_) {
      if (feed == _feed) {
        if (hasStories) {
          offline = true;
        } else {
          error =
              'Could not load stories. Check your connection and try again.';
        }
      }
    }
    if (feed == _feed) {
      loading = false;
      notifyListeners();
    }
  }

  List<Story> _list(Feed feed) => _lists[feed] ??= _readCache(feed);

  List<Story> _readCache(Feed feed) {
    try {
      return (_prefs.getStringList(_cacheKey(feed)) ?? [])
          .map((s) => Story.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // unreadable saved copy: behave as if there was none
    }
  }

  String _cacheKey(Feed feed) => 'feed_${feed.name}';
}
