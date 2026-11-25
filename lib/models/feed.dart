/// The story lists the app can show. [path] is appended to the Algolia API base URL.
enum Feed {
  top('Top', 'search?tags=front_page'),
  latest('New', 'search_by_date?tags=story'),
  ask('Ask', 'search?tags=ask_hn');

  const Feed(this.label, this.path);

  final String label;
  final String path;
}
