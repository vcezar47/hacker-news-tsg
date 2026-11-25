import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/comment.dart';
import '../models/feed.dart';
import '../models/story.dart';

class HnApi {
  static const _base = 'https://hn.algolia.com/api/v1';

  Future<List<Story>> fetchFeed(Feed feed) async {
    final hits = (await _get('$_base/${feed.path}'))['hits'] as List;
    return hits.map((h) => Story.fromJson(h as Map<String, dynamic>)).toList();
  }

  /// Details of one story from /items/:id.
  Future<Story> fetchItem(String id) async =>
      Story.fromItemJson(await _get('$_base/items/$id'));

  /// Same endpoint, but also returns the story's own text (Ask HN) and its comments.
  Future<({Story story, String? text, List<Comment> comments})> fetchThread(
    String id,
  ) async {
    final json = await _get('$_base/items/$id');
    final text = json['text'] as String?;
    return (
      story: Story.fromItemJson(json),
      text: text == null ? null : htmlToText(text),
      comments: Comment.flatten(json['children'] as List?),
    );
  }

  Future<Map<String, dynamic>> _get(String url) async {
    final res = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Server returned ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
