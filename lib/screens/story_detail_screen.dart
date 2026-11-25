import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/comment.dart';
import '../models/story.dart';
import '../services/hn_api.dart';
import '../widgets/story_card.dart';

/// One story with its comment thread, loaded from /items/:id.
class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen({super.key, required this.story});

  final Story story;

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  late Future<({Story story, String? text, List<Comment> comments})> _thread;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _thread = context.read<HnApi>().fetchThread(widget.story.id);

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story'),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: () => SharePlus.instance.share(
              ShareParams(
                text: '${story.title}\n${story.url}',
                subject: story.title,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _thread,
        builder: (context, snap) {
          final data = snap.data;
          // One header row, then the comments (or a single status row).
          final rows = data == null || data.comments.isEmpty
              ? 1
              : data.comments.length;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: 1 + rows,
            itemBuilder: (_, i) {
              if (i == 0) {
                return _Header(story: data?.story ?? story, text: data?.text);
              }
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text('Could not load the comments.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => setState(_load),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (data == null) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (data.comments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No comments yet.')),
                );
              }
              return _CommentTile(comment: data.comments[i - 1]);
            },
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.story, this.text});

  final Story story;
  final String? text; // body of Ask HN posts

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('d MMM yyyy, HH:mm')
        .format(story.createdAt.toLocal());
    final meta = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(story.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('${story.author} · $date', style: meta),
          const SizedBox(height: 4),
          Text(
            '${story.points} points · ${story.comments} comments',
            style: meta,
          ),
          if (text != null) ...[const SizedBox(height: 12), Text(text!)],
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => openInBrowser(context, story.url),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Open in browser'),
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('d MMM, HH:mm').format(comment.createdAt.toLocal());
    // Replies are indented; very deep threads stop indenting so they stay readable.
    final indent = comment.depth.clamp(0, 5) * 14.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16 + indent, 6, 16, 6),
      child: Container(
        padding: comment.depth == 0
            ? EdgeInsets.zero
            : const EdgeInsets.only(left: 10),
        decoration: comment.depth == 0
            ? null
            : BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${comment.author} · $date',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(comment.text),
          ],
        ),
      ),
    );
  }
}
