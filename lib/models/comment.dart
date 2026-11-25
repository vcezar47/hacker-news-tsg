class Comment {
  final String id;
  final String author;
  final String text; // plain text, HTML already stripped
  final DateTime createdAt;
  final int depth; // 0 = top-level reply to the story

  const Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    required this.depth,
  });

  /// Turns the nested "children" tree of /items/:id into one flat list, in reading order.
  /// Deleted comments (no text) are skipped, but their replies are kept.
  static List<Comment> flatten(List? children, [int depth = 0]) => [
    for (final c in children ?? const []) ...[
      if ((c as Map<String, dynamic>)['text'] != null)
        Comment(
          id: c['id'].toString(),
          author: (c['author'] as String?) ?? 'unknown',
          text: htmlToText(c['text'] as String),
          createdAt: DateTime.parse(c['created_at'] as String),
          depth: depth,
        ),
      ...flatten(c['children'] as List?, depth + 1),
    ],
  ];
}

/// HN comments are small HTML snippets (<p>, <a>, <i>, <pre>, entities).
String htmlToText(String html) {
  return html
      .replaceAll(RegExp(r'<p>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAllMapped(
        RegExp(r'&#x([0-9a-fA-F]+);'),
        (m) => String.fromCharCode(int.parse(m[1]!, radix: 16)),
      )
      .replaceAllMapped(
        RegExp(r'&#(\d+);'),
        (m) => String.fromCharCode(int.parse(m[1]!)),
      )
      .replaceAll('&quot;', '"')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&') // last, so "&amp;lt;" stays "&lt;"
      .trim();
}
