import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/feed.dart';
import '../providers/favorites_provider.dart';
import '../providers/read_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/stories_provider.dart';
import '../widgets/screen_header.dart';
import '../widgets/settings_menu.dart';
import '../widgets/star_button.dart';
import '../widgets/story_card.dart';
import '../widgets/swipe_actions.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final _search = TextEditingController();
  bool _searching = false;

  static const _captions = {
    Feed.top: 'Top stories right now',
    Feed.latest: 'Newest first',
    Feed.ask: 'Questions for the crowd',
  };
  static const _featuredLabels = {
    Feed.top: 'Top story',
    Feed.latest: 'Latest',
    Feed.ask: 'Ask HN',
  };

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggleSearch(StoriesProvider provider) {
    setState(() => _searching = !_searching);
    if (!_searching) {
      _search.clear();
      provider.setQuery('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoriesProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final read = context.watch<ReadProvider>();
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final stories = settings.hideRead
        ? provider.stories.where((s) => !read.isRead(s.id)).toList()
        : provider.stories;
    final showFeatured = stories.isNotEmpty && _search.text.trim().isEmpty;

    // [kind] keys the switcher below: it cross-fades when the screen changes state or feed,
    // but not while typing in the search box.
    String kind;
    Widget body;
    if (!provider.hasStories && provider.loading) {
      kind = 'loading';
      body = const Center(child: CircularProgressIndicator());
    } else if (!provider.hasStories) {
      kind = 'error';
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.error ?? 'No stories found.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: provider.load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else if (stories.isEmpty) {
      kind = 'nomatch';
      body = Center(
        child: Text(
          _search.text.trim().isEmpty
              ? "You've read everything here."
              : 'No stories match "${_search.text}".',
        ),
      );
    } else {
      kind = 'list';
      body = RefreshIndicator(
        onRefresh: provider.load,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          itemCount: stories.length,
          itemBuilder: (_, i) {
            final story = stories[i];
            final isFav = favorites.isFavorite(story.id);
            void toggle() => favorites.toggle(story);
            final featured = i == 0 && showFeatured;
            return SwipeActions(
              story: story,
              isFavorite: isFav,
              featured: featured,
              onToggleFavorite: toggle,
              onOpenComments: () => openStoryDetail(context, story),
              child: StoryCard(
                story: story,
                index: i,
                featuredLabel: featured
                    ? _featuredLabels[provider.feed]!
                    : null,
                trailing: StarButton(
                  isFavorite: isFav,
                  onPressed: toggle,
                  idleColor: featured ? Colors.white : null,
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(
              caption: _captions[provider.feed]!,
              title: 'Today on HN',
              trailing: const SettingsMenu(showHideRead: true),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  for (final f in Feed.values) ...[
                    _Pill(
                      selected: provider.feed == f,
                      onTap: () => provider.setFeed(f),
                      child: Text(f.label),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  _Pill(
                    selected: _searching,
                    tonal: true,
                    onTap: () => _toggleSearch(provider),
                    child: Icon(
                      _searching ? Icons.close : Icons.search,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _searching
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: TextField(
                        controller: _search,
                        autofocus: true,
                        onChanged: provider.setQuery,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search title or author',
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          filled: true,
                          fillColor: scheme.surfaceContainer,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: provider.offline
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_off,
                            size: 18,
                            color: scheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Offline: showing saved stories',
                            style: TextStyle(
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                layoutBuilder: (current, previous) => Stack(
                  fit: StackFit.expand,
                  children: [...previous, ?current],
                ),
                child: KeyedSubtree(
                  key: ValueKey('${provider.feed.name}-$kind'),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded tab / button that animates between selected and unselected.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.selected,
    required this.onTap,
    required this.child,
    this.tonal = false,
  });

  final bool selected;
  final bool tonal; // the search button: tinted instead of solid when selected
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = selected
        ? (tonal ? scheme.primaryContainer : scheme.primary)
        : scheme.surfaceContainer;
    final text = selected
        ? (tonal ? scheme.onPrimaryContainer : scheme.onPrimary)
        : scheme.onPrimaryContainer;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(color: text, fontSize: 14),
          child: IconTheme.merge(
            data: IconThemeData(color: text),
            child: child,
          ),
        ),
      ),
    );
  }
}
