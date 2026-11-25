import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/story.dart';
import '../providers/favorites_provider.dart';
import '../services/calendar_service.dart';
import '../widgets/screen_header.dart';
import '../widgets/settings_menu.dart';
import '../widgets/story_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> _export(BuildContext context, Story story) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = await showDatePicker(
      context: context,
      helpText: 'Pick the day for the calendar event',
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 730)),
    );
    if (day == null || !context.mounted) return;

    String? error;
    try {
      error = await context.read<CalendarService>().addStory(story, day);
    } catch (_) {
      error = 'Could not save the event.';
    }
    if (!context.mounted) return;

    final (from, to) = slotFor(day);
    final hours =
        '${from.toString().padLeft(2, '0')}:00-${to.toString().padLeft(2, '0')}:00';
    final when = '${DateFormat('EEE d MMM').format(day)}, $hours';
    if (error == null) {
      context.read<FavoritesProvider>().markExported(story.id, when);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Added to your calendar: $when')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final count = favorites.stories.length;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(
              caption: count == 1 ? '1 saved story' : '$count saved stories',
              title: 'Favorites',
              trailing: const SettingsMenu(),
            ),
            Expanded(
              child: count == 0
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No favorites yet.\nTap the star on a story to save it.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: favorites.refresh,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        itemCount: count,
                        itemBuilder: (_, i) {
                          final story = favorites.stories[i];
                          return _RemovableCard(
                            key: ValueKey(story.id),
                            onRemoved: () => favorites.toggle(story),
                            builder: (remove) => StoryCard(
                              story: story,
                              index: i,
                              footer: Row(
                                children: [
                                  Expanded(
                                    child: _ExportButton(
                                      label: favorites.exportLabel(story.id),
                                      onTap: () => _export(context, story),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove from favorites',
                                    icon: Icon(
                                      Icons.close,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    onPressed: remove,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fades the card out and collapses the gap before the story is actually removed.
class _RemovableCard extends StatefulWidget {
  const _RemovableCard({
    super.key,
    required this.builder,
    required this.onRemoved,
  });

  final Widget Function(VoidCallback remove) builder;
  final VoidCallback onRemoved;

  @override
  State<_RemovableCard> createState() => _RemovableCardState();
}

class _RemovableCardState extends State<_RemovableCard> {
  bool _gone = false;

  Future<void> _remove() async {
    setState(() => _gone = true);
    await Future.delayed(const Duration(milliseconds: 300));
    widget.onRemoved();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: Align(
        heightFactor: _gone ? 0 : 1,
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: _gone ? 0 : 1,
          child: widget.builder(_remove),
        ),
      ),
    );
  }
}

/// "Add to calendar", which turns into a green chip with the event's day and time once exported.
class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.label, required this.onTap});

  final String? label; // e.g. "Mon 23 Nov, 14:00-20:00"; null if never exported
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = label != null;
    final fg = done ? scheme.onTertiaryContainer : scheme.onPrimaryContainer;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: done ? scheme.tertiaryContainer : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Row(
                key: ValueKey(label),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    done ? Icons.event_available : Icons.edit_calendar_outlined,
                    size: 18,
                    color: fg,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label ?? 'Add to calendar',
                    style: TextStyle(
                      color: fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
