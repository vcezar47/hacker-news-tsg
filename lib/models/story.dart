class Story {
  final String id;
  final String title;
  final String author;
  final String url;
  final int points;
  final int comments;
  final DateTime createdAt;

  const Story({
    required this.id,
    required this.title,
    required this.author,
    required this.url,
    required this.points,
    required this.comments,
    required this.createdAt,
  });

  // Reads the Algolia field names; toJson() writes the same ones, so favorites reuse this.
  factory Story.fromJson(Map<String, dynamic> json) {
    final id = json['objectID'] as String;
    final url = json['url'] as String?;
    return Story(
      id: id,
      title: (json['title'] as String?) ?? '(no title)',
      author: (json['author'] as String?) ?? 'unknown',
      // Ask HN and similar posts have no external link: fall back to the HN page.
      url: (url == null || url.isEmpty)
          ? 'https://news.ycombinator.com/item?id=$id'
          : url,
      points: (json['points'] as int?) ?? 0,
      comments: (json['num_comments'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // /items/:id has numeric "id" and no comment count, only the nested comment tree.
  factory Story.fromItemJson(Map<String, dynamic> json) {
    int count(Map<String, dynamic> node) =>
        ((node['children'] as List?) ?? []).fold<int>(
          0,
          (sum, child) => sum + 1 + count(child as Map<String, dynamic>),
        );
    return Story.fromJson({
      ...json,
      'objectID': json['id'].toString(),
      'num_comments': count(json),
    });
  }

  Map<String, dynamic> toJson() => {
    'objectID': id,
    'title': title,
    'author': author,
    'url': url,
    'points': points,
    'num_comments': comments,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}
