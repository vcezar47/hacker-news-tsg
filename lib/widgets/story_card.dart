import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/story.dart';
import '../providers/read_provider.dart';
import '../screens/story_detail_screen.dart';
import 'fade_slide_in.dart';

Future<void> openInBrowser(BuildContext context, String url) async {
  final ok = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Could not open the link')));
  }
}

void openStoryDetail(BuildContext context, Story story) {
  context.read<ReadProvider>().markRead(story.id);
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story)));
}

/// Shared by the list page and the favorites page. [trailing] sits on the right
/// (star) and [footer] spans the bottom (calendar export, remove). Tapping the card
/// opens the link; the comment count opens the story page. Stories already opened
/// are dimmed and marked with a check. With [featuredLabel] (e.g. "Top story") the card
/// is drawn on solid indigo with that label on top.
class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.story,
    this.trailing,
    this.footer,
    this.featuredLabel,
    this.index = 99,
  });

  final Story story;
  final Widget? trailing;
  final Widget? footer;
  final String? featuredLabel;
  final int
  index; // position in the list, used to stagger the entrance animation

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final featured = featuredLabel != null;
    final dark = theme.brightness == Brightness.dark;
    final read = context.watch<ReadProvider>().isRead(story.id);

    const onIndigo = Colors.white;
    const onIndigoSoft = Color(0xFFE0E7FF);
    final titleColor = featured ? onIndigo : null;
    final softColor = featured ? onIndigoSoft : scheme.onSurfaceVariant;
    final accent = featured ? onIndigoSoft : scheme.primary;

    final date = DateFormat('d MMM yyyy, HH:mm')
        .format(story.createdAt.toLocal());
    final meta = theme.textTheme.bodySmall?.copyWith(color: softColor);

    return FadeSlideIn(
      index: index,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: read ? 0.55 : 1,
        child: Card(
          elevation: 0,
          color: featured
              ? (dark ? const Color(0xFF4338CA) : const Color(0xFF4F46E5))
              : scheme.surfaceContainer,
          margin: EdgeInsets.fromLTRB(16, featured ? 8 : 6, 16, 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(featured ? 22 : 18),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              context.read<ReadProvider>().markRead(story.id);
              openInBrowser(context, story.url);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (featured)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 0, 0, 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_outlined,
                            size: 16,
                            color: onIndigoSoft,
                          ),
                          const SizedBox(width: 6),
                          Text(featuredLabel!, style: meta),
                        ],
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PointsBadge(points: story.points),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                height: 1.3,
                                color: titleColor,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (read) ...[
                                  Icon(
                                    Icons.done_all,
                                    size: 14,
                                    color: softColor,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Flexible(
                                  child: Text(
                                    '${story.author} · $date',
                                    style: meta,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => openStoryDetail(context, story),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 16,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${story.comments} comments',
                                      style: meta,
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 16,
                                      color: softColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ?trailing,
                    ],
                  ),
                  ?footer,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The green points badge. Display only: Hacker News votes can't be cast from the app.
class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 46,
      height: 58,
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_upward, size: 18, color: scheme.onTertiaryContainer),
          Text(
            '$points',
            style: TextStyle(
              color: scheme.onTertiaryContainer,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
